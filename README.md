# Self-maintenance scripts

Scripts in `maintenance/` appear as fix-it-yourself tasks in the Ariat request window
(`Invoke-AriatForm.ps1`, script variable `maintenanceRepo`). Each script's comment-based help
decides how it is listed:

```powershell
<#
.SYNOPSIS
    Fix stuck print jobs                     # card title (no .SYNOPSIS = helper, not listed)
.DESCRIPTION
    Restarts the print spooler and ...       # text under the title
.NOTES
    RunAs: System                            # System (administrator rights) or User (default)
    Category: Printing                       # heading; default = first sub-folder
    Timeout: 5                               # minutes, 1-120, default 10
#>
```

Each organization's list is `maintenance/orgs/<NinjaOne organization id>.txt`: one script path per
line, `#` for comments. An organization without a list sees every script. The lists were picked from
each organization's tickets (Nov 2025 - Nov 2026): a fix is listed when 2 or more tickets were about
its problem.

Exit code 0 = success. Scripts run hidden and non-interactive, so they can't prompt.

> **Everything merged to `main` runs as SYSTEM on every device that shows the list.**
> Review changes accordingly.
