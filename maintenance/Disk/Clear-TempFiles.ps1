<#
.SYNOPSIS
    Clear my temporary files
.DESCRIPTION
    Deletes files older than a day from your temp folder. Frees disk space and can fix apps
    that fail to install or update.
.NOTES
    RunAs: User
    Category: Disk space
    Timeout: 10
#>
$cutoff = (Get-Date).AddDays(-1)
$files = @(Get-ChildItem -LiteralPath $env:TEMP -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $cutoff })
$removed = 0; $bytes = 0
foreach ($f in $files) {
    try { Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop; $removed++; $bytes += $f.Length } catch { }
}
"Removed $removed of $($files.Count) old temporary files ($([Math]::Round($bytes / 1MB, 1)) MB freed)."
