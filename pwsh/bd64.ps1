<#
.SYNOPSIS
base64 decode tool
#>
function Base64-Decode {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Base64String
    )

    $bytes = [Convert]::FromBase64String($Base64String)
    $decodedString = [System.Text.Encoding]::UTF8.GetString($bytes)
    return $decodedString
}

Set-Alias bd64 Base64-Decode
