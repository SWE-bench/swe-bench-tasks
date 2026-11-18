"""How a generated eval.sh puts the test patch's files back before grading."""

import pytest

from dockerfile_gen import _get_eval_script
from dockerfile_gen.constants import END_TEST_OUTPUT
from dockerfile_gen.tasks import TASKS_DIR, _read, load_task, task_dirs
from dockerfile_gen.utils import get_modified_files, get_new_files


def reset_lines(script: str) -> tuple[list[str], list[str]]:
    """The reset commands before `git apply` and after the end-of-output marker."""
    lines = script.split("\n")
    apply_at = next(i for i, line in enumerate(lines) if line.startswith("git apply "))
    end_at = next(i for i, line in enumerate(lines) if END_TEST_OUTPUT in line)

    def is_reset(line: str) -> bool:
        return line.startswith(("git checkout ", "rm -f "))

    before = [line for line in lines[:apply_at] if is_reset(line)]
    after = [line for line in lines[end_at:] if is_reset(line)]
    return before, after


def generated(instance_id: str) -> tuple[dict, list[str]]:
    instance = load_task(TASKS_DIR / instance_id)
    before, after = reset_lines(_get_eval_script(instance))
    assert before == after
    return instance, before


def test_patch_that_only_adds_files_is_reset_with_rm():
    _, reset = generated("django__django-16877")
    assert reset == ["rm -f tests/template_tests/filter_tests/test_escapeseq.py"]


def test_added_file_is_not_passed_to_git_checkout():
    instance, reset = generated("django__django-11141")
    assert reset == [
        f"git checkout {instance['base_commit']} tests/migrations/test_loader.py",
        "rm -f tests/migrations/test_migrations_namespace_package/0001_initial.py",
    ]


def test_rename_restores_old_path_and_removes_new_path():
    instance, reset = generated("astropy__astropy-7336")
    assert reset == [
        f"git checkout {instance['base_commit']} "
        "astropy/units/tests/py3_test_quantity_annotations.py "
        "astropy/units/tests/test_quantity_decorator.py",
        "rm -f astropy/units/tests/test_quantity_annotations.py",
    ]


def test_patch_that_only_modifies_files_is_reset_with_checkout():
    instance, reset = generated("astropy__astropy-12907")
    assert get_new_files(instance["test_patch"]) == []
    assert reset == [
        f"git checkout {instance['base_commit']} "
        + " ".join(get_modified_files(instance["test_patch"]))
    ]


@pytest.mark.parametrize("task_dir", task_dirs(), ids=lambda d: d.name)
def test_committed_eval_script_resets_every_test_patch_file(task_dir):
    """A file the test patch creates is removed before `git apply`, never checked out."""
    test_patch = _read(task_dir / "test.patch")
    before, after = reset_lines(_read(task_dir / "eval.sh"))
    assert before == after
    checked_out, removed = [], []
    for line in before:
        if line.startswith("git checkout "):
            checked_out += line.split(" ")[3:]
        else:
            removed += line.split(" ")[2:]
    assert checked_out == get_modified_files(test_patch)
    assert removed == get_new_files(test_patch)
