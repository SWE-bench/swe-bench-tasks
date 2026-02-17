# SWE-bench Dockerfiles (OG Python)

Dockerfile generator for the original SWE-bench Python benchmarks.

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
