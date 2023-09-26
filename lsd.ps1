function lsd {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]] $filePaths
    )

    foreach ($filePath in $filePaths) {
        $file = Get-Item $filePath

        Write-Host "File: $file"
        Write-Host "Creation Time: $($file.CreationTime)"
        Write-Host "Modification Time: $($file.LastWriteTime)"
        Write-Host "Access Time: $($file.LastAccessTime)"
        Write-Host ""
    }
}
