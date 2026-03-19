import importlib.resources as resources
import json
import os
import posixpath
import re
from argparse import ArgumentParser
from functools import cache
from pathlib import Path

import requests
import sb_dockerfile_gen.data

from sb_dockerfile_gen.constants import (
    CONTAINER_ENV_NAME,
    CONTAINER_WORKDIR,
    END_TEST_OUTPUT,
    HEADERS,
    MAP_REPO_TO_ENV_YML_PATHS,
    MAP_REPO_TO_INSTALL,
    MAP_REPO_TO_REQS_PATHS,
    MAP_REPO_VERSION_TO_SPECS,
    NON_TEST_EXTS,
    REPLACE_REQ_PACKAGES,
    START_TEST_OUTPUT,
    SWE_BENCH_URL_RAW,
    _DOCKERFILE_BASE,
)
from sb_dockerfile_gen.utils import (
    generate_heredoc_delimiter,
    git_clone_timesafe,
    make_heredoc_run_command,
)


# ── Dockerfile generation helpers ──────────────────────────────────────


@cache
def get_environment_yml_by_commit(repo: str, commit: str) -> str:
    for req_path in MAP_REPO_TO_ENV_YML_PATHS[repo]:
        reqs_url = posixpath.join(SWE_BENCH_URL_RAW, repo, commit, req_path)
        reqs = requests.get(reqs_url, headers=HEADERS)
        if reqs.status_code == 200:
            break
    else:
        raise ValueError(
            f"Could not find environment.yml at paths {MAP_REPO_TO_ENV_YML_PATHS[repo]} for repo {repo} at commit {commit}"
        )

    lines = reqs.text.split("\n")
    cleaned = []
    for line in lines:
        if line.startswith("name:"):
            cleaned.append(f"name: {CONTAINER_ENV_NAME}")
            continue
        cleaned.append(line)

    return "\n".join(cleaned)


def clean_environment_yml(yml_text: str) -> str:
    pip_match = re.search(r"^(\s*-\s*pip\s*:\s*\n)", yml_text, flags=re.MULTILINE)
    if not pip_match:
        return yml_text
    pip_indent = len(pip_match.group(1)) - len(pip_match.group(1).lstrip())
    pip_content_start = pip_match.end()
    lines_after_pip = yml_text[pip_content_start:].split("\n")
    pip_section_end = pip_content_start
    for ix, line in enumerate(lines_after_pip):
        if line.strip() == "":
            continue
        line_indent = len(line) - len(line.lstrip())
        if line_indent <= pip_indent:
            pip_section_end = pip_content_start + sum(
                len(l) + 1 for l in lines_after_pip[:ix]
            )
            break
    else:
        pip_section_end = len(yml_text)
    prefix = yml_text[:pip_content_start]
    pip_portion = yml_text[pip_content_start:pip_section_end]
    suffix = yml_text[pip_section_end:]
    for pkg_to_replace, replacement in REPLACE_REQ_PACKAGES:
        if replacement is None:
            pip_portion = re.sub(
                rf"^(\s*-\s*){re.escape(pkg_to_replace)}([<>~]=?.*|$)\n?",
                "",
                pip_portion,
                flags=re.MULTILINE,
            )
        else:
            pip_portion = re.sub(
                rf"^(\s*-\s*){re.escape(pkg_to_replace)}([<>=!~]=?.*|$)",
                rf"\1{replacement}",
                pip_portion,
                flags=re.MULTILINE,
            )
    return prefix + pip_portion + suffix


def get_environment_yml(instance: dict) -> str:
    commit = (
        instance["environment_setup_commit"]
        if "environment_setup_commit" in instance
        else instance["base_commit"]
    )
    yml_text = get_environment_yml_by_commit(instance["repo"], commit)
    yml_text = clean_environment_yml(yml_text)
    return yml_text


@cache
def get_requirements_by_commit(repo: str, commit: str) -> str:
    for req_path in MAP_REPO_TO_REQS_PATHS[repo]:
        reqs_url = posixpath.join(SWE_BENCH_URL_RAW, repo, commit, req_path)
        reqs = requests.get(reqs_url, headers=HEADERS)
        if reqs.status_code == 200:
            break
    else:
        raise ValueError(
            f"Could not find requirements.txt at paths {MAP_REPO_TO_REQS_PATHS[repo]} for repo {repo} at commit {commit}"
        )

    lines = reqs.text
    original_req = []
    additional_reqs = []
    req_dir = "/".join(req_path.split("/")[:-1])
    exclude_line = lambda line: any(
        [line.strip().startswith(x) for x in ["-e .", "#", ".[test"]]
    )

    for line in lines.split("\n"):
        if line.strip().startswith("-r"):
            file_name = line[len("-r") :].strip()
            reqs_url = os.path.join(
                SWE_BENCH_URL_RAW, repo, commit, req_dir, file_name
            )
            reqs = requests.get(reqs_url, headers=HEADERS)
            if reqs.status_code == 200:
                for line_extra in reqs.text.split("\n"):
                    if not exclude_line(line_extra):
                        additional_reqs.append(line_extra)
        else:
            if not exclude_line(line):
                original_req.append(line)

    additional_reqs.append("\n".join(original_req))
    return "\n".join(additional_reqs)


