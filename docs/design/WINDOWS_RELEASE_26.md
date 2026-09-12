# Windows playtest release 0.26.0-test.1

Owner authorized Windows packaging and GitHub publication on 11 September 2026. Research/class/presentation proposals stay on hold. This release packages the verified gameplay; it does not change the balance.

## Build

Use the existing Godot 4.7.2 editor from `scripts/setup.ps1`. Obtain `templates/windows_release_x86_64.exe` from the official Godot 4.7.2 stable export templates archive and place it at `.tools/export-templates/windows_release_x86_64.exe`. SHA256 of that executable: `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562`. Initial acquisition used byte ranges from Godot's official object-storage mirror, ZIP metadata/CRC validation, then recorded this hash; not a full-archive checksum verification.

Run `scripts/export_windows.ps1 -Version 0.26.0-test.1` from a clean committed checkout. It uses `export_presets.cfg`, creates a fresh ignored export directory, copies the optional shortcut helper/instructions/engine notices, records the source commit, and ZIPs the folder. Reusing a folder is rejected to avoid stale release files. Upload the ZIP, not the automatically generated GitHub source archive.

## Verification

The release template does not accept editor `--path`/`--script` overrides. Launch its EXE from its own directory, using `--quit-after 10` for startup testing. `--write-movie` can record a startup frame without requiring an interactive visible window. For detailed pack checks, run the editor with `--main-pack <exported.pck> --script scripts/release/export_smoke.gd --headless`. The smoke scene sets `persist_settings=false`, visits Practice, checks dynamically loaded icons and all nine music streams, and emits a rocket. It does not grant loot.

Do not include local profiles, source masters, tests, docs, tools, credentials or test captures in the release ZIP. Player progress lives outside the extracted folder. The optional VBS helper creates a desktop shortcut to the adjacent EXE; manual Windows shortcut creation remains available when VBScript is disabled. No installer or updater is included.

The repository is private: release assets require repository access. The owner can instead send the same ZIP directly to a tester. Do not make the repository public or invite collaborators without an explicit request. The unsigned binary may trigger Windows publisher warnings. The menu currently retains its historical 0.18 label; identify this build by release tag and BUILD-COMMIT.txt.
