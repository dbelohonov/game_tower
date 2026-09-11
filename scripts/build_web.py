"""Build the browser version of the game with love.js.

love.js (Davidobot) is an Emscripten port of LOVE 11.x: it transpiles a
game.love archive into a folder of WASM + JS that any static host can
serve (GitHub Pages, itch.io, nginx, ...).

Pipeline:

  1. zip the game sources into build/game.love (same file list as build_exe.py)
  2. run `npx love.js` in compatibility mode (-c): no SharedArrayBuffer,
     so the page works without COOP/COEP headers on any static host
  3. patch web/love.js so the emulated save directory (IDBFS) is synced
     back to IndexedDB - by default love.js only POPULATES it at boot,
     which would lose best scores / language choice on every reload
  4. replace the generated index.html + theme with a themed page
     (centered canvas, dark background, favicon, no debug footer)

Usage:
    uv run python scripts/build_web.py
    then serve: python3 -m http.server -d web 8000
"""

import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"
WEB = ROOT / "web"

# Game files that go into game.love (everything else is dev tooling).
GAME_FILES = ["main.lua", "conf.lua"]
GAME_DIRS = ["src", "assets"]
EXCLUDE_NAMES = {".gitkeep", "__pycache__"}
EXCLUDE_SUFFIXES = {".pyc"}

# Compatibility mode needs no SharedArrayBuffer; the heap is baked into
# the wasm at build time and 16 MB (the default) is too small.
MEMORY_BYTES = 67108864  # 64 MB
TITLE = "Tower Bloxx"

# love.js mounts the save dir on IDBFS and populates it once at boot
# (FS.syncfs(true, ...)).  Without a reverse sync everything written by
# the game dies with the page.  Hook a periodic + on-hide sync onto that
# one call site (same scope, so FS is reachable there).
SYNCFS_ANCHOR = (
    'FS.syncfs(true,function(err){if(err){Module["printErr"](err)}'
    'else{Module.removeRunDependency("IDBFS_sync")}})'
)
SYNCFS_PATCH = (
    'FS.syncfs(true,function(err){if(err){Module["printErr"](err)}'
    'else{Module.removeRunDependency("IDBFS_sync")};'
    'var tbSyncing=false;function tbSync(){if(tbSyncing)return;tbSyncing=true;'
    'FS.syncfs(false,function(e){tbSyncing=false;if(e){Module["printErr"](e)}})}'
    # NB: no beforeunload hook - by then the page teardown kills the IDB
    # transaction, the sync never completes and Emscripten warns about
    # overlapping syncfs calls on the next boot.  visibilitychange(hidden)
    # fires early enough (tab switch, tab close, reload) to finish in time.
    'setInterval(tbSync,5000);'
    'document.addEventListener("visibilitychange",function(){'
    'if(document.visibilityState==="hidden"){tbSync()}})})'
)

