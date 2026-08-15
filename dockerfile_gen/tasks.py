"""Reading and writing the tasks/ tree, which is the source of truth."""

import json
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
TASKS_DIR = REPO_ROOT / "tasks"

# columns kept as their own file rather than inside task.json
AS_FILE = {
    "patch": "gold.patch",
    "test_patch": "test.patch",
    "eval_script": "eval.sh",
    "problem_statement": "problem_statement.md",
}


def _read(path: Path) -> str:
    # newline="" so CRLF inside a patch survives verbatim
    with open(path, newline="") as fh:
        return fh.read()


def _write(path: Path, text: str) -> None:
    with open(path, "w", newline="") as fh:
        fh.write(text)


def task_dirs(tasks_dir: Path = TASKS_DIR) -> list[Path]:
    return sorted(d for d in tasks_dir.iterdir() if (d / "task.yaml").exists())


def load_task(task_dir: Path) -> dict:
    """A task directory, as the instance dict the generators expect."""
    instance = yaml.safe_load((task_dir / "task.yaml").read_text())
    for column, filename in AS_FILE.items():
        instance[column] = _read(task_dir / filename)
    hints = task_dir / "hints.md"
    instance["hints_text"] = _read(hints) if hints.is_file() else ""
    instance.update(json.loads((task_dir / "tests.json").read_text()))
    return instance


def write_generated(task_dir: Path, dockerfile: str, eval_script: str) -> None:
    """Overwrite the two derived files in place."""
    _write(task_dir / "Dockerfile", dockerfile)
    _write(task_dir / "eval.sh", eval_script)
