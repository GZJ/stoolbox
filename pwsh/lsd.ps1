<#
.SYNOPSIS
displays file timestamps (creation, modification, access times) for specified files
#>
function lsd {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$filePaths
    )

    if ($filePaths -eq $null -or $filePaths.Count -eq 0) {
        $filePaths = (Get-ChildItem $PWD).FullName
    }

    $result = foreach ($filePath in $filePaths) {
        $file = Get-Item $filePath

        [PSCustomObject]@{
            File = $file.Name
            CreationTime = $file.CreationTime
            LastWriteTime = $file.LastWriteTime
            LastAccessTime = $file.LastAccessTime
        }
    }

    $result | Format-Table
}
