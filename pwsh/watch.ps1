<#
.SYNOPSIS
execute commands at regular intervals for monitoring purposes
#>
function watch {
    param(
        $cmd,
        [int]$interval = 3
    )
    if (!$cmd) {
        Write-Output "no command"
        return
    }
    $command = "while(1){clear; $cmd ;sleep $interval}"
    Invoke-Expression "$command"
}
