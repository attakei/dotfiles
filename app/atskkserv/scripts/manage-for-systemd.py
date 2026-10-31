from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path
from subprocess import PIPE, run

from pydantic import BaseModel

sys.path.append(str(Path(__file__).parent))

from _cli import Context  # noqa: E402
from _settings import ServerSettings, load_settings  # noqa: E402

# ExecStart requires absolute paths, so this unit is generated from settings.toml
# on every `create` instead of being kept in the repository.
TEMPLATE_UNIT = """
[Unit]
Description=atskkserv (SKK dictionary server)
After=network.target

[Service]
Type=simple
ExecStart={command_line}
Restart=on-failure

[Install]
WantedBy=default.target
""".lstrip()

parser = argparse.ArgumentParser()
parser.add_argument("command", type=str)
parser.add_argument("settings", type=Path)


def _quote(arg: str) -> str:
    """Quote an argument for systemd's ExecStart if it needs it."""
    if any(c.isspace() for c in arg) or '"' in arg:
        return '"' + arg.replace("\\", "\\\\").replace('"', '\\"') + '"'
    return arg


class Task(BaseModel):
    settings: ServerSettings
    ctx: Context

    @property
    def unit_name(self) -> str:
        return f"{self.settings.name}.service"

    @property
    def unit_path(self) -> Path:
        return self.ctx.make_path(self.settings.systemd.unit_path)

    def _systemctl(self, *arguments: str):
        run(["systemctl", "--user", *arguments])

    def _server_command(self) -> str:
        # Use the real binary rather than the aqua shim; the shim depends on
        # aqua's environment variables, which systemd's user manager may lack.
        proc = run(["aqua", "which", "atskkserv"], stdout=PIPE, check=True)
        return proc.stdout.strip().decode(encoding="utf8")

    def create(self):
        arguments = [self._server_command()] + [
            self.ctx.str_format(o) for o in self.settings.cli_options
        ]
        command_line = " ".join(_quote(a) for a in arguments)
        self.unit_path.parent.mkdir(parents=True, exist_ok=True)
        self.unit_path.write_text(TEMPLATE_UNIT.format(command_line=command_line), encoding="utf-8")
        self._systemctl("link", str(self.unit_path))
        self._systemctl("daemon-reload")
        self._systemctl("enable", self.unit_name)

    def delete(self):
        self._systemctl("disable", self.unit_name)
        # `disable` normally removes the symlink created by `link`, but make sure.
        config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
        linked = config_home / "systemd" / "user" / self.unit_name
        if linked.is_symlink():
            linked.unlink()
        self._systemctl("daemon-reload")

    def start(self):
        self._systemctl("start", self.unit_name)

    def stop(self):
        self._systemctl("stop", self.unit_name)

    def status(self):
        self._systemctl("status", "--no-pager", self.unit_name)


def main(args: argparse.Namespace):
    settings_toml = Path(args.settings)
    settings = load_settings(settings_toml)
    context = Context(
        root=settings_toml.parent.resolve(),
    )
    task = Task(settings=settings.server, ctx=context)
    match args.command:
        case "create":
            task.create()
        case "delete":
            task.delete()
        case "start":
            task.start()
        case "stop":
            task.stop()
        case "status":
            task.status()
        case _:
            print("Unknown target!!")
            sys.exit(1)


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
