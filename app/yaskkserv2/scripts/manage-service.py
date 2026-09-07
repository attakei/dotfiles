from __future__ import annotations

import argparse
import getpass
import sys
from pathlib import Path
from subprocess import PIPE, run
from typing import TYPE_CHECKING

from lxml import etree

sys.path.append(str(Path(__file__).parent))

from _cli import Context  # noqa: D402
from _settings import load_settings  # noqa: E402

if TYPE_CHECKING:
    from ._settings import ServerSettings

TEMPLATE_WINDOWS_TASK = """
<?xml version="1.0" encoding="UTF-16"?>
<Task xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <LogonTrigger>
      <UserId>{username}</UserId>
    </LogonTrigger>
  </Triggers>
  <Actions Context="Author">
    <Exec>
      <Command>{command}</Command>
      <Arguments>{arguments}</Arguments>
    </Exec>
  </Actions>
</Task>
""".strip()

parser = argparse.ArgumentParser()
parser.add_argument("command", type=str)
parser.add_argument("settings", type=Path)
parser.add_argument("--target", type=str, choices=["windows"])


def create_windows_task(settings: ServerSettings, dictionary_path: Path, ctx: Context):
    xml_path = ctx.make_path(settings.windows.taskdef_path)
    username = getpass.getuser()
    command = run("aqua which yaskkserv2", stdout=PIPE).stdout.strip().decode(encoding="utf8")
    arguments = " ".join(settings.cli_options) + f" {dictionary_path}"
    xml_path.write_text(TEMPLATE_WINDOWS_TASK.format(username=username, command=command, arguments=arguments), encoding="utf-16")
    create = [
        "sudo",
        "schtasks",
        "/create",
        "/np",
        "/tn",
        settings.name,
        "/xml",
        str(xml_path.resolve())
    ]
    cmd = run(" ".join(create), stdout=PIPE, stderr=PIPE)


def start_windows_task(settings: ServerSettings, ctx: Context):
    run([
        "schtasks",
        "/run",
        "/tn", 
        settings.name,
    ])


def stop_windows_task(settings: ServerSettings, ctx: Context):
    run([
        "schtasks",
        "/end",
        "/tn", 
        settings.name,
    ])

def delete_windows_task(settings: ServerSettings, ctx: Context):
    run([
        "sudo",
        "schtasks",
        "/delete",
        "/tn", 
        settings.name,
    ])


def main(args: argparse.Namespace):
    settings_toml = Path(args.settings)
    settings = load_settings(settings_toml)
    context = Context(
        root=settings_toml.parent,
    )
    dictionary_path = context.make_path(settings.dictionary.filepath)
    match args.command, args.target:
        case "create", "windows":
            create_windows_task(settings.server, dictionary_path, context)
        case "start", "windows":
            start_windows_task(settings.server, context)
        case "stop", "windows":
            stop_windows_task(settings.server, context)
        case "delete", "windows":
            delete_windows_task(settings.server, context)
        case _, _:
            print("Unknown target!!")

if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
