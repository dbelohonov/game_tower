"""Launch the game with LOVE (`love <project root>`).

Usage:  uv run python scripts/run_game.py   (or simply `love .`)
"""

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

CANDIDATES = [
    "/usr/bin/love",
    "/usr/local/bin/love",
    "/opt/homebrew/bin/love",
    "/Applications/love.app/Contents/MacOS/love",
    r"C:\Program Files\LOVE\love.exe",
]


def find_love() -> str | None:
    exe = shutil.which("love")
    if exe:
        return exe
    for path in CANDIDATES:
        if Path(path).exists():
            return path
    return None


def main() -> int:
    love = find_love()
    if not love:
        print(
            "LOVE was not found on this machine.\n"
            "Install it from https://love2d.org (e.g. `sudo apt install love`),\n"
            "then run this script again.",
            file=sys.stderr,
        )
        return 1
    return subprocess.call([love, str(ROOT)])


if __name__ == "__main__":
    raise SystemExit(main())
