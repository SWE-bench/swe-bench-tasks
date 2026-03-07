#!/usr/bin/env python3
"""
Audit pinned dependencies: compare pip freeze from Docker containers
against what's declared in the cached environment YML files.

Detects:
  1. Packages in the container but NOT in the YML (undeclared deps)
  2. Packages in the YML but NOT in the container (phantom deps)
  3. Version mismatches between container and YML

Usage:
  # Audit all available images (parallel, up to 8 at a time)
  python scripts/audit_pinned_deps.py

  # Audit specific instances
  python scripts/audit_pinned_deps.py django__django-10087 sympy__sympy-24661

  # Output as JSON
  python scripts/audit_pinned_deps.py --json

  # Limit parallelism
  python scripts/audit_pinned_deps.py --workers 4
"""

import argparse
import glob
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_DIR = SCRIPT_DIR.parent
ENV_DIR = REPO_DIR / "src" / "sb_dockerfile_gen" / "data" / "environments"
DOCKERFILES_DIR = REPO_DIR / "src" / "dockerfiles"


def normalize_pkg_name(name: str) -> str:
    """Normalize package name: lowercase, replace hyphens/underscores/dots with hyphens."""
    return re.sub(r"[-_.]+", "-", name.lower())


def parse_yml_packages(yml_path: str) -> tuple[dict[str, str], dict[str, str]]:
    """Extract packages from a conda environment.yml file.

    Returns (pip_pkgs, conda_pkgs) where each is {normalized_name: version}.
    """
    pip_pkgs = {}
    conda_pkgs = {}
    in_pip = False
    in_deps = False
    with open(yml_path) as f:
        for line in f:
            stripped = line.strip()
            if stripped == "dependencies:":
                in_deps = True
                continue
            if stripped == "- pip:":
                in_pip = True
                continue
            if stripped.startswith("prefix:") or stripped.startswith("name:") or stripped.startswith("channels:"):
                in_pip = False
                in_deps = False
                continue
            if in_pip:
                if stripped.startswith("- ") and "==" in stripped:
                    pkg_spec = stripped[2:].strip()
                    name, version = pkg_spec.split("==", 1)
                    pip_pkgs[normalize_pkg_name(name)] = version
                elif stripped.startswith("- ") and "==" not in stripped:
                    pkg_name = stripped[2:].strip()
                    pip_pkgs[normalize_pkg_name(pkg_name)] = "UNPINNED"
                elif not stripped.startswith("- ") and not stripped.startswith("#"):
                    in_pip = False
            elif in_deps and stripped.startswith("- ") and "=" in stripped:
                pkg_spec = stripped[2:].strip()
                parts = pkg_spec.split("=")
                if len(parts) >= 2:
                    name = parts[0]
                    version = parts[1]
                    conda_pkgs[normalize_pkg_name(name)] = version
    return pip_pkgs, conda_pkgs


def parse_pip_freeze(freeze_output: str) -> dict[str, str]:
    """Parse pip freeze output into {name: version} dict."""
    pkgs = {}
    for line in freeze_output.strip().split("\n"):
        line = line.strip()
        if "==" in line:
            name, version = line.split("==", 1)
            pkgs[normalize_pkg_name(name)] = version
        # Skip lines with @ file:// (conda-installed via local paths)
    return pkgs


def find_docker_image(instance_id: str) -> str | None:
    """Find the Docker image tag for a given instance_id.

    Image naming: swebench/sweb.eval.x86_64.{org}_{hash}_{repo}-{issue}:latest
    Instance ID:  {org}__{repo}-{issue}
    Example:      django__django-10087 -> swebench/sweb.eval.x86_64.django_1776_django-10087:latest
    """
    result = subprocess.run(
        ["docker", "images", "--format", "{{.Repository}}:{{.Tag}}"],
        capture_output=True,
        text=True,
    )
    # e.g., django__django-10087 -> search for "_django-10087:" in image names
    parts = instance_id.split("__")
    if len(parts) != 2:
        return None
    _, repo_issue = parts
    search = f"_{repo_issue}:"

    for line in result.stdout.strip().split("\n"):
        if search in line and line.startswith("swebench/"):
            return line
    return None


def find_yml_file(instance_id: str) -> str | None:
    """Find the cached environment YML for an instance."""
    for yml in glob.glob(str(ENV_DIR / "**" / f"{instance_id}.yml"), recursive=True):
        return yml
    return None


