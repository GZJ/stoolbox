function EnvPath-Refresh-Env {
    param(
        [string]$profile
    )
    if ($profile -eq "Process") {
        return
    }
    refreshenv > $null
}

function EnvPath-Confirm-Set {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$profile,
        [string]$newPath,
        [string]$describe
    )

    if ($PSCmdlet.ShouldProcess("Environment Path Variable",$describe)) {
        [Environment]::SetEnvironmentVariable("Path",$newPath,$profile)
        if ($?) {
            Write-Host "Set new path for $profile successful." -ForegroundColor Green
        } else {
            Write-Warning "Failed to set a new path for $profile."
        }
    } else {
        Write-Host "No changes made." -ForegroundColor Yellow
        return $false
    }
}

#----------------------------- revert -----------------------------
function EnvPath-Revert {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$profile,
        [string]$vname
    )

    EnvPath-Refresh-Env $profile

    $p = [Environment]::GetEnvironmentVariable($vname,$profile)
    EnvPath-Confirm-Set $profile $p "Revert"

    EnvPath-Refresh-Env $profile
}

function pru {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Revert "User" "PathBackupUser"
}
function prm {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Revert "Machine" "PathBackupMachine"
}
function prp {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Revert "Process" "PathBackupProcess"
}
