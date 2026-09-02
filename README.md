# Tower Bloxx

A tribute to the classic Nokia **Tower Bloxx** game, written in **Lua** with the
[**LÖVE**](https://love2d.org) framework.

A block swings on a crane high above your tower. Drop it at the right moment:
the part that overlaps the floor below stays, the overhang is cut away.
Miss three times and the game is over. Perfect drops keep your blocks wide
and build a combo bonus.

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

## Controls

| Input | Action |
|-------|--------|
| `SPACE` / click / tap | drop the swinging block |
| `P` | pause |
| `M` | sound on/off |
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
  states/
    menu.lua             title screen
    game.lua             core gameplay loop
    gameover.lua         results screen
scripts/
  run_game.py            finds and launches `love .`
  check_syntax.py        Lua syntax check via lupa (LuaJIT)
assets/                  reserved for future art / audio / fonts
```

## Roadmap

- [ ] Tower tipping physics when drops are too lopsided
- [ ] Animated construction crew / crane
- [ ] Building themes & city skyline background
- [ ] Combo "streak" visual effects (particles)
- [ ] Mobile packaging (Android/iOS via LÖVE ports)
