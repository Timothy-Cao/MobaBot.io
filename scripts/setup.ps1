$ErrorActionPreference = "Stop"

$version = "4.7.2-stable"
$archiveName = "Godot_v$version`_win64.exe.zip"
$expectedSha256 = "731980F9608D61333E5BAF54A2EF17210ACC7A538446C0CB9969F002ACA1E953"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$installDirectory = Join-Path $projectRoot ".tools\godot"
$archivePath = Join-Path $installDirectory $archiveName
$editorPath = Join-Path $installDirectory "Godot_v$version`_win64.exe"
$downloadUrl = "https://godot-releases.nbg1.your-objectstorage.com/$version/$archiveName"

New-Item -ItemType Directory -Force -Path $installDirectory | Out-Null

if (-not (Test-Path -LiteralPath $editorPath)) {
    Write-Host "Downloading Godot $version..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath

    $actualSha256 = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash
    if ($actualSha256 -ne $expectedSha256) {
        throw "Godot archive checksum mismatch. Expected $expectedSha256, received $actualSha256."
    }

    Expand-Archive -LiteralPath $archivePath -DestinationPath $installDirectory -Force
}

# Godot's supported portable mode keeps editor settings and cache beside the binary.
New-Item -ItemType File -Force -Path (Join-Path $installDirectory "_sc_") | Out-Null

& $editorPath --version
Write-Host "Godot is ready. Run .\scripts\open_editor.ps1 to begin."
