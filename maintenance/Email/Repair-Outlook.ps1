<#
.SYNOPSIS
    Fix Outlook
.DESCRIPTION
    Closes Outlook, clears its temporary settings cache and opens it again with a fresh folder
    pane. Helps when Outlook won't open, freezes or shows folders wrong. Your email, contacts
    and saved addresses are not touched. Pinned favorite folders may need pinning again.
.NOTES
    RunAs: User
    Timeout: 5
#>
$exe = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\OUTLOOK.EXE' -ErrorAction SilentlyContinue).'(default)'
if (-not $exe -or -not (Test-Path -LiteralPath $exe)) {
    'Classic Outlook is not installed on this computer, so this fix does not apply. Send an IT support request.'
    exit 1
}

$running = @(Get-Process OUTLOOK -ErrorAction SilentlyContinue)
if ($running) {
    'Closing Outlook...'
    $running | ForEach-Object { [void]$_.CloseMainWindow() }
    $running | ForEach-Object { if (-not $_.WaitForExit(30000)) { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } }
    Start-Sleep -Seconds 2
}

# The cache of server settings; Stream_Autocomplete holds saved addresses and is kept.
$roam = Join-Path $env:LOCALAPPDATA 'Microsoft\Outlook\RoamCache'
$removed = 0
foreach ($f in @(Get-ChildItem -LiteralPath $roam -File -ErrorAction SilentlyContinue | Where-Object Name -notlike 'Stream_Autocomplete*')) {
    try { Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop; $removed++ } catch { }
}
"Cleared $removed cached settings file(s)."

Start-Process -FilePath $exe -ArgumentList '/resetnavpane'
'Outlook is opening again. Give it a minute to load your mail.'
