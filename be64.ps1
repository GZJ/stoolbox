Set-Alias be64 Base64-Encode
function Base64-Encode {
    param (
        [Parameter(Mandatory = $true)]
        [string]$InputString
    )

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
    $base64String = [Convert]::ToBase64String($bytes)
    return $base64String
}
