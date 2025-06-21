<#
.SYNOPSIS
remove specified directory from PATH (pdu pdm pdp)
#>
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

#----------------------------- delete -----------------------------
function EnvPath-Delete {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$profile,
        [string]$customPath
    )

    EnvPath-Refresh-Env $profile

    $path = $customPath
    $pathBackslope = Join-Path $path '\'
    $path = [regex]::Escape($path)
    $pathBackslope = [regex]::Escape($pathBackslope)

    $old = [Environment]::GetEnvironmentVariable("Path",$profile)
    $new = $old -replace "$path;|;$path$|$pathBackslope;|;$pathBackslope$",""
    Write-Verbose $old
    $oldCount = ($old -split ";").Count
    Write-Verbose $new
    $newCount = $newCount = ($new -split ";").Count

    EnvPath-Confirm-Set $profile $new "Delete $path"

    EnvPath-Refresh-Env $profile
}

function pdu {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$customPath = (Get-Location).Path
    )
    EnvPath-Delete "User" (EnvPath-Absolute-Path $customPath)
}

function pdm {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$customPath = (Get-Location).Path
    )
    EnvPath-Delete "Machine" (EnvPath-Absolute-Path $customPath)
}

function pdp {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$customPath = (Get-Location).Path
    )
    EnvPath-Delete "Process" (EnvPath-Absolute-Path $customPath)
}
