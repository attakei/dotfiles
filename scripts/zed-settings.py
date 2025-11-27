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
parser.add_argument("source", type=Path, help="Source path")
parser.add_argument("destination", type=Path, help="Destination path")


def merge_dict_recursive(src: dict, dst: dict, excludes: list[str] | None = None) -> dict:
    out = {}
    excludes = excludes or []
    src_keys = set(src.keys())
    dst_keys = set(dst.keys())
    for key in excludes:
        if key in dst:
            out[key] = dst[key]
    for key in dst_keys - src_keys:
        if key in excludes:
            continue
        out[key] = dst[key]
    for key in src_keys - dst_keys:
        if key in excludes:
            continue
        out[key] = src[key]
    for key in (src_keys & dst_keys):
        if key in excludes:
            continue
        if isinstance(dst[key], list):
            out[key] = list(set(src[key] + dst[key]))
        elif isinstance(dst[key], dict):
            out[key] = merge_dict_recursive(src[key], dst[key])
        else:
            out[key] = src[key]
    return dict(sorted(out.items()))


def main(args):
    exclude_list = args.exclude.split(",")
    src = jsonc.loads(args.source.read_text(encoding="utf-8"))
    dest = jsonc.loads(args.destination.read_text(encoding="utf-8"))
    out = merge_dict_recursive(src, dest, exclude_list)
    args.destination.write_text(jsonc.dumps(out, indent=2), encoding="utf-8")


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
