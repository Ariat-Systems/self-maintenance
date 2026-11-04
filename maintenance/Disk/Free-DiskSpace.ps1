<#
.SYNOPSIS
    Free up disk space
.DESCRIPTION
    Empties the Recycle Bin and deletes temporary files and old Windows update downloads.
    Anything in the Recycle Bin is deleted for good. Your documents are not touched.
.NOTES
    RunAs: System
    Category: Disk space
    Timeout: 30
#>
$drive = $env:SystemDrive
$freeBefore = (Get-PSDrive $drive.TrimEnd(':')).Free
$cutoff = (Get-Date).AddDays(-1)

function Remove-Old([string]$Dir) {
    Get-ChildItem -LiteralPath $Dir -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue }
}

'Emptying the Recycle Bin...'
Get-ChildItem -LiteralPath "$drive\`$Recycle.Bin" -Force -ErrorAction SilentlyContinue |
    ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }

'Deleting temporary files...'
Remove-Old "$env:SystemRoot\Temp"
foreach ($p in Get-ChildItem -LiteralPath "$drive\Users" -Directory -Force -ErrorAction SilentlyContinue) {
    Remove-Old (Join-Path $p.FullName 'AppData\Local\Temp')
}

'Deleting old Windows update downloads...'
Stop-Service wuauserv, bits -Force -ErrorAction SilentlyContinue
Remove-Item "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service bits, wuauserv -ErrorAction SilentlyContinue
if (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) { Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue }

$freeAfter = (Get-PSDrive $drive.TrimEnd(':')).Free
$total = $freeAfter + (Get-PSDrive $drive.TrimEnd(':')).Used
"Freed $([Math]::Round([Math]::Max(0, $freeAfter - $freeBefore) / 1GB, 2)) GB. $drive now has $([Math]::Round($freeAfter / 1GB, 1)) GB free of $([Math]::Round($total / 1GB, 1)) GB."
if ($freeAfter / $total -lt 0.10) { 'The disk is still almost full. Send an IT support request so a technician can look at what is using the space.' }
