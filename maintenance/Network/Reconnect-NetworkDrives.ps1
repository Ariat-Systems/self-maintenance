<#
.SYNOPSIS
    Reconnect my network drives
.DESCRIPTION
    Reloads your company settings and reconnects your mapped drives (like I: or S:). Helps
    when a drive is missing or shows a red X.
.NOTES
    RunAs: User
    Timeout: 5
#>
'Reloading your company settings...'
# Answers "no" if Windows asks to sign out, so nothing is closed.
cmd.exe /c 'echo N| gpupdate /target:user /force' | Out-Null

$drives = @(Get-ChildItem -Path 'HKCU:\Network' -ErrorAction SilentlyContinue | ForEach-Object {
    [pscustomobject]@{ Letter = $_.PSChildName.ToUpper(); Path = (Get-ItemProperty $_.PSPath).RemotePath } })
if (-not $drives) { 'No mapped network drives are saved for you. If you expected one, send an IT support request.'; exit 0 }

$failed = 0
foreach ($d in $drives) {
    if (Test-Path -LiteralPath "$($d.Letter):\") { "$($d.Letter): ($($d.Path)) is connected."; continue }
    net use "$($d.Letter):" /delete /y 2>$null | Out-Null
    $out = net use "$($d.Letter):" "$($d.Path)" /persistent:yes 2>&1
    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath "$($d.Letter):\")) { "$($d.Letter): ($($d.Path)) reconnected." }
    else {
        $failed++
        "$($d.Letter): ($($d.Path)) could not connect: $((@($out) -join ' ').Trim())"
    }
}
if ($failed) { 'Some drives could not connect. If you work from home, connect the VPN and try again; otherwise send an IT support request.'; exit 1 }
