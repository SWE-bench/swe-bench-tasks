# SWE-bench task data

Dockerfile generator for the SWE-bench benchmark. This repo is just for the original SWE-bench benchmark and does not contain any data related to the newer benchmarks we released like SWE-bench Multilingual or SWE-bench Multimodal.

## Usage

```bash
# From HuggingFace dataset
dockerfile-gen

# From local JSON/JSONL file
dockerfile-gen

# Specific instances
dockerfile-gen
```

## Output

`Dockerfile` and `eval.sh` are regenerated in place under `tasks/<instance_id>/`, from that task's `task.yaml`.

## ARM64

Tasks with an `environment.arm64.yml` can generate a native ARM64 recipe:

```bash
dockerfile-gen --arch arm64 --instance_ids scikit-learn__scikit-learn-14141
docker build --platform linux/arm64 \
  -f tasks/scikit-learn__scikit-learn-14141/Dockerfile.arm64 \
  -t sweb.eval.arm64.scikit-learn_1776_scikit-learn-14141:latest \
  tasks/scikit-learn__scikit-learn-14141
```

This writes `Dockerfile.arm64`; the default `Dockerfile` and published image name
remain AMD64. The evaluation script is shared. ARM64 environments must be provided
explicitly because the original Conda build pins are architecture-specific.

`scikit-learn__scikit-learn-14141` uses Python 3.7 on ARM64 because its original
Python 3.6 environment is unavailable there. Its task revision and grading tests
are unchanged.

Run the generator tests with `python -m unittest discover -s tests -v`.

## Install

```bash
pip install -e .
```
