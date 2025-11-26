#!/usr/bin/env python
"""Zed settings sync tool.

Why do you create this?
=======================
"""
# /// script
# dependencies = [
#     "json-with-comments",
# ]
# ///

import argparse
from pathlib import Path

import jsonc

parser = argparse.ArgumentParser(description="Zed settings sync tool.")
parser.add_argument("--exclude", type=str, default="")
parser.add_argument("source", type=Path, help="Source directory")
parser.add_argument("destination", type=Path, help="Destination directory")


def dump_json_key_path(key, value, indent=2):
    value_lines = jsonc.dumps(value, indent=indent).split("\n")
    dumped_lines = []
    space = " " * indent
    for i, line in enumerate(value_lines):
        new_line: str
        if i == 0:
            new_line = f'{space}"{key}": {line}'
        else:
            new_line = f"{space}{line}"
        if i == len(value_lines) - 1:
            new_line += ","
        dumped_lines.append(new_line)
    return "\n".join(dumped_lines)


def main(args):
    # Parse source.
    exclude_list = args.exclude.split(",")
    source = jsonc.loads(args.source.read_text())
    source = {k: v for k, v in source.items() if k not in exclude_list}
    # Merge to destination.
    lines = args.destination.read_text().split("\n")
    dest = []
    keep_append = True
    for line in lines:
        # Pich json key
        if line.startswith('  "'):
            key = line.split('"')[1]
            if key in source:
                value = source.pop(key)
                dumped_lines = dump_json_key_path(key, value)
                dest += dumped_lines.split("\n")
                keep_append = False
            else:
                dest.append(line)
                keep_append = True
        elif line == "}":
            dest.append(line)
        elif line == "  }" and dest[-1] not in ("  }", "  },"):
            dest.append(line)
        elif keep_append:
            dest.append(line)
    tail = []
    if source:
        for line in reversed(dest):
            tail.append(line)
            dest.pop(-1)
            if line == "}":
                if not dest[-1].endswith(","):
                    dest[-1] += ","
                break
        if not dest[-1].endswith(","):
            dest[-1] += ","
        for idx, key in enumerate(source.keys()):
            dumped_lines = dump_json_key_path(key, source[key])
            dest += dumped_lines.split("\n")
        dest += tail
    tail = []
    for line in reversed(dest):
        tail.append(line)
        dest.pop(-1)
        if line == "}":
            if dest[-1].endswith(","):
                dest[-1] = dest[-1][:-1]
            break
    dest += tail
    args.destination.write_text("\n".join(dest))


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
