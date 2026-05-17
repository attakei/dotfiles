#!/usr/bin/env python3
"""Generate .gitignore files from github/gitignore templates."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


MARKER = "## FROM https://github.com/github/gitignore"
SOURCE_URL = "https://github.com/github/gitignore"
REPO_PATH = Path.home() / "ghq" / "github.com" / "github" / "gitignore"


def normalize_lf(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def source_sort_key(source: str) -> tuple[object, ...]:
    """Sort plain names first, then slash-separated groups recursively."""
    if "/" not in source:
        return (0, source.casefold(), source)
    head, tail = source.split("/", 1)
    return (1, head.casefold(), head, source_sort_key(tail))


def run_git(args: list[str], cwd: Path | None = None) -> None:
    try:
        subprocess.run(["git", *args], cwd=cwd, check=True)
    except FileNotFoundError:
        print("git command is not available.", file=sys.stderr)
        raise SystemExit(1)
    except subprocess.CalledProcessError as err:
        command = " ".join(["git", *args])
        print(f"Failed to run `{command}`.", file=sys.stderr)
        raise SystemExit(err.returncode)


def prepare_repo(repo_path: Path) -> None:
    if not repo_path.exists():
        repo_path.parent.mkdir(parents=True, exist_ok=True)
        run_git(["clone", SOURCE_URL, str(repo_path)])

    if not repo_path.is_dir():
        print(f"Material repository path is not a directory: {repo_path}", file=sys.stderr)
        raise SystemExit(1)

    run_git(["fetch"], cwd=repo_path)


def read_prologue(output: Path) -> str:
    if not output.exists():
        return ""

    content = normalize_lf(output.read_text(encoding="utf-8"))
    lines = content.splitlines(keepends=True)
    for index, line in enumerate(lines):
        if line.rstrip("\r\n") == MARKER:
            return "".join(lines[:index]).rstrip()
    return content.rstrip()


def resolve_sources(repo_path: Path, sources: list[str]) -> list[tuple[str, str]]:
    missing: list[str] = []
    resolved: list[tuple[str, Path]] = []

    for source in sources:
        source_path = repo_path / f"{source}.gitignore"
        if source_path.is_file():
            resolved.append((source, source_path))
        else:
            missing.append(source)

    if missing:
        for source in missing:
            print(f"Source not found: {source}", file=sys.stderr)
        raise SystemExit(1)

    return [
        (source, normalize_lf(source_path.read_text(encoding="utf-8")).rstrip())
        for source, source_path in resolved
    ]


def render(prologue: str, sources: list[str], source_contents: list[tuple[str, str]]) -> str:
    parts: list[str] = []
    if prologue:
        parts.extend([prologue, ""])

    parts.extend(
        [
            MARKER,
            f"## sources: {' '.join(sources)}",
            "",
        ]
    )
    parts.extend(content for _, content in source_contents)
    return "\n".join(parts).rstrip() + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate a .gitignore file from github/gitignore templates."
    )
    parser.add_argument("output", type=Path, help="Path to write generated .gitignore.")
    parser.add_argument(
        "sources",
        nargs="+",
        help="Template names in github/gitignore without the .gitignore suffix.",
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="Overwrite output when it already exists.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    output = args.output

    if output.exists() and not args.force:
        print(f"Output already exists: {output}", file=sys.stderr)
        print("Use --force to overwrite it.", file=sys.stderr)
        return 1

    prepare_repo(REPO_PATH)

    sources = sorted(args.sources, key=source_sort_key)
    source_contents = resolve_sources(REPO_PATH, sources)
    prologue = read_prologue(output)

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        render(prologue, sources, source_contents),
        encoding="utf-8",
        newline="\n",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
