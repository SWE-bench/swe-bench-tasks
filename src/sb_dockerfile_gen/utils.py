"""
Inlined utilities from swebench — makes this package fully standalone.
"""

from hashlib import blake2b

from sb_dockerfile_gen.constants import REPO_BASE_COMMIT_BRANCH


def generate_heredoc_delimiter(content: str) -> str:
    delimiter = f"EOF_{blake2b(content.encode()).hexdigest()[:12]}"
    while delimiter in content:
        delimiter = (
            f"EOF_{blake2b(content.encode() + delimiter.encode()).hexdigest()[:12]}"
        )
    return delimiter


def make_heredoc_run_command(commands: list[str]) -> str:
    """Create a heredoc-style RUN command from a list of shell commands."""
    if not commands:
        return ""
    heredoc_content = "\n".join(["#!/bin/bash", "set -euxo pipefail", *commands])
    delimiter = generate_heredoc_delimiter(heredoc_content)
    return f"RUN <<{delimiter}\n{heredoc_content}\n{delimiter}\n"


def git_clone_timesafe(repo: str, base_commit: str, workdir: str) -> list[str]:
    """Generate shell commands to clone a repo and remove references to future information."""
    branch = REPO_BASE_COMMIT_BRANCH.get(repo, {}).get(base_commit, "")
    branch = f"--branch {branch}" if branch else ""
    return [
        f"git clone -o origin {branch} --single-branch https://github.com/{repo} {workdir}",
        f"chmod -R 777 {workdir}",
        f"cd {workdir}",
        f"git reset --hard {base_commit}",
        "git remote remove origin",
        f"TARGET_TIMESTAMP=$(git show -s --format=%ci {base_commit})",
        'git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done',
        "git reflog expire --expire=now --all",
        "git gc --prune=now --aggressive",
        "AFTER_TIMESTAMP=$(date -d \"$TARGET_TIMESTAMP + 1 second\" '+%Y-%m-%d %H:%M:%S')",
        'COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)',
        '[ "$COMMIT_COUNT" -eq 0 ] || exit 1',
        "cd - || true",
    ]


def get_modified_files(patch: str) -> list[str]:
    """Get the list of modified files in a patch."""
    from unidiff import PatchSet

    source_files = [
        f.source_file for f in PatchSet(patch) if f.source_file != "/dev/null"
    ]
    return [x[2:] for x in source_files if x.startswith("a/")]