def clean_requirements(requirements_text: str) -> str:
    for pkg_to_replace, replacement in REPLACE_REQ_PACKAGES:
        if replacement is None:
            requirements_text = re.sub(
                rf"^{re.escape(pkg_to_replace)}([<>=!~]=?.*|$)\n?",
                "",
                requirements_text,
                flags=re.MULTILINE,
            )
        else:
            requirements_text = re.sub(
                rf"^{re.escape(pkg_to_replace)}([<>=!~]=?.*|$)",
                replacement,
                requirements_text,
                flags=re.MULTILINE,
            )
    return requirements_text


def get_requirements(instance: dict) -> str:
    commit = (
        instance["environment_setup_commit"]
        if "environment_setup_commit" in instance
        else instance["base_commit"]
    )
    requirements_text = get_requirements_by_commit(instance["repo"], commit)
    requirements_text = clean_requirements(requirements_text)
    return requirements_text


def make_repo_script_list(specs, repo, base_commit) -> str:
    setup_commands = [
        *git_clone_timesafe(repo, base_commit, CONTAINER_WORKDIR),
        "source /opt/miniconda3/bin/activate",
        f"conda activate {CONTAINER_ENV_NAME}",
        'echo "Current environment: $CONDA_DEFAULT_ENV"',
        f"cd {CONTAINER_WORKDIR}",
    ]
    if repo in MAP_REPO_TO_INSTALL:
        setup_commands.append(MAP_REPO_TO_INSTALL[repo])
    if specs.get("pre_install", None):
        for pre_install in specs["pre_install"]:
            setup_commands.append(pre_install)

    if "install" in specs:
        setup_commands.append(specs["install"])

    setup_commands += [
        "",
        "# Configure git",
        "git config --global user.email setup@swebench.com",
        "git config --global user.name SWE-bench",
        "git commit --allow-empty -am SWE-bench",
    ]

    return make_heredoc_run_command(setup_commands)


def load_cached_environment_yml(instance_id: str) -> str | None:
    owner = instance_id.split("__")[0]
    env_path = (
        resources.files(sb_dockerfile_gen.data)
        / "environments"
        / owner
        / f"{instance_id}.yml"
    )
    try:
        return env_path.read_text()
    except FileNotFoundError:
        return None


def make_env_script_list_from_conda(instance, specs, cached_environment_yml) -> list:
    delimiter = generate_heredoc_delimiter(cached_environment_yml)
    return [
        "source /opt/miniconda3/bin/activate",
        f"cat <<'{delimiter}' > /root/environment.yml\n{cached_environment_yml}\n{delimiter}",
        "conda env create -f /root/environment.yml",
        f"conda activate {CONTAINER_ENV_NAME}",
    ]


def make_env_script_list(instance, specs) -> str:
    cached_environment_yml = load_cached_environment_yml(instance["instance_id"])
    if cached_environment_yml:
        return make_heredoc_run_command(
            make_env_script_list_from_conda(instance, specs, cached_environment_yml)
        )
    reqs_commands = ["source /opt/miniconda3/bin/activate"]
    pkgs = specs.get("packages", "")
    if pkgs == "requirements.txt":
        reqs = get_requirements(instance)
        path_to_reqs = "/root/requirements.txt"
        reqs_commands += [
            f"conda create -n {CONTAINER_ENV_NAME} python={specs['python']} -y",
            f"conda activate {CONTAINER_ENV_NAME}",
            "",
            "# Create requirements file",
            f"cat > {path_to_reqs} << 'REQUIREMENTS_EOF'",
            reqs,
            "REQUIREMENTS_EOF",
            "",
            "# Install requirements",
            f"python -m pip install -r {path_to_reqs}",
            f"rm {path_to_reqs}",
        ]
    elif pkgs == "environment.yml":
        reqs = get_environment_yml(instance)
        path_to_reqs = "environment.yml"
        reqs_commands += [f"cat > {path_to_reqs} << 'ENV_EOF'", reqs, "ENV_EOF"]
        if specs.get("no_use_env", None):
            reqs_commands += [
                f"conda create -c conda-forge -n {CONTAINER_ENV_NAME} python={specs['python']} -y",
                f"conda env update -f {path_to_reqs}",
            ]
        else:
            reqs_commands += [
                f"conda env create --file {path_to_reqs}",
                f"conda activate {CONTAINER_ENV_NAME} && conda install python={specs['python']} -y",
            ]
        reqs_commands += [f"rm {path_to_reqs}"]
    else:
        reqs_commands += [
            f"conda create -n {CONTAINER_ENV_NAME} python={specs['python']} {pkgs} -y"
        ]

    reqs_commands.append(f"conda activate {CONTAINER_ENV_NAME}")
    if specs.get("pip_packages", None):
        reqs_commands += [f"python -m pip install {' '.join(specs['pip_packages'])}"]

    return make_heredoc_run_command(reqs_commands)


# ── Dockerfile generation ──────────────────────────────────────────────


