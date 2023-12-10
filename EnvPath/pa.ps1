function EnvPath-Refresh-Env {
    param(
        [string]$profile
    )
    if ($profile -eq "Process") {
        return
    }
    refreshenv > $null
}

function EnvPath-Absolute-Path {
    param(
        [string]$path
    )

    return (Resolve-Path -Path $path).Path
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

#----------------------------- append -----------------------------
function EnvPath-Append {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$profile,
        [string]$customPath = (Get-Location).Path
    )

    EnvPath-Refresh-Env $profile

    $path = EnvPath-Absolute-Path $customPath
    $p = [Environment]::GetEnvironmentVariable("Path",$profile)
    EnvPath-Confirm-Set $profile "$p;$path" "Append this path $path"

    EnvPath-Refresh-Env $profile
}

function pau {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    [CmdletBinding()]
    param(
        [string]$customPath = (Get-Location).Path
    )

    EnvPath-Append "User" (EnvPath-Absolute-Path $customPath)
}

function pam {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$customPath = (Get-Location).Path
    )

    EnvPath-Append "Machine" (EnvPath-Absolute-Path $customPath)
}

function pap {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$customPath = (Get-Location).Path
    )

    EnvPath-Append "Process" (EnvPath-Absolute-Path $customPath)
}
