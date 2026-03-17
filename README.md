# SWE-bench Dockerfiles

Dockerfile generator for the SWE-bench benchmark. This repo is just for the original SWE-bench benchmark and does not contain any data related to the newer benchmarks we released like SWE-bench Multilingual or SWE-bench Multimodal.

## Usage

```bash
# From HuggingFace dataset
sb-dockerfile-gen-og SWE-bench/SWE-bench_Verified --output_dir src/dockerfiles

# From local JSON/JSONL file
sb-dockerfile-gen-og instances.jsonl --output_dir src/dockerfiles

# Specific instances
sb-dockerfile-gen-og SWE-bench/SWE-bench_Verified --instance_ids django__django-12345 --output_dir src/dockerfiles
```

## Output

Generated Dockerfiles are written to `src/dockerfiles/<instance_id>.Dockerfile`.

## Install

```bash
pip install -e .
```
