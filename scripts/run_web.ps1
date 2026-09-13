param([switch]$NoBuild, [switch]$NoOpen, [switch]$Stop, [ValidateRange(1024,65535)][int]$Port=8765)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$serverScript = Join-Path $PSScriptRoot 'serve_web.py'
$pidFile = Join-Path $projectRoot ".tools/web-server-$Port.json"
if ($Stop) {
    if (Test-Path -LiteralPath $pidFile) {
        $saved = Get-Content -LiteralPath $pidFile -Raw | ConvertFrom-Json
        $owned = Get-CimInstance Win32_Process -Filter "ProcessId=$([int]$saved.pid)" -ErrorAction SilentlyContinue
        if ($owned -and $owned.CommandLine.Contains($serverScript) -and $owned.CommandLine.Contains("--port $Port")) {
            Stop-Process -Id $owned.ProcessId
        }
        Remove-Item -LiteralPath $pidFile
    }
    Write-Host "Local web server on port $Port stopped."
    return
}
if (-not $NoBuild) { & (Join-Path $PSScriptRoot 'export_web.ps1') }
$url = "http://127.0.0.1:$Port/"
$running = $false
try {
    $response = Invoke-WebRequest -Uri ($url + '__mobabot_health') -TimeoutSec 2 -UseBasicParsing
    if ($response.Content.Trim() -ne 'mobabot-local-web-v1') { throw 'Different server' }
    $running = $true
} catch {
    # A port collision will produce a clear bind error when Python starts.
}
if (-not $running) {
    $python = (Get-Command python -ErrorAction Stop).Source
    $serverArgs = '"' + $serverScript + '" --port ' + $Port
    $serverProcess = Start-Process -FilePath $python -ArgumentList $serverArgs -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $projectRoot ".tools/web-server-$Port.log") -RedirectStandardError (Join-Path $projectRoot ".tools/web-server-$Port.err.log")
    @{ pid=$serverProcess.Id; port=$Port } | ConvertTo-Json | Set-Content -LiteralPath $pidFile
    for ($attempt=0; $attempt -lt 30; $attempt++) {
        if ($serverProcess.HasExited) { throw "Server exited. See .tools/web-server-$Port.err.log" }
        try {
            $response = Invoke-WebRequest -Uri ($url + '__mobabot_health') -TimeoutSec 1 -UseBasicParsing
            if ($response.Content.Trim() -eq 'mobabot-local-web-v1') { $running=$true; break }
        } catch { Start-Sleep -Milliseconds 100 }
    }
    if (-not $running) { throw 'Local server did not become ready.' }
}
if (-not $NoOpen) { Start-Process $url }
Write-Host "Ready: $url  Rebuild with scripts/export_web.ps1, then refresh. Stop with scripts/run_web.ps1 -Stop -Port $Port"
