from __future__ import annotations

import argparse
import sys
from io import BytesIO
from pathlib import Path
from subprocess import run
from typing import TYPE_CHECKING

import requests
from pydantic import BaseModel

_HERE = Path(__file__).parent
sys.path.append(str(_HERE))

from _cli import Context
from _settings import load_settings  # noqa: E402

if TYPE_CHECKING:
    from ._settings import DictionarySettings

parser = argparse.ArgumentParser()
parser.add_argument("settings", type=Path)


def fetch_all_dictionaries(settings: DictionarySettings, ctx: Context):
    for source in settings.sources:
        resp = requests.get(source.url)
        filepath = Path(ctx.str_format(source.filepath))
        filepath.parent.mkdir(exist_ok=True, parents=True)
        if source.options.filetype == "gzip":
            import gzip

            fp = gzip.GzipFile(fileobj=BytesIO(resp.content))
            filepath.write_bytes(fp.read())


def make_dictionary(settings: DictionarySettings, ctx: Context):
    output_path = Path(ctx.str_format(settings.output))
    cmd = [
        "yaskkserv2_make_dictionary",
        f"--dictionary-filename={output_path}",
    ] + settings.cli_options + [
        Path(ctx.str_format(source.filepath))
        for source in settings.sources
    ]
    run(cmd)


def main(args: argparse.Namespace):
    settings_toml = Path(args.settings)
    settings = load_settings(settings_toml)
    context = Context(
        root=settings_toml.parent,
    )
    fetch_all_dictionaries(settings.dictionary, context)
    make_dictionary(settings.dictionary, context)


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
