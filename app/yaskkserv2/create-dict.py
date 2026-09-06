from subprocess import run
from pathlib import Path

HERE = Path(__file__).parent
WORK_DIR = HERE / "var"

BASE_DICT_DIR = WORK_DIR / "dict"
OUT_DICT_PATH = WORK_DIR / "dict.yaskkserv2"


def main():
    BASE_DICT_DIR.parent.mkdir(exist_ok=True, parents=True)
    cmd = [
        "yaskkserv2_make_dictionary",
        "--verbose",
        f"--dictionary-filename={OUT_DICT_PATH}",
    ]
    cmd += [f for f in BASE_DICT_DIR.glob("*")]
    run(cmd)


if __name__ == "__main__":
    main()
