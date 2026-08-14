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
        # Fall back to a full clone when the mapped branch no longer exists upstream
        # (sympy deleted its 1.7 branch, which made the clone exit 128 and the whole
        # image build fail). The base commit is still reachable either way.
        f"git clone -o origin {branch} --single-branch https://github.com/{repo} {workdir} "
        f"|| git clone -o origin https://github.com/{repo} {workdir}"
        if branch
        else f"git clone -o origin --single-branch https://github.com/{repo} {workdir}",
        f"cd {workdir}",
        f"git reset --hard {base_commit}",
        "git remote remove origin",
        f"TARGET_TIMESTAMP=$(git show -s --format=%ci {base_commit})",
        f"TARGET_EPOCH=$(git show -s --format=%ct {base_commit})",
        # Delete refs newer than the base commit. Deleting *all* tags instead is
        # simpler but breaks version derivation: setuptools_scm falls back to
        # 0.1.dev..., which trips pytest's own `minversion` gate so no tests run.
        # Use a for-loop, not `git tag -l | while read`: a git command in the loop
        # body consumes the piped stdin, so that form silently stopped early.
        'for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done',
        "git branch | grep -v '^\\*' | xargs -r git branch -D || true",
        "git reflog expire --expire=now --all",
        "git gc --prune=now --aggressive",
        "AFTER_TIMESTAMP=$(date -d \"$TARGET_TIMESTAMP + 1 second\" '+%Y-%m-%d %H:%M:%S')",
        'COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)',
        '[ "$COMMIT_COUNT" -eq 0 ] || exit 1',
        # chmod last: `git reset --hard` above re-creates working-tree files as
        # root-owned 0644, so chmod'ing before it left committed lockfiles
        # unwritable by a non-root install user.
        f"chmod -R 777 {workdir}",
        "cd - || true",
    ]


def get_modified_files(patch: str) -> list[str]:
    """Get the list of modified files in a patch."""
    from unidiff import PatchSet

    source_files = [
        f.source_file for f in PatchSet(patch) if f.source_file != "/dev/null"
    ]
    return [x[2:] for x in source_files if x.startswith("a/")]
