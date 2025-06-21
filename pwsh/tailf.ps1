<#
.SYNOPSIS
follow file changes in real-time like tail -f
#>
function tailf {
    param(
        [Parameter(
            HelpMessage = "Specify the file(s) to copy."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Item
    )

    Get-Content -Path $Item -Wait
}
