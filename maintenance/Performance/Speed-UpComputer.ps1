<#
.SYNOPSIS
    Speed up a slow computer
.DESCRIPTION
    Closes programs that have stopped responding, restarts the taskbar and Start menu, and
    clears your temporary files. A frozen program loses anything not yet saved in it.
.NOTES
    RunAs: User
    Timeout: 10
#>
$hung = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 -and -not $_.Responding -and $_.ProcessName -ne 'explorer' })
foreach ($p in $hung) {
    try { Stop-Process -Id $p.Id -Force -ErrorAction Stop; "Closed $($p.ProcessName), which had stopped responding." } catch { }
}
if (-not $hung) { 'No programs were frozen.' }

Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) { Start-Process explorer.exe }
'Restarted the taskbar and Start menu.'

$cutoff = (Get-Date).AddDays(-1)
$bytes = 0
foreach ($f in @(Get-ChildItem -LiteralPath $env:TEMP -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoff })) {
    try { Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop; $bytes += $f.Length } catch { }
}
"Cleared $([Math]::Round($bytes / 1MB, 1)) MB of temporary files."

$os = Get-CimInstance Win32_OperatingSystem
$days = [int]((Get-Date) - $os.LastBootUpTime).TotalDays
$memUsed = [Math]::Round((1 - $os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100)
"Memory in use: $memUsed%."
$top = Get-Process -ErrorAction SilentlyContinue | Sort-Object WorkingSet64 -Descending | Select-Object -First 3
"Using the most memory: $(($top | ForEach-Object { "$($_.ProcessName) ($([Math]::Round($_.WorkingSet64 / 1MB)) MB)" }) -join ', ')."
if ($days -ge 7) { "Your computer has not restarted in $days days. Restarting it will help most." }
