"""Package Tower Bloxx as a standalone Windows program (.exe).

How it works: LOVE supports "fusing" a game with its runtime. When a
`game.love` archive is appended to the end of `love.exe`, the resulting
binary launches the game directly - no LOVE installation needed on the
target machine. This script:

  1. fetches the official LOVE Windows runtime (downloaded once, cached
     under vendor/)
  2. zips the game source files into game.love
  3. fuses both into TowerBloxx.exe
  4. bundles the runtime DLLs + licenses into dist/TowerBloxx-win64/
  5. creates the distributable dist/TowerBloxx-<version>-win64.zip

Usage:
  uv run python scripts/build_exe.py
  uv run python scripts/build_exe.py --love-zip path/to/love-11.5-win64.zip
                                     (use an already-downloaded runtime,
                                      e.g. when building offline)

Installing the result: unzip dist/TowerBloxx-<version>-win64.zip anywhere
(e.g. C:\\Games) and run TowerBloxx.exe.
"""

import argparse
import re
import shutil
import sys
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"
DIST = ROOT / "dist"
VENDOR = ROOT / "vendor"

LOVE_VERSION = "11.5"
LOVE_WIN64_URL = (
    f"https://github.com/love2d/love/releases/download/"
    f"{LOVE_VERSION}/love-{LOVE_VERSION}-win64.zip"
)
RUNTIME_DIRNAME = f"love-{LOVE_VERSION}-win64"
EXE_NAME = "TowerBloxx.exe"

# Game files that go into game.love (everything else is dev tooling).
GAME_FILES = ["main.lua", "conf.lua"]
GAME_DIRS = ["src", "assets"]
EXCLUDE_NAMES = {".gitkeep", "__pycache__"}
EXCLUDE_SUFFIXES = {".pyc"}


def read_version() -> str:
    text = (ROOT / "pyproject.toml").read_text(encoding="utf-8")
    match = re.search(r'^version\s*=\s*"([^"]+)"', text, re.MULTILINE)
    return match.group(1) if match else "0.0.0"


def download(url: str, dest: Path) -> None:
    print(f"  downloading {url}")
    tmp = dest.with_suffix(dest.suffix + ".part")
    with urllib.request.urlopen(url) as response, open(tmp, "wb") as out:
        total = int(response.headers.get("Content-Length") or 0)
        done = 0
        while True:
            chunk = response.read(1 << 20)
            if not chunk:
                break
            out.write(chunk)
            done += len(chunk)
            if total:
                print(f"\r  {done / 1e6:6.1f} / {total / 1e6:.1f} MB", end="", flush=True)
    print()
    tmp.rename(dest)


def get_runtime(local_zip: str | None) -> Path:
    """Return a directory containing love.exe + the Windows DLLs."""
    runtime = VENDOR / RUNTIME_DIRNAME
    if (runtime / "love.exe").exists():
        print(f"  using cached LOVE runtime: {runtime}")
        return runtime

    zip_path = Path(local_zip) if local_zip else VENDOR / f"{RUNTIME_DIRNAME}.zip"
    if local_zip and not zip_path.exists():
        sys.exit(f"error: --love-zip file not found: {zip_path}")

    if not zip_path.exists():
        VENDOR.mkdir(parents=True, exist_ok=True)
        download(LOVE_WIN64_URL, zip_path)

    print(f"  extracting {zip_path.name}")
    with zipfile.ZipFile(zip_path) as archive:
        archive.extractall(VENDOR)

    if not (runtime / "love.exe").exists():
        # Be lenient about the folder layout inside the zip.
        hits = list(VENDOR.glob("**/love.exe"))
        if not hits:
            sys.exit("error: love.exe not found after extracting the runtime")
        runtime = hits[0].parent
    return runtime


def build_game_love() -> Path:
    """Zip the game source into build/game.love."""
    BUILD.mkdir(parents=True, exist_ok=True)
    love_zip = BUILD / "game.love"

    entries: list[Path] = []
    for name in GAME_FILES:
        path = ROOT / name
        if path.exists():
            entries.append(path)
    for name in GAME_DIRS:
        base = ROOT / name
        if base.is_dir():
            entries.extend(
                p for p in sorted(base.rglob("*"))
                if p.is_file()
                and p.name not in EXCLUDE_NAMES
                and p.suffix not in EXCLUDE_SUFFIXES
            )

    with zipfile.ZipFile(love_zip, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in entries:
            archive.write(path, path.relative_to(ROOT).as_posix())
    print(f"  packed {len(entries)} files into {love_zip.relative_to(ROOT)}")
    return love_zip


def fuse(runtime: Path, game_love: Path, out_dir: Path) -> Path:
    """Copy the runtime next to a fused TowerBloxx.exe."""
    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True)

    for item in sorted(runtime.iterdir()):
        if item.name.lower() == "love.exe":
            continue  # replaced by the fused executable
        if item.is_file():
            shutil.copy2(item, out_dir / item.name)

    exe = out_dir / EXE_NAME
    with open(runtime / "love.exe", "rb") as src, \
            open(game_love, "rb") as game, \
            open(exe, "wb") as out:
        shutil.copyfileobj(src, out)
        shutil.copyfileobj(game, out)

    print(f"  fused {exe.relative_to(ROOT)} ({exe.stat().st_size / 1e6:.1f} MB)")
    return exe


def make_zip(folder: Path, zip_path: Path) -> None:
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as archive:
        for item in sorted(folder.rglob("*")):
            if item.is_file():
                archive.write(item, item.relative_to(folder.parent))
    print(f"  created {zip_path.relative_to(ROOT)} ({zip_path.stat().st_size / 1e6:.1f} MB)")


def main() -> int:
    parser = argparse.ArgumentParser(description="Build the Windows .exe of Tower Bloxx")
    parser.add_argument(
        "--love-zip",
        help="path to an already-downloaded love-11.5-win64.zip (skip the download)",
    )
    args = parser.parse_args()

    version = read_version()
    print(f"Building Tower Bloxx {version} for Windows (64-bit)")

    print("[1/4] LOVE runtime")
    runtime = get_runtime(args.love_zip)

    print("[2/4] game.love")
    game_love = build_game_love()

    print("[3/4] fuse executable")
    out_dir = DIST / "TowerBloxx-win64"
    fuse(runtime, game_love, out_dir)

    print("[4/4] distributable zip")
    zip_path = DIST / f"TowerBloxx-{version}-win64.zip"
    make_zip(out_dir, zip_path)

    print()
    print("Done! Install it by unzipping and running TowerBloxx.exe:")
    print(f"  {zip_path}")
    print(f"  {out_dir / EXE_NAME}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
