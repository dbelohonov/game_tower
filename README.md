# Tower Bloxx

A tribute to the classic Nokia **Tower Bloxx** game, written in **Lua** with the
[**LÖVE**](https://love2d.org) framework.

A block swings on a crane high above your tower. Drop it at the right moment:
the part that overlaps the floor below stays, the overhang is cut away.
Miss three times and the game is over. Perfect drops keep your blocks wide
and build a combo bonus.

The menu and UI are localized into **English, Russian, German, French and
Slovak** (switched from the title screen).

## Requirements

| Tool | Why | Install |
|------|-----|---------|
| [LÖVE](https://love2d.org) 11.4+ | runs the game | `sudo apt install love` / [love2d.org](https://love2d.org) |
| [uv](https://docs.astral.sh/uv) | manages the dev environment & helper scripts | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |

## Getting started

```bash
uv sync                              # create .venv and install dev tooling
uv run python scripts/run_game.py    # launch the game (finds `love` for you)
```

You can also bypass uv and run the game directly — LÖVE only needs the project
directory:

```bash
love .
```

## Install as a Windows program (.exe)

The game can be packaged into a standalone Windows executable — no LÖVE
installation needed on the target machine:

```bash
uv run python scripts/build_exe.py
```

The first run downloads the official LÖVE 11.5 Windows runtime (cached in
`vendor/`), fuses it with the game source and produces:

| Artifact | What it is |
|----------|------------|
| 📦 [**`dist/TowerBloxx-0.1.0-win64.zip`**](dist/TowerBloxx-0.1.0-win64.zip) | distributable package — **install this** |
| `dist/TowerBloxx-win64/TowerBloxx.exe` | the game as a single program |

To install: unzip the package anywhere (e.g. `C:\Games\TowerBloxx`) and run
`TowerBloxx.exe`. Your best score is kept in `%APPDATA%\LOVE\tower-bloxx`.

> Building offline? Put a copy of
> [love-11.5-win64.zip](https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip)
> next to you and pass it explicitly:
> `uv run python scripts/build_exe.py --love-zip /path/to/love-11.5-win64.zip`

## Play in the browser (web build)

The game also runs in any modern browser via
[love.js](https://github.com/Davidobot/love.js) (LÖVE compiled to
WebAssembly). One command builds everything into `web/`:

```bash
uv run python scripts/build_web.py
python3 -m http.server -d web 8000   # then open http://localhost:8000
```

`web/` is a plain static site (~5.8 MB, mostly the WASM runtime + fonts) —
upload it to GitHub Pages, itch.io, nginx, anything. The build uses love.js
**compatibility mode** (no `SharedArrayBuffer`), so no COOP/COEP response
headers are needed. Best score and language choice persist between visits
via IndexedDB; the build script patches love.js to sync the emulated save
directory back to the browser.

## Controls

| Input | Action |
|-------|--------|
| `SPACE` / click / tap | drop the swinging block |
| `P` | pause |
| `M` | sound on/off |
| `LEFT` / `RIGHT` or clicking a button | change menu language (EN / RU / DE / FR / SK) |
| `ESC` | back to menu / quit from menu |

## Gameplay rules

- Each floor keeps only the overlap with the floor beneath it — precision matters.
- Overlaps thinner than 20 px crumble and cost a life.
- A drop within 7 px of the edge below is **PERFECT**: it snaps into place,
  restores a little width and grows a score combo.
- The crane swings faster the taller the tower gets.
- 3 lives. Best height is saved between sessions.

## Development helpers (uv)

```bash
uv sync                              # install/refresh dev dependencies
uv run python scripts/check_syntax.py  # parse-check all .lua files
uv run python scripts/run_game.py      # launch the game
uv run python scripts/build_exe.py     # package the Windows .exe (see above)
```

## Project layout

```
conf.lua                 LOVE window/module configuration
main.lua                 entry point: LOVE callbacks -> scene manager
src/
  config.lua             all gameplay tuning constants
  scene_manager.lua      tiny scene/state manager
  screen.lua             letterboxing onto a fixed 480x800 canvas
  camera.lua             vertical camera that follows the tower (+ shake)
  tower.lua              the stack of placed blocks (+ cosmetic sway)
  crane.lua              swinging crane / falling block state machine
  blocks.lua             shared block renderer (palette, windows)
  background.lua         sky gradient, sun, clouds, stars (parallax)
  hud.lua                floors, score, lives, hints
  sfx.lua                sound effects synthesized at runtime (no assets)
  save.lua               best-score persistence (love.filesystem)
  i18n.lua               localization (EN/RU/DE/FR/SK), plural rules, fonts
  states/
    menu.lua             title screen + language selector
    game.lua             core gameplay loop
    gameover.lua         results screen
scripts/
  run_game.py            finds and launches `love .`
  check_syntax.py        Lua syntax check via lupa (LuaJIT)
  build_exe.py           packages the Windows .exe (fuses LÖVE + game)
  build_web.py           packages the browser build (love.js/WASM -> web/)
assets/
  fonts/DejaVuSans.ttf   Unicode UI font (Latin + Cyrillic)
  fonts/LICENSE-DejaVu.txt  its license (must ship with the game)
```

## Roadmap

- [ ] Tower tipping physics when drops are too lopsided
- [ ] Animated construction crew / crane
- [ ] Building themes & city skyline background
- [ ] Combo "streak" visual effects (particles)
- [ ] Mobile packaging (Android/iOS via LÖVE ports)