def audit_instance(instance_id: str) -> dict:
    """Compare pip freeze from Docker with the cached YML."""
    result = {
        "instance_id": instance_id,
        "status": "ok",
        "undeclared": [],  # in container but not in YML
        "phantom": [],  # in YML but not in container
        "mismatched": [],  # version differs
        "errors": [],
    }

    # Find the YML
    yml_path = find_yml_file(instance_id)
    if not yml_path:
        result["status"] = "error"
        result["errors"].append("No cached environment.yml found")
        return result

    # Find the Docker image
    image = find_docker_image(instance_id)
    if not image:
        result["status"] = "skip"
        result["errors"].append("No Docker image found")
        return result

    # Get pip freeze from container
    try:
        proc = subprocess.run(
            [
                "docker",
                "run",
                "--rm",
                image,
                "bash",
                "-c",
                "source /opt/miniconda3/bin/activate testbed && pip list --format=freeze 2>/dev/null",
            ],
            capture_output=True,
            text=True,
            timeout=60,
        )
        if proc.returncode != 0:
            result["status"] = "error"
            result["errors"].append(f"pip list failed: {proc.stderr[:200]}")
            return result
        container_pkgs = parse_pip_freeze(proc.stdout)
    except subprocess.TimeoutExpired:
        result["status"] = "error"
        result["errors"].append("Docker run timed out")
        return result

    # Parse YML — get both pip and conda sections
    yml_pip_pkgs, yml_conda_pkgs = parse_yml_packages(yml_path)
    # Combined: all packages declared in the YML
    yml_all = {**yml_conda_pkgs, **yml_pip_pkgs}

    # Compare pip freeze (container) against YML pip section
    # Only flag drift for pip-managed packages; conda packages (python, zlib, etc.)
    # won't show up in pip freeze and that's expected.
    repo_name = instance_id.split("__")[1].rsplit("-", 1)[0].lower()
    normalized_repo = normalize_pkg_name(repo_name)
    repo_aliases = {repo_name, normalized_repo, repo_name.replace("-", "_"), repo_name.replace("_", "-")}

    for name, version in sorted(container_pkgs.items()):
        if name in repo_aliases or any(alias in name for alias in repo_aliases):
            continue  # Skip the repo itself
        if name not in yml_all:
            result["undeclared"].append(f"{name}=={version}")
        elif name in yml_pip_pkgs:
            if yml_pip_pkgs[name] == "UNPINNED":
                result["mismatched"].append(
                    f"{name}: yml=UNPINNED, container=={version}"
                )
            elif yml_pip_pkgs[name] != version:
                result["mismatched"].append(
                    f"{name}: yml=={yml_pip_pkgs[name]}, container=={version}"
                )

    # Only report phantom for pip packages that aren't also in conda section
    # (conda-installed packages won't appear in pip freeze)
    for name, version in sorted(yml_pip_pkgs.items()):
        if name not in container_pkgs and name not in yml_conda_pkgs:
            result["phantom"].append(f"{name}=={version}")

    if result["undeclared"] or result["phantom"] or result["mismatched"]:
        result["status"] = "drift"

    return result


def get_all_instance_ids() -> list[str]:
    """Get all instance IDs that have both a Dockerfile and a cached YML."""
    ids = []
    for f in sorted(glob.glob(str(DOCKERFILES_DIR / "*.Dockerfile"))):
        instance_id = os.path.basename(f).replace(".Dockerfile", "")
        ids.append(instance_id)
    return ids


def main():
    parser = argparse.ArgumentParser(description="Audit pinned deps vs Docker containers")
    parser.add_argument("instances", nargs="*", help="Instance IDs to audit (default: all)")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    parser.add_argument("--workers", type=int, default=8, help="Parallel workers (default: 8)")
    parser.add_argument("--only-drift", action="store_true", help="Only show instances with drift")
    args = parser.parse_args()

    instances = args.instances or get_all_instance_ids()
    print(f"Auditing {len(instances)} instances with {args.workers} workers...", file=sys.stderr)

    results = []
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = {pool.submit(audit_instance, iid): iid for iid in instances}
        for i, future in enumerate(as_completed(futures), 1):
            result = future.result()
            results.append(result)
            if not args.json:
                status_icon = {"ok": ".", "drift": "D", "skip": "S", "error": "E"}
                print(status_icon.get(result["status"], "?"), end="", flush=True, file=sys.stderr)
                if i % 80 == 0:
                    print(file=sys.stderr)

    if not args.json:
        print(file=sys.stderr)

    results.sort(key=lambda r: r["instance_id"])

    if args.json:
        print(json.dumps(results, indent=2))
        return

    # Summary
    ok = sum(1 for r in results if r["status"] == "ok")
    drift = sum(1 for r in results if r["status"] == "drift")
    skip = sum(1 for r in results if r["status"] == "skip")
    errors = sum(1 for r in results if r["status"] == "error")

    print(f"\n{'='*60}")
    print(f"Results: {ok} ok, {drift} drift, {skip} skipped, {errors} errors")
    print(f"{'='*60}")

    for r in results:
        if args.only_drift and r["status"] != "drift":
            continue
        if r["status"] == "ok":
            continue

        print(f"\n  {r['instance_id']} [{r['status'].upper()}]")
        for err in r["errors"]:
            print(f"    ERROR: {err}")
        for item in r["undeclared"]:
            print(f"    + UNDECLARED (in container, not in yml): {item}")
        for item in r["phantom"]:
            print(f"    - PHANTOM (in yml, not in container): {item}")
        for item in r["mismatched"]:
            print(f"    ~ MISMATCH: {item}")


if __name__ == "__main__":
    main()
