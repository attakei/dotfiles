"""Settings definition."""
from __future__ import annotations

import tomllib
from typing import TYPE_CHECKING

from pydantic import BaseModel

if TYPE_CHECKING:
    from pathlib import Path


class SourceOptions(BaseModel):
    filetype: str


class DictionarySourceSettings(BaseModel):
    filepath: str
    url: str
    options: SourceOptions


class DictionarySettings(BaseModel):
    output: str
    cli_options: list[str]
    sources: list[DictionarySourceSettings]


class ServerSettings(BaseModel):
    dict_path: str
    cli_options: list[str]


class Settings(BaseModel):
    server: ServerSettings
    dictionary: DictionarySettings
 

def load_settings(filepath: Path) -> Settings:
    return Settings.model_validate(tomllib.loads(filepath.read_text(encoding="utf8")))
