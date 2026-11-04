<#
.SYNOPSIS
    Fix my internet connection
.DESCRIPTION
    Gets a fresh network address, clears saved website lookups and checks that the internet
    answers. The connection drops for a few seconds while it runs, and a VPN may need to
    reconnect.
.NOTES
    RunAs: System
    Timeout: 5
#>
ipconfig /release | Out-Null
ipconfig /renew | Out-Null
Clear-DnsClientCache
Register-DnsClient
Start-Sleep -Seconds 5

$adapters = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object Status -eq 'Up')
$gateway = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object -First 1
$names = try { [bool](Resolve-DnsName www.microsoft.com -DnsOnly -ErrorAction Stop) } catch { $false }
$web = Test-NetConnection www.microsoft.com -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue

"Connected adapters: $(if ($adapters) { ($adapters.Name) -join ', ' } else { 'none' })"
"Router found: $(if ($gateway) { 'yes' } else { 'no' })"
"Website names work: $(if ($names) { 'yes' } else { 'no' })"
"Internet answers: $(if ($web) { 'yes' } else { 'no' })"
if ($web) { 'Your internet connection is working.' }
elseif (-not $adapters) { 'No network is connected. Check the cable, or turn Wi-Fi on and pick your network.'; exit 1 }
else { 'The internet is still not answering. Restart your router or send an IT support request.'; exit 1 }
