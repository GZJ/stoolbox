﻿<#
.SYNOPSIS
IP address utility tool for getting local and external IP information
#>
function ip {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromRemainingArguments = $true,
            HelpMessage = "Specify the destination path(s) to copy.")]
        [string]$addr
    )

    if ($ip.count -eq 0) {
        ipinfo.exe myip
    } else {
        nali.exe $DstPath
    }
}
