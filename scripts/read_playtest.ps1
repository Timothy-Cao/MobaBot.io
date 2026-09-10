param(
    [ValidateRange(1,20)][int]$Last = 3,
    [string]$LogPath = (Join-Path $env:APPDATA 'Godot/app_userdata/Workshop Salvager/salvage_runs.jsonl'),
    [switch]$IncludeTests
)
$ErrorActionPreference = 'Stop'
# One-shot, read-only. No profile reads, writes, telemetry upload or polling.
if (-not (Test-Path -LiteralPath $LogPath -PathType Leaf)) {
    Write-Output 'No result log yet. Results are recorded at victory/defeat, not continuously.'
    return
}
$records = @(
    foreach ($line in (Get-Content -LiteralPath $LogPath -Tail 500)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $entry = $line | ConvertFrom-Json -ErrorAction Stop }
        catch { Write-Warning 'Skipped an incomplete or malformed log line.'; continue }
        if ($null -eq $entry -or $null -eq $entry.result) { continue }
        if (-not $IncludeTests -and ($entry.practice -eq $true -or $entry.automated -eq $true)) { continue }
        [pscustomobject]@{
            timestamp = $entry.timestamp
            build = $entry.build
            log_schema = $entry.log_schema
            result = $entry.result
            campaign = $entry.campaign
            seconds = $entry.seconds
            wall_seconds = $entry.wall_seconds
            level = $entry.level
            kills = $entry.kills
            damage_taken = $entry.damage_taken
            last_damage = $entry.last_damage
            recent_damage = $entry.recent_damage
            damage_by_source = $entry.damage_by_source
            casts = $entry.casts
            earned_tool_ranks = $entry.earned_tool_ranks
            progression_samples = $entry.progression_samples
            energy_spent = $entry.energy_spent
            equipment = $entry.equipment
            render_timing = $entry.render_timing
            classification = if ($null -eq $entry.log_schema) { 'Historical: human/test origin unknown' } else { 'Tagged result; verify session timestamp and whether Continue was used' }
        }
    }
)
if ($records.Count -eq 0) { Write-Output 'No matching completed results in the last 500 lines.'; return }
$records | Select-Object -Last $Last | ConvertTo-Json -Depth 15
