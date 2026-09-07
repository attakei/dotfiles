from __future__ import annotations

import argparse
import getpass
import sys
from pathlib import Path
from subprocess import PIPE, run

from pydantic import BaseModel

sys.path.append(str(Path(__file__).parent))

from _cli import Context  # noqa: D402
from _settings import ServerSettings, load_settings  # noqa: E402

TEMPLATE_TASKDEF = """
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


class Task(BaseModel):
    settings: ServerSettings
    ctx: Context
    
    def _schtasks(self, command: str, arguments: list[str] | None = None, *, sudo: bool = False):
        cmd = ["schtasks", command, "/tn", self.settings.name]
        if arguments:
            cmd += arguments
        if sudo:
            cmd = ["sudo"] + cmd
        run(cmd)

    def create(self, dictionary_path: Path):
        xml_path = self.ctx.make_path(self.settings.windows.taskdef_path)
        username = getpass.getuser()
        command = run("aqua which yaskkserv2", stdout=PIPE).stdout.strip().decode(encoding="utf8")
        arguments = " ".join(self.settings.cli_options) + f" {dictionary_path}"
        xml_path.write_text(TEMPLATE_TASKDEF.format(username=username, command=command, arguments=arguments), encoding="utf-16")
        self._schtasks("/create", ["/np", "/xml", str(xml_path)], sudo=True)

    def delete(self):
        self._schtasks("/delete", sudo=True)

    def start(self):
        self._schtasks("/run")

    def stop(self):
        self._schtasks("/end")


def main(args: argparse.Namespace):
    settings_toml = Path(args.settings)
    settings = load_settings(settings_toml)
    context = Context(
        root=settings_toml.parent,
    )
    task = Task(settings=settings.server, ctx=context)
    match args.command:
        case "create":
            dictionary_path = context.make_path(settings.dictionary.filepath)
            task.create(dictionary_path)
        case "delete":
            task.delete()
        case "start":
            task.start()
        case "stop":
            task.stop()
        case _, _:
            print("Unknown target!!")

if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
