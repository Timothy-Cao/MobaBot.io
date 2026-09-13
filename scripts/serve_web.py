"""Loopback-only development server. Serve the export, never the source/profile."""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1] / "exports" / "web"


class Handler(SimpleHTTPRequestHandler):
    extensions_map = {**SimpleHTTPRequestHandler.extensions_map, ".wasm": "application/wasm", ".pck": "application/octet-stream"}

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

    def do_GET(self):
        if urlsplit(self.path).path == "/__mobabot_health":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"mobabot-local-web-v1")
            return
        # No directory listings, traversal or symlink escape from the export.
        requested = unquote(urlsplit(self.path).path).lstrip("/")
        target = (ROOT / requested).resolve()
        if not target.is_relative_to(ROOT.resolve()) or target.is_dir() and requested:
            self.send_error(403)
            return
        super().do_GET()

    def list_directory(self, path):
        self.send_error(403)
        return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    if not (ROOT / "index.html").is_file():
        raise SystemExit("Build first: scripts/export_web.ps1")
    server = ThreadingHTTPServer(("127.0.0.1", args.port), partial(Handler, directory=str(ROOT)))
    print(f"MobaBot: http://127.0.0.1:{args.port}/ (Ctrl+C stops the server)", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
