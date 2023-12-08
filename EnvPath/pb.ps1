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

#----------------------------- backup -----------------------------
function EnvPath-Backup {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$profile
    )
    EnvPath-Refresh-Env $profile

    $p = [Environment]::GetEnvironmentVariable("Path",$profile)
    EnvPath-Confirm-Set $profile $p "Backup $p"
}

function pbu {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Backup ("User")
}
function pbm {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Backup ("Machine")
}
function pbp {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Backup ("Process")
}
