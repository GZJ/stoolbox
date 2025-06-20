<#
.SYNOPSIS

#>
function whereis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$CommandName
    )
    
    Get-Command -Name $CommandName -ShowCommandInfo
}
