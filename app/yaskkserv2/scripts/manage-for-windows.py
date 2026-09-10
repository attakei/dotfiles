from __future__ import annotations

import argparse
import getpass
import os
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
  <Principals>
    <Principal id="Author">
      <UserId>{username}</UserId>
      <LogonType>InteractiveToken</LogonType>
    </Principal>
  </Principals>
  <Settings>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>{wscript}</Command>
      <Arguments>"{launcher}"</Arguments>
    </Exec>
  </Actions>
</Task>
""".strip()

# Runs the real command with a hidden window (0 = SW_HIDE) so no console flashes
# up under a LogonTrigger/InteractiveToken task, which needs no special logon
# rights (unlike Password/S4U, which require "Log on as a batch job").
TEMPLATE_LAUNCHER_VBS = """
Set objShell = CreateObject("WScript.Shell")
objShell.Run "{command_line}", 0, False
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
        launcher_path = xml_path.with_name("run-hidden.vbs")
        username = getpass.getuser()
        command = run("aqua which yaskkserv2", stdout=PIPE).stdout.strip().decode(encoding="utf8")
        arguments = " ".join(self.settings.cli_options) + f" {dictionary_path}"
        command_line = f'"{command}" {arguments}'.replace('"', '""')
        launcher_path.write_text(TEMPLATE_LAUNCHER_VBS.format(command_line=command_line), encoding="utf-8")
        wscript = str(Path(os.environ["WINDIR"]) / "System32" / "wscript.exe")
        xml_path.write_text(
            TEMPLATE_TASKDEF.format(username=username, wscript=wscript, launcher=launcher_path),
            encoding="utf-16",
        )
        self._schtasks("/create", ["/xml", str(xml_path)])

    def delete(self):
        self._schtasks("/delete", ["/f"])

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
