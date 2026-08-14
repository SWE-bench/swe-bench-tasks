# Versioning

Attaches a version to each task instance. Install specs are keyed by version, so an
instance without one cannot be built.

This moved out of the SWE-bench harness repo, because it belongs with the task data
rather than with evaluation. It is only used when building a dataset, never when
running one.

## Scope

This works for the original, Python SWE-bench repos only:

- `constants.py` lists, per repository, the file holding the version string and the
  regex to read it from. Adding a repository means adding an entry.
- `extract_web/` holds one hand-written scraper per project, for the six projects
  whose versions are only published on a website.
- The `build` method installs the package with conda and pip, then reads the version
  back. That step assumes a Python project.

SWE-bench Multilingual and Multimodal instances were not versioned with this.

## Use

Run it from `src/`:

```bash
python -m versioning.get_versions --instances_path tasks/scikit-learn-task-instances.jsonl --retrieval_method github
```

Methods are `github` (read the version file at the instance's base commit), `web`
(scrape, see `extract_web/`), `build` (install and ask the package), and `mix`.
`build` and `mix` also need `--testbed`, `--path_conda` and `--conda_env`.
