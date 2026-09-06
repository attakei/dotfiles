import tomllib
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path
from subprocess import run
from typing import TypedDict

import requests

HERE = Path(__file__).parent
WORK_DIR = HERE / "var"

BASE_DICT_DIR = WORK_DIR / "dict"
OUT_DICT_PATH = WORK_DIR / "dict.yaskkserv2"


class SourceSettings(TypedDict):
    filepath: Path
    url: str
    format: str | None


@dataclass
class Settings:
    sources: list[SourceSettings]



def fetch_all_dictionaries(settings: list[SourceSettings]):
    for source in settings:
        resp = requests.get(source["url"])
        filepath = HERE / source["filepath"]
        filepath.parent.mkdir(exist_ok=True, parents=True)
        if source["format"] == "gzip":
            import gzip

            fp = gzip.GzipFile(fileobj=BytesIO(resp.content))
            filepath.write_bytes(fp.read())


def make_dictionary():
    cmd = [
        "yaskkserv2_make_dictionary",
        "--verbose",
        f"--dictionary-filename={OUT_DICT_PATH}",
    ]
    cmd += [f for f in BASE_DICT_DIR.glob("*")]
    run(cmd)

def main():
    BASE_DICT_DIR.mkdir(exist_ok=True, parents=True)
    settings = Settings(**tomllib.loads((HERE / "settings.toml").read_text(encoding="utf8")))
    fetch_all_dictionaries(settings.sources)
    # make_dictionary()

if __name__ == "__main__":
    main()
