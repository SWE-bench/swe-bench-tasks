import shutil
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from dockerfile_gen import _get_dockerfile, regenerate
from dockerfile_gen.tasks import REPO_ROOT, load_task


INSTANCE_ID = "scikit-learn__scikit-learn-14141"
TASK_DIR = REPO_ROOT / "tasks" / INSTANCE_ID


class ArchitectureTests(unittest.TestCase):
    def test_default_dockerfile_preserves_amd64_recipe(self):
        self.assertEqual(
            _get_dockerfile(load_task(TASK_DIR)),
            (TASK_DIR / "Dockerfile").read_text(),
        )

    def test_arm64_generation_preserves_existing_task_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            task_dir = Path(tmp) / INSTANCE_ID
            shutil.copytree(TASK_DIR, task_dir)
            original = {
                name: (task_dir / name).read_bytes()
                for name in ("Dockerfile", "eval.sh", "task.yaml")
            }
            with (
                patch("dockerfile_gen.tasks.TASKS_DIR", Path(tmp)),
                patch("dockerfile_gen.tasks.task_dirs", return_value=[task_dir]),
            ):
                self.assertEqual(regenerate([INSTANCE_ID], arch="arm64"), 1)
            dockerfile = (task_dir / "Dockerfile.arm64").read_text()
            self.assertIn("FROM --platform=linux/arm64 ubuntu:jammy", dockerfile)
            self.assertIn("Linux-aarch64.sh", dockerfile)
            self.assertIn((task_dir / "environment.arm64.yml").read_text(), dockerfile)
            self.assertNotIn("Linux-x86_64", dockerfile)
            for name, contents in original.items():
                self.assertEqual((task_dir / name).read_bytes(), contents, name)

    def test_arm64_requires_an_explicit_environment(self):
        with tempfile.TemporaryDirectory() as tmp:
            task_dir = Path(tmp) / INSTANCE_ID
            shutil.copytree(TASK_DIR, task_dir)
            (task_dir / "environment.arm64.yml").unlink(missing_ok=True)
            with patch("dockerfile_gen.tasks.TASKS_DIR", Path(tmp)):
                with self.assertRaisesRegex(ValueError, "environment.arm64.yml"):
                    _get_dockerfile(load_task(task_dir), arch="arm64")


if __name__ == "__main__":
    unittest.main()
