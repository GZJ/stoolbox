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

#----------------------------- revert -----------------------------
function EnvPath-Revert {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string]$profile
    )
    EnvPath-Refresh-Env $profile

    $p = [Environment]::GetEnvironmentVariable("PathBackup",$profile)
    EnvPath-Confirm-Set $profile $p "Revert"
}


function pru {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Revert ("User")
}
function prm {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Revert ("Machine")
}
function prp {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()
    EnvPath-Revert ("Process")
}

#----------------------------- view -----------------------------
function EnvPath-View {
    [CmdletBinding()]
    param(
        [string]$profile,
        [switch]$Raw
    )
    EnvPath-Refresh-Env $profile

    $path = [Environment]::GetEnvironmentVariable("PATH",$profile)
    if ($Raw) {
        $path
    } else {
        $path -split ';'
    }
}

function pvu {
    EnvPath-View "User"
}
function pvm {
    EnvPath-View "Machine"
}
function pvp {
    EnvPath-View "Process"
}
function pvur {
    EnvPath-View "User" -Raw
}
function pvmr {
    EnvPath-View "Machine" -Raw
}
function pvpr {
    EnvPath-View "Process" -Raw
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
