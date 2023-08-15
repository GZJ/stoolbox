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
