# Local browser development

12 September 2026. Same Godot project and intent39 gameplay as native; no separate gameplay port or public deployment.

## Daily workflow

From the project folder in PowerShell:

```powershell
.\scripts\run_game.ps1       # Native Godot
.\scripts\run_web.ps1        # Build, serve and open the browser
```

The browser address is http://127.0.0.1:8765/. After editing, run `scripts/export_web.ps1` and refresh the page. This restarts the browser game, so do it between tests. There is no automatic hot reload. Native and browser may run side by side.

`scripts/run_web.ps1 -NoBuild` reuses the last export. `-NoOpen` keeps the browser closed. `scripts/run_web.ps1 -Stop` stops the owned local server. `-Port` selects another port, but keep 8765 for consistent browser saves. The hidden server stays running until stopped or Windows exits.

Prerequisites: the existing Godot setup (`scripts/setup.ps1`) and Python 3.10+. The first web export downloads matching official Godot 4.7.2 single-threaded debug/release templates into ignored `.tools`. `scripts/setup_web.py` fetches just the two entries using HTTP ranges, validates ZIP CRC and pinned entry SHA256, and keeps the large archive off disk. The pins were established from the official HTTPS download, not an independently published full-archive checksum.

## Platform differences

- Browser progress/settings use browser storage, separate from Windows saves. Changing browser, origin/port, clearing site data or private browsing can yield a fresh profile. Profile sync is not implemented.
- Click the game to give keyboard/audio focus. Fullscreen is entered through Settings after a click; the browser controls Escape. Browser pointer speed follows the operating system, so the in-game mouse-speed slider is disabled there.
- Home uses Reload instead of Quit. Close the tab to exit. Existing campaign checkpoint rules still apply; refreshing is not an exact-frame save.
- Desktop keyboard/mouse and WebGL2 are the target. This is not a touch/mobile conversion. Heavy crowds and precise buffered combos still need human browser testing; native performance is not a browser guarantee.
- Initial debug payload is about 103 MB before HTTP compression. The local server prioritizes fresh builds, with no service-worker cache. Public download-size optimization/hosting is a separate task.

The Web preset uses Godot's single-threaded Compatibility export. The server binds only loopback and serves only `exports/web`, with correct WASM MIME and isolation headers. It does not expose the repository or native saves. `exports/web/build.json` records source commit, dirty state, UTC build time and debug/release variant. `scripts/export_web.ps1 -Release` builds the release variant into the same folder.

Browser-only source adaptations avoid cursor confinement, defer fullscreen until interaction, reload on exit, and bundle an OFL symbol fallback for HUD diamonds/charge pips. All native gameplay and input contracts are retained. Font and engine notices accompany exported files.

## Verification

`scripts/check.ps1` includes `web_compat_test.gd` (46 suites). `python scripts/check_web_server.py` checks a disposable HTTP fixture's WASM type, freshness, isolation headers, health endpoint and path containment, without player data. Debug export and actual in-app Chromium rendering passed: illustrated Home, Settings, Practice, right-click movement, Q/E/LMB inputs, HUD symbols and settings persistence across refresh. No permanent rewards were produced. Precise combo timing, audible music quality, full campaign storage/recovery and other browser engines remain human/platform review items.

Reference: [Godot Web export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) describes Compatibility/WebGL2, serving over HTTP, browser persistence and audio/fullscreen restrictions. [Google Fonts Noto Symbols 2](https://github.com/google/fonts/tree/main/ofl/notosanssymbols2) supplies the licensed symbol fallback.
