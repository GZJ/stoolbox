function EnvPath-Refresh-Env {
    param(
        [string]$profile
    )
    if ($profile -eq "Process") {
        return
    }
    refreshenv > $null
}

#----------------------------- backup -----------------------------
function EnvPath-Backup {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$profile,
        [string]$vname
    )

    EnvPath-Refresh-Env $profile

    $p = [Environment]::GetEnvironmentVariable("Path",$profile)
    [Environment]::SetEnvironmentVariable($vname,$p,$profile)

    EnvPath-Refresh-Env $profile
}

function pbu {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Backup "User" "PathBackupUser"
}

function pbm {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Backup "Machine" "PathBackupMachine"
}

function pbp {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Backup "Process" "PathBackupProcess"
}