def _get_dockerfile(instance) -> str:
    repo = instance["repo"]
    version = instance.get("version")
    base_commit = instance["base_commit"]
    specs = MAP_REPO_VERSION_TO_SPECS[repo][version]
    env_script = make_env_script_list(instance, specs)
    repo_script = make_repo_script_list(specs, repo, base_commit)
    dockerfile = _DOCKERFILE_BASE
    dockerfile += f"\n{env_script}\n" if env_script else ""
    dockerfile += '\nRUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc\n'
    dockerfile += f"\n{repo_script}\n" if repo_script else ""
    dockerfile += "\nWORKDIR /testbed/\n"
    return dockerfile


# ── Eval script generation ─────────────────────────────────────────────


def _get_test_directives(instance: dict) -> list[str]:
    """Get test file directives from the test_patch."""
    diff_pat = r"diff --git a/.* b/(.*)"
    directives = re.findall(diff_pat, instance["test_patch"])
    directives = [
        d
        for d in directives
        if not any(d.endswith(ext) for ext in NON_TEST_EXTS)
    ]
    return directives


def _get_eval_script(instance: dict) -> str:
    """Generate the eval.sh script for an instance."""
    repo = instance["repo"]
    version = instance.get("version")
    base_commit = instance["base_commit"]
    test_patch = instance["test_patch"]
    specs = MAP_REPO_VERSION_TO_SPECS[repo][version]

    # Files modified by the test patch
    test_files = re.findall(r"diff --git a/.* b/(.*)", test_patch)
    reset_tests_command = f"git checkout {base_commit} {' '.join(test_files)}"

    HEREDOC_DELIMITER = "EOF_114329324912"
    apply_test_patch_command = (
        f"git apply -v - <<'{HEREDOC_DELIMITER}'\n{test_patch}\n{HEREDOC_DELIMITER}"
    )

    test_command = " ".join(
        [specs["test_cmd"], *_get_test_directives(instance)]
    )

    eval_commands = [
        "#!/bin/bash",
        "set -uxo pipefail",
        "source /opt/miniconda3/bin/activate",
        f"conda activate {CONTAINER_ENV_NAME}",
        f"cd {CONTAINER_WORKDIR}",
    ]
    if "eval_commands" in specs:
        eval_commands += specs["eval_commands"]
    eval_commands += [
        f"git config --global --add safe.directory {CONTAINER_WORKDIR}",
        f"cd {CONTAINER_WORKDIR}",
        "git status",
        "git show",
        f"git -c core.fileMode=false diff {base_commit}",
        "source /opt/miniconda3/bin/activate",
        f"conda activate {CONTAINER_ENV_NAME}",
    ]
    if "install" in specs:
        eval_commands.append(specs["install"])
    eval_commands += [
        reset_tests_command,
        apply_test_patch_command,
        f": '{START_TEST_OUTPUT}'",
        test_command,
        f": '{END_TEST_OUTPUT}'",
        reset_tests_command,
    ]
    return "\n".join(eval_commands) + "\n"


# ── CLI ────────────────────────────────────────────────────────────────


def load_instances(
    dataset_name_or_path: str,
    split: str = "test",
    instance_ids: list[str] | None = None,
):
    """Load instances from HuggingFace dataset name or local JSON/JSONL file."""
    path = Path(dataset_name_or_path)
    if path.exists() and path.is_file():
        if path.suffix == ".jsonl":
            with open(path) as f:
                instances = [json.loads(line) for line in f if line.strip()]
        else:
            with open(path) as f:
                instances = json.load(f)
            if isinstance(instances, dict):
                instances = list(instances.values())
        if instance_ids:
            instance_ids_set = set(instance_ids)
            instances = [
                i for i in instances if i["instance_id"] in instance_ids_set
            ]
        return instances
    # Fall back to HuggingFace (optional dependency)
    from swebench.harness.utils import load_swebench_dataset

    return load_swebench_dataset(
        dataset_name_or_path, split, instance_ids=instance_ids
    )


def generate_instances(
    dataset_name_or_path: str,
    split: str = "test",
    output_dir: str = "src/instances",
    instance_ids: list[str] | None = None,
):
    """Generate Dockerfiles for each instance."""
    instances = load_instances(dataset_name_or_path, split, instance_ids)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    for instance in instances:
        dockerfile_path = output_path / f"{instance['instance_id']}.Dockerfile"
        dockerfile_path.write_text(_get_dockerfile(instance))

    print(f"Generated {len(instances)} Dockerfiles in {output_path}")


def main():
    parser = ArgumentParser(
        description="Generate Dockerfiles for SWE-bench (original Python benchmarks)"
    )
    parser.add_argument(
        "dataset",
        help="HuggingFace dataset name or path to local JSON/JSONL file",
    )
    parser.add_argument("--split", default="test")
    parser.add_argument("--output_dir", default="src/instances")
    parser.add_argument("--instance_ids", nargs="+", default=None)
    args = parser.parse_args()
    generate_instances(args.dataset, args.split, args.output_dir, args.instance_ids)


if __name__ == "__main__":
    main()
