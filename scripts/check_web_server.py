"""Isolated HTTP behavior check using disposable exports, never player data."""
from functools import partial
from http.server import ThreadingHTTPServer
from pathlib import Path
import tempfile
import threading
import urllib.error
import urllib.request
import serve_web


with tempfile.TemporaryDirectory(prefix="mobabot-web-test-") as directory:
    root = Path(directory)
    (root / "index.html").write_text("fixture", encoding="utf-8")
    (root / "index.wasm").write_bytes(b"wasm-fixture")
    serve_web.ROOT = root
    server = ThreadingHTTPServer(("127.0.0.1", 0), partial(serve_web.Handler, directory=directory))
    worker = threading.Thread(target=server.serve_forever, daemon=True)
    worker.start()
    base = f"http://127.0.0.1:{server.server_port}"
    try:
        with urllib.request.urlopen(base + "/index.wasm") as response:
            assert response.headers["Content-Type"] == "application/wasm"
            assert response.headers["Cache-Control"] == "no-store"
            assert response.headers["Cross-Origin-Opener-Policy"] == "same-origin"
            assert response.headers["Cross-Origin-Embedder-Policy"] == "require-corp"
            assert response.read() == b"wasm-fixture"
        with urllib.request.urlopen(base + "/__mobabot_health") as response:
            assert response.read() == b"mobabot-local-web-v1"
        with urllib.request.urlopen(base + "/") as response:
            assert response.read() == b"fixture"
        try:
            urllib.request.urlopen(base + "/%2e%2e/SESSION_HANDOFF.md")
            raise AssertionError("Traversal accepted")
        except urllib.error.HTTPError as error:
            assert error.code == 403
        print("WEB SERVER: MIME, freshness, headers, health, index and containment PASS")
    finally:
        server.shutdown()
        server.server_close()
        worker.join()
