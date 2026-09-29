<#
.SYNOPSIS
    Fix websites that won't load
.DESCRIPTION
    Clears the DNS cache and re-registers this computer's name. Helps when some websites or
    company servers can't be found but the internet otherwise works.
.NOTES
    RunAs: System
    Timeout: 5
#>
Clear-DnsClientCache
Register-DnsClient
'DNS cache cleared and computer name re-registered.'
