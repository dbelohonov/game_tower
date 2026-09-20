"""Serve the web build on localhost with caching disabled.

Plain `python3 -m http.server` sends no Cache-Control headers, so browsers
apply heuristic caching and can keep serving a stale game.js after a
rebuild - and a stale game.js is doubly bad here: its embedded package
UUID matches the stale game.data in Emscripten's IndexedDB preload cache,
so the whole game boots old without ever contacting the server.
no-store kills both: every reload re-downloads, which is what a dev
server should do (the payload is ~6 MB and localhost-fast anyway).

Usage:
    uv run python scripts/serve_web.py [port]     # default 8000
"""

import http.server
import sys
from pathlib import Path

WEB = Path(__file__).resolve().parent.parent / "web"
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8000


class NoStoreHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


def main():
    handler = lambda *a, **kw: NoStoreHandler(*a, directory=str(WEB), **kw)
    with http.server.ThreadingHTTPServer(("0.0.0.0", PORT), handler) as httpd:
        print(f"serving {WEB} on http://localhost:{PORT} (Cache-Control: no-store)")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
