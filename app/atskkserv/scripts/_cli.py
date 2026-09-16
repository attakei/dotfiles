from pathlib import Path

from pydantic import BaseModel



class Context(BaseModel):
    root: Path

    def str_format(self, text: str) -> str:
        return text.format(**self.model_dump())

    def make_path(self, text: str) -> Path:
        return Path(self.str_format(text)).resolve()
