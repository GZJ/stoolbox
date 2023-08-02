function gpaste {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromRemainingArguments = $true,
            HelpMessage = "Specify the destination path(s) to copy."
        )]
        [string[]]$DstPath = $PWD
    )

    if (-not ("System.Windows.Forms.Clipboard" -as [type])) {
        Add-Type -AssemblyName System.Windows.Forms
    }
    $items = [System.Windows.Forms.Clipboard]::GetFileDropList()

    foreach ($p in $DstPath) {
        foreach ($item in $items) {
            Copy-Item -Recurse $item -Destination $p -Force
            Write-Host "Copied file '$item' to '$p'"
        }
    }
}
