# Dependency Audit Report — SWE-bench Verified (500 instances)

**Date:** 2026-03-07
**Tool:** `scripts/audit_pinned_deps.py`
**Cache:** `scripts/audit_results.json`

## What the audit does

Compares `pip list --format=freeze` output from each Docker container against the cached environment YML (`data/environments/<owner>/<instance_id>.yml`). Detects:

1. **Undeclared** — package in container but not in YML
2. **Phantom** — package in YML but not in container
3. **Mismatch** — version differs between container and YML

The audit handles conda↔pip name aliases (e.g., `pyqt` in conda = `pyqt5` in pip).

## Results summary

| Status | Count | Description |
|--------|-------|-------------|
| ok | 500 | Container matches YML exactly |
| drift | 0 | — |
| skip | 0 | — |
| error | 0 | — |

**All 500 instances fully pinned. 0 version mismatches. 0 undeclared deps.**

## Issues found and fixed

### 1. Version mismatches — astropy (2 instances)

Two instances had the YML updated but the Docker image not rebuilt:

| Instance | Package | YML | Container (before) | Fix |
|----------|---------|-----|--------------------|-----|
| `astropy__astropy-8707` | pytest | 7.1.2 | 7.4.0 | Rebuilt with `--no-cache` |
| `astropy__astropy-8707` | setuptools | 58.0.0 | 68.0.0 | Rebuilt with `--no-cache` |
| `astropy__astropy-8872` | pytest | 7.1.2 | 7.4.0 | Rebuilt with `--no-cache` |
| `astropy__astropy-8872` | setuptools | 58.0.0 | 68.0.0 | Rebuilt with `--no-cache` |

Both images rebuilt with `docker build --no-cache` and verified via gold eval (both `resolved=true`).

### 2. Undeclared transitive deps — pinned in YMLs (46 instances)

46 instances had packages in the container that weren't declared in the environment YML. These were transitive dependencies installed by `pip install -e .` (the repo under test). Without pinning, these would resolve to different versions on rebuild, breaking reproducibility.

**Packages pinned:**

| Package | Instances | Source |
|---------|-----------|--------|
| `pygments` | 22 (xarray) | Transitive dep of xarray's test suite |
| `fastjsonschema` | 24 (matplotlib) + 12 (xarray) | Transitive dep via jsonschema/jupyter |
| `matplotlib` | 12 (xarray) | xarray optional test dep |
| `scitools-iris` | 12 (xarray) | xarray optional test dep |
| `py` | 2 (astropy) | Legacy pytest dependency |
| `pyqt5` | Initially flagged but already pinned as `pyqt` in conda section (alias) |

### 3. Conda↔pip name aliases — audit script fix (no YML changes needed)

Some packages are installed by conda under one name but reported by pip under another. The audit script now handles these aliases:

| conda name | pip name | Instances |
|-----------|----------|-----------|
| `pyqt` | `pyqt5` | 34 (matplotlib, scikit-learn) |
| `python-fastjsonschema` | `fastjsonschema` | Some xarray instances |
| `antlr-python-runtime` | `antlr4-python3-runtime` | 21 (xarray) |
| `msgpack-python` | `msgpack` | 22 (xarray) |
| `matplotlib-base` | `matplotlib` | Some xarray instances |
| `iris` | `scitools-iris` | Some xarray instances |

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
