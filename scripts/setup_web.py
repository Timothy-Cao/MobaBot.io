"""Fetch only the two Web templates from Godot's large official ZIP.

HTTPS origin + ZIP CRC/size validation; no claim of full archive hash validation.
The engine/version matches scripts/setup.ps1. No pip packages needed.
"""
import hashlib
import io
from pathlib import Path
import urllib.request
import zipfile

VERSION = "4.7.2-stable"
URL = f"https://godot-releases.nbg1.your-objectstorage.com/{VERSION}/Godot_v{VERSION}_export_templates.tpz"
DEST = Path(__file__).resolve().parents[1] / ".tools" / "export-templates"
NAMES = ("web_nothreads_debug.zip", "web_nothreads_release.zip")
HASHES = {
    "web_nothreads_debug.zip": "08962aefef811b603541d7951ac67ef00413aad2d978855183c28adee98f626a",
    "web_nothreads_release.zip": "d3ee2f08cef0cf3cf6678a6355a92a8db48ccdd35cbd2e8bfd5f0e8a0b4032a0",
}


class RemoteZip(io.RawIOBase):
    def __init__(self):
        with urllib.request.urlopen(urllib.request.Request(URL, method="HEAD"), timeout=60) as response:
            self.length = int(response.headers["Content-Length"])
        self.position = 0

    def seekable(self):
        return True

    def tell(self):
        return self.position

    def seek(self, offset, whence=0):
        self.position = offset if whence == 0 else self.position + offset if whence == 1 else self.length + offset
        if self.position < 0:
            raise ValueError("Negative archive offset")
        return self.position

    def read(self, size=-1):
        count = self.length - self.position if size < 0 else min(size, self.length - self.position)
        if count <= 0:
            return b""
        if count > 32 * 1024 * 1024:
            raise ValueError("Unexpectedly large archive entry")
        start, end = self.position, self.position + count - 1
        request = urllib.request.Request(URL, headers={"Range": f"bytes={start}-{end}"})
        with urllib.request.urlopen(request, timeout=90) as response:
            expected = f"bytes {start}-{end}/{self.length}"
            if response.status != 206 or response.headers.get("Content-Range") != expected:
                raise RuntimeError("Server did not honor the exact requested range")
            data = response.read(count + 1)
        if len(data) != count:
            raise RuntimeError("Incomplete template download")
        self.position += count
        return data


def main():
    DEST.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(RemoteZip()) as archive:
        for name in NAMES:
            target = DEST / name
            print(f"Installing official {VERSION} {name}...", flush=True)
            data = archive.read("templates/" + name)  # ZipFile verifies CRC.
            if hashlib.sha256(data).hexdigest() != HASHES[name]:
                raise RuntimeError("Template SHA256 differs from the verified version")
            with zipfile.ZipFile(io.BytesIO(data)) as template:
                if template.testzip() is not None:
                    raise RuntimeError("Invalid inner template archive")
            temporary = target.with_suffix(".zip.tmp")
            temporary.write_bytes(data)
            temporary.replace(target)
            print(f"SHA256 {hashlib.sha256(data).hexdigest()}  {name}", flush=True)


if __name__ == "__main__":
    main()
