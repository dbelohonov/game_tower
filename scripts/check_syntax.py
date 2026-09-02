"""Syntax-check every Lua file in the project via lupa (LuaJIT bindings).

LÖVE 11.x runs on LuaJIT 2.1, so we check against that engine specifically;
it is stricter than the plain Lua 5.5 that lupa defaults to.

Usage:  uv run python scripts/check_syntax.py
Exits non-zero if any file fails to parse.
"""

import sys
from pathlib import Path


def make_runtime():
    """Prefer LuaJIT 2.1 (the engine LÖVE 11.x uses), else fall back."""
    from lupa import LuaRuntime

    try:
        from lupa import luajit21

        return luajit21.LuaRuntime(), "LuaJIT 2.1 (matches LOVE 11.x)"
    except Exception:  # noqa: BLE001 - fall back to the default runtime
        return LuaRuntime(), "default Lua"


def main() -> int:
    try:
        lua, engine = make_runtime()
    except ImportError:
        print("lupa is not installed. Run `uv sync` first.", file=sys.stderr)
        return 1

    print(f"Checking with: {engine}\n")
    root = Path(__file__).resolve().parent.parent
    files = sorted(p for p in root.rglob("*.lua") if ".venv" not in p.parts)
    if not files:
        print("No Lua files found.", file=sys.stderr)
        return 1

    failures = 0
    for path in files:
        rel = path.relative_to(root)
        try:
            lua.compile(path.read_text(encoding="utf-8"))
        except Exception as exc:  # noqa: BLE001 - report any parse failure
            failures += 1
            print(f"FAIL  {rel}: {exc}")
        else:
            print(f"OK    {rel}")

    print(f"\n{len(files) - failures}/{len(files)} files passed the syntax check.")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
