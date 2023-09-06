function pam {
    param(
        [string]$path = $null
    )

    if (-not $path) {
        $pathCurrent = Resolve-Path .
        while ($true) {
            switch (Read-Host 'Write current path to machine path variable (Y/N)') {
                'Y' {
                    [Environment]::SetEnvironmentVariable("PATH",$Env:PATH + ";" + $pathCurrent,"Machine")
                    Write-Host "Write path machine variable successful..." -ForegroundColor Green
                    return
                }
                'N' { return }
                default { Write-Host 'Only Y/N valid' -ForegroundColor Red }
            }
        }
    }

    [Environment]::SetEnvironmentVariable("PATH",$Env:PATH + ";" + $path,"Machine")
}