INDEX_HTML = """<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <meta name="theme-color" content="#0d1117">
    <title>Tower Bloxx</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>&#129521;</text></svg>">
    <link rel="stylesheet" type="text/css" href="theme/love.css">
  </head>
  <body>
    <canvas id="loadingCanvas" width="675" height="900"></canvas>
    <canvas id="canvas" oncontextmenu="event.preventDefault()"></canvas>

    <script type='text/javascript'>
      // Keep the drawing buffer matched to the viewport.  CSS pixels, NOT
      // multiplied by devicePixelRatio: that is the convention love.js's own
      // fullscreen hook uses (SDL handles HiDPI internally), and scaling by
      // dpr here desyncs SDL's window size from the canvas on HiDPI screens.
      // Must go through Module.setCanvasSize: assigning canvas.width
      // directly leaves SDL's cached window size stale until the next real
      // resize event, so a freshly loaded page would render off-center.
      function fitCanvas() {
        var w = window.innerWidth;
        var h = window.innerHeight;
        if (Module && typeof Module.setCanvasSize === "function") {
          Module.setCanvasSize(w, h);
        } else {
          var canvas = document.getElementById("canvas");
          canvas.width = w;
          canvas.height = h;
        }
      }
      window.addEventListener("resize", fitCanvas);

      function goFullScreen() {
        var canvas = document.getElementById("canvas");
        if (canvas.requestFullscreen) canvas.requestFullscreen();
        else if (canvas.webkitRequestFullscreen) canvas.webkitRequestFullscreen();
        else if (canvas.mozRequestFullScreen) canvas.mozRequestFullScreen();
      }

      var loadingContext = document.getElementById('loadingCanvas').getContext('2d');
      function drawLoadingText(text) {
        var canvas = loadingContext.canvas;
        loadingContext.fillStyle = "#0d1117";
        loadingContext.fillRect(0, 0, canvas.width, canvas.height);
        loadingContext.font = "bold 28px system-ui, sans-serif";
        loadingContext.textAlign = "center";
        loadingContext.fillStyle = "#8ec3e3";
        loadingContext.fillText(text, canvas.width / 2, canvas.height / 2);
      }

      window.onload = function () { window.focus(); };
      window.onclick = function () { window.focus(); };

      window.addEventListener("keydown", function (e) {
        // space and arrow keys scroll the page otherwise
        if ([32, 37, 38, 39, 40].indexOf(e.keyCode) > -1) {
          e.preventDefault();
        }
      }, false);

      var Module = {
        arguments: ["./game.love"],
        INITIAL_MEMORY: __MEMORY__,
        printErr: console.error.bind(console),
        canvas: (function () {
          var canvas = document.getElementById('canvas');
          canvas.addEventListener("webglcontextlost", function (e) {
            alert('WebGL context lost. You will need to reload the page.');
            e.preventDefault();
          }, false);
          return canvas;
        })(),
        setStatus: function (text) {
          if (text) {
            drawLoadingText(text);
          } else if (Module.remainingDependencies === 0) {
            fitCanvas(); // size first: the very first visible frame is then centred
            document.getElementById('loadingCanvas').style.display = 'none';
            document.getElementById('canvas').style.visibility = 'visible';
          }
        },
        totalDependencies: 0,
        remainingDependencies: 0,
        monitorRunDependencies: function (left) {
          this.remainingDependencies = left;
          this.totalDependencies = Math.max(this.totalDependencies, left);
          Module.setStatus(left ? 'Loading... (' + (this.totalDependencies - left) + '/' + this.totalDependencies + ')' : 'Starting...');
        }
      };
      Module.setStatus('Loading...');
      window.onerror = function (event) {
        Module.setStatus('Exception thrown, see JavaScript console');
        Module.setStatus = function (text) {
          if (text) Module.printErr('[post-exception status] ' + text);
        };
      };

      // Boot-order guard: Module.setCanvasSize only exists once the wasm
      // runtime is up, and SDL re-imposes the conf.lua size when it
      // initialises.  Poll until the drawing buffer really matches the
      // viewport so a fresh load is centred no matter who wins the race.
      function canvasMatchesViewport() {
        var c = document.getElementById("canvas");
        return !!c && c.width === window.innerWidth
                   && c.height === window.innerHeight;
      }
      var tbStable = 0, tbTries = 0;
      var tbPoll = setInterval(function () {
        tbTries++;
        if (canvasMatchesViewport()) {
          tbStable++;
          if (tbStable > 3 || tbTries > 40) clearInterval(tbPoll);
        } else {
          tbStable = 0;
          fitCanvas();
        }
      }, 250);

      var applicationLoad = function (e) {
        Love(Module);
        fitCanvas();
      }
    </script>
    <script type="text/javascript" src="game.js"></script>
    <script async type="text/javascript" src="love.js" onload="applicationLoad(this)"></script>
  </body>
</html>
"""

LOVE_CSS = """html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  overflow: hidden;
  background: #0d1117;
}

#canvas, #loadingCanvas {
  display: block;
  width: 100vw;
  height: 100vh;
  touch-action: none;
}

#canvas {
  visibility: hidden;
}

#loadingCanvas {
  position: absolute;
  inset: 0;
}
"""


def make_love_zip(target: Path) -> None:
    with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as z:
        for name in GAME_FILES:
            z.write(ROOT / name, name)
        for dir_name in GAME_DIRS:
            for path in sorted((ROOT / dir_name).rglob("*")):
                if path.name in EXCLUDE_NAMES or path.suffix in EXCLUDE_SUFFIXES:
                    continue
                if path.is_file():
                    z.write(path, path.relative_to(ROOT))
    print(f"  {target.relative_to(ROOT)}: {target.stat().st_size // 1024} KB")


def transpile(love_zip: Path) -> None:
    if WEB.exists():
        shutil.rmtree(WEB)
    cmd = [
        "npx", "-y", "love.js", str(love_zip), str(WEB),
        "-c", "-m", str(MEMORY_BYTES), "-t", TITLE,
    ]
    print("  running:", " ".join(cmd))
    subprocess.run(cmd, cwd=ROOT, check=True, capture_output=True)


def patch_persistence() -> None:
    love_js = WEB / "love.js"
    text = love_js.read_text(encoding="utf-8")
    if SYNCFS_ANCHOR not in text:
        sys.exit("error: love.js layout changed - IDBFS anchor not found, "
                 "update SYNCFS_ANCHOR in this script")
    love_js.write_text(text.replace(SYNCFS_ANCHOR, SYNCFS_PATCH), encoding="utf-8")
    print("  patched save-dir persistence (IDBFS reverse sync)")


def write_theme() -> None:
    (WEB / "index.html").write_text(
        INDEX_HTML.replace("__MEMORY__", str(MEMORY_BYTES)), encoding="utf-8")
    (WEB / "theme" / "love.css").write_text(LOVE_CSS, encoding="utf-8")
    print("  wrote themed index.html + theme/love.css")


def main() -> None:
    print("building web version:")
    BUILD.mkdir(exist_ok=True)
    make_love_zip(BUILD / "game.love")
    transpile(BUILD / "game.love")
    patch_persistence()
    write_theme()
    total = sum(p.stat().st_size for p in WEB.rglob("*") if p.is_file())
    print(f"  web/ ready: {total / 1e6:.1f} MB - serve it over HTTP, e.g.")
    print("    python3 -m http.server -d web 8000")


if __name__ == "__main__":
    main()
