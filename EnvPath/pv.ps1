<#
.SYNOPSIS
view current state of PATH (pvu pvm pvp pvur pvmr pvpr)
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
