# Dependency Audit Report — SWE-bench Verified (500 instances)

**Date:** 2026-03-07
**Tool:** `scripts/audit_pinned_deps.py`
**Cache:** `scripts/audit_results.json`

## What the audit does

Compares `pip list --format=freeze` output from each Docker container against the cached environment YML (`data/environments/<owner>/<instance_id>.yml`). Detects:

1. **Undeclared** — package in container but not in YML
2. **Phantom** — package in YML but not in container
3. **Mismatch** — version differs between container and YML

## Results summary

| Status | Count | Description |
|--------|-------|-------------|
| ok | 442 | Container matches YML exactly |
| drift | 58 | Has undeclared transitive deps (harmless — see below) |
| skip | 0 | No Docker image found |
| error | 0 | Container or YML error |

**Version mismatches: 0** (after astropy rebuild — see below)

## Version mismatches (fixed)

Two instances had real version mismatches where the YML was updated but the Docker image hadn't been rebuilt:

| Instance | Package | YML | Container | Fix |
|----------|---------|-----|-----------|-----|
| `astropy__astropy-8707` | pytest | 7.1.2 | 7.4.0 | Rebuilt with `--no-cache` |
| `astropy__astropy-8707` | setuptools | 58.0.0 | 68.0.0 | Rebuilt with `--no-cache` |
| `astropy__astropy-8872` | pytest | 7.1.2 | 7.4.0 | Rebuilt with `--no-cache` |
| `astropy__astropy-8872` | setuptools | 58.0.0 | 68.0.0 | Rebuilt with `--no-cache` |

Both images were rebuilt with `docker build --no-cache` and verified:
- Re-audit shows 0 mismatches
- Gold eval: both `resolved=true`

## Transitive dependencies (harmless drift)

The 58 "drift" instances have **undeclared packages** — packages present in the container but not listed in the environment YML. These are **transitive dependencies** installed by `pip install -e .` (the repo under test's own `setup.py` / `pyproject.toml`).

### Why they're not pinned in the YML

The environment YML pins the **test environment** dependencies (pytest, numpy, coverage, etc.). The project under test is installed separately via `pip install -e .`, which pulls in the project's own dependencies. These are not — and should not be — pinned in the YML because:

1. They're determined by the project's own requirements at the specific git commit
2. They're installed deterministically from the project's pinned setup files
3. The Docker images are pre-built, so they don't drift over time
4. Pinning them would create conflicts with the project's own version constraints

### Examples of transitive deps by repo

| Repo | Undeclared packages | Source |
|------|-------------------|--------|
| xarray | `scitools-iris`, `nc-time-axis`, `pint` | xarray's optional test deps |
| matplotlib | `pyqt5`, `fonttools`, `kiwisolver` | matplotlib's build/runtime deps |
| django | `fastjsonschema`, `asgiref` | Django's core deps |
| scikit-learn | `threadpoolctl`, `joblib` | scikit-learn's runtime deps |
| sympy | `antlr4-python3-runtime`, `mpmath` | sympy's parsing/math deps |

### Why they're not a problem

- They're installed at image build time and frozen in the Docker layer
- They match exactly what the project requires at that commit
- No evaluator ever rebuilds from scratch (pre-built images on DockerHub)
- The audit confirms no **version mismatches** exist for declared deps

## How to run

```bash
# Full audit (parallel, 8 workers, uses cache)
python scripts/audit_pinned_deps.py

# Report from existing cache (no containers needed)
python scripts/audit_pinned_deps.py --report-only

# Audit specific instances
python scripts/audit_pinned_deps.py astropy__astropy-8707 django__django-10087

# Force re-audit (ignore cache)
python scripts/audit_pinned_deps.py --no-cache

# JSON output
python scripts/audit_pinned_deps.py --report-only --json
```
