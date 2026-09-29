<#
.SYNOPSIS
    Fix stuck print jobs
.DESCRIPTION
    Restarts the Windows print spooler and clears jobs stuck in the queue. Anything waiting to
    print will need to be printed again.
.NOTES
    RunAs: System
    Timeout: 5
#>
Stop-Service -Name Spooler -Force
Get-ChildItem -LiteralPath "$env:SystemRoot\System32\spool\PRINTERS" -File -ErrorAction SilentlyContinue |
    Remove-Item -Force -ErrorAction SilentlyContinue
Start-Service -Name Spooler
$status = (Get-Service -Name Spooler).Status
"Print spooler is $status."
if ($status -ne 'Running') { exit 1 }
