<#
.SYNOPSIS
    Repair Microsoft Office
.DESCRIPTION
    Runs Office's quick repair. Helps when Word, Excel, Outlook or Teams crash, won't open or
    say they are unlicensed. All Office programs close while it runs, so save your work first.
    It takes about 5 to 15 minutes.
.NOTES
    RunAs: System
    Timeout: 30
#>
$c2r = Join-Path $env:CommonProgramFiles 'microsoft shared\ClickToRun\OfficeClickToRun.exe'
$cfg = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration' -ErrorAction SilentlyContinue
if (-not (Test-Path -LiteralPath $c2r) -or -not $cfg.Platform) {
    'This computer does not have the Microsoft 365 version of Office that can repair itself. Send an IT support request.'
    exit 1
}
$culture = if ($cfg.ClientCulture) { $cfg.ClientCulture } else { 'en-us' }
"Repairing Office ($($cfg.Platform), $culture). Office programs will close now..."
$p = Start-Process -FilePath $c2r -ArgumentList "scenario=Repair platform=$($cfg.Platform) culture=$culture RepairType=QuickRepair forceappshutdown=True DisplayLevel=False" -PassThru -Wait
# The repair goes on in Office's own update client after the starter exits.
$deadline = (Get-Date).AddMinutes(25)
Start-Sleep -Seconds 20
while ((Get-Process OfficeC2RClient -ErrorAction SilentlyContinue) -and (Get-Date) -lt $deadline) { Start-Sleep -Seconds 15 }
if ($p.ExitCode -ne 0) { "Office repair stopped with code $($p.ExitCode). Send an IT support request."; exit 1 }
'Office repair finished. Open your Office programs again.'
