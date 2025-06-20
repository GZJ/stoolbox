<#
.SYNOPSIS

#>
function StopWatch {
    $stopwatch = [System.Diagnostics.Stopwatch]::new()
    $stopwatch.Start()

    while ($true) {
        if ([System.Console]::KeyAvailable) {
            $key = [System.Console]::ReadKey($true)
            if ($key.Key -eq "Enter") {
                $stopwatch.Stop()
                break
            }
        } else {
            $elapsedTime = $stopwatch.Elapsed
            Write-Host -NoNewLine "`r$($elapsedTime.Hours):$($elapsedTime.Minutes):$($elapsedTime.Seconds).$($elapsedTime.Milliseconds)"
        }
    }
}
