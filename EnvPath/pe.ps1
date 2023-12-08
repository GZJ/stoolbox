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

#----------------------------- edit -----------------------------
function EnvPath-Edit {
    param(
        [string]$profile,
        [switch]$Raw
    )
    EnvPath-Refresh-Env $profile

    $peTemp = New-TemporaryFile
    $p = [Environment]::GetEnvironmentVariable("Path",$profile)
    if ($Raw) {
        $p > $peTemp
        vim $peTemp
    } else {
        $p -split ';' > $peTemp
        vim $peTemp
        $combinedString = ""
        Get-Content -Path $peTemp | ForEach-Object {
            $combinedString += $_ + ";"
        }
        $combinedString = $combinedString.TrimEnd(";")
        Write-Output $combinedString
        EnvPath-Confirm-Set $profile $combinedString "Overwrite the edited content into path"
    }
}

function peu {
    EnvPath-Edit "User"
}
function pem {
    EnvPath-Edit "Machine"
}
function pep {
    EnvPath-Edit "Process"
}
function peur {
    EnvPath-Edit "User" -Raw
}
function pemr {
    EnvPath-Edit "Machine" -Raw
}
function pepr {
    EnvPath-Edit "Process" -Raw
}
