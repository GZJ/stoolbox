function lsd {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$filePaths
    )

    if ($filePaths -eq $null -or $filePaths.Count -eq 0) {
        $filePaths = (Get-ChildItem $PWD).FullName
    }

    foreach ($filePath in $filePaths) {
        $file = Get-Item $filePath

        Write-Host "File: $file"
        Write-Host "Creation Time: $($file.CreationTime)"
        Write-Host "Modification Time: $($file.LastWriteTime)"
        Write-Host "Access Time: $($file.LastAccessTime)"
        Write-Host ""
    }
}
