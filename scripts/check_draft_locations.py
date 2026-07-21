#!/usr/bin/env python3
"""
Pre-commit check: ensures draft posts live in drafts/ and published
posts live in content/posts/ — never the other way around.

A file is considered a "draft" if its frontmatter contains `draft: true`.
"""

import re
import sys
from pathlib import Path

POSTS_DIR = Path("content/posts")
DRAFTS_DIR = Path("drafts")

FRONTMATTER_RE = re.compile(r"^(?:---\n(.*?)\n---|(\+\+\+\n.*?\n\+\+\+))", re.DOTALL)
DRAFT_TRUE_RE = re.compile(r"^\s*draft\s*[:=]\s*true\s*$", re.IGNORECASE | re.MULTILINE)


def is_draft(path: Path) -> bool:
    try:
        text = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return False

    match = FRONTMATTER_RE.match(text)
    if not match:
        return False

    frontmatter = match.group(1) or match.group(2) or ""
    return bool(DRAFT_TRUE_RE.search(frontmatter))


def find_md_files(directory: Path):
    if not directory.exists():
        return []
    return list(directory.rglob("*.md"))


def main() -> int:
    errors = []

    for path in find_md_files(POSTS_DIR):
        if is_draft(path):
            errors.append(
                f"  {path} — marked draft:true but lives in {POSTS_DIR}/ "
                f"(move it to {DRAFTS_DIR}/)"
            )

    for path in find_md_files(DRAFTS_DIR):
        if not is_draft(path):
            errors.append(
                f"  {path} — not marked draft:true but lives in {DRAFTS_DIR}/ "
                f"(move it to {POSTS_DIR}/, or add draft: true)"
            )

    if errors:
        print("Draft/post placement check failed:\n")
        print("\n".join(errors))
        print()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
