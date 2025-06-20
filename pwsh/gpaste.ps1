<#
.SYNOPSIS

#>
function gpaste {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromRemainingArguments = $true,
            HelpMessage = "Specify the destination path(s) to copy."
        )]
        [string[]]$DstPath = $PWD,

        [Parameter(
            HelpMessage = "Specify the format for returned items. Options: 'text', 'newline', 'comma', 'json'. Default is 'text'."
        )]
        [ValidateSet("text","newline","comma","json")]
        [string]$Format = "text"
    )

    if (-not ("System.Windows.Forms.Clipboard" -as [type])) {
        Add-Type -AssemblyName System.Windows.Forms
    }
    $items = [System.Windows.Forms.Clipboard]::GetFileDropList()

    $result = @()

    if (-not (Test-Path $DstPath)) {
        return
    }
    foreach ($p in $DstPath) {
        foreach ($item in $items) {
            Copy-Item -Recurse $item -Destination $p -Force
            if ($Format -eq "text") {
                $result += "Copied file '$item' to '$p'"
            } else {
                $result += $item
            }
        }
    }
    switch ($Format) {
        "text" { return $result -join "`n" }
        "newline" { return $result -join "`n" }
        "comma" { return "$(($result | ForEach-Object { '"' + $_ + '"' }) -join ',')" }
        "json" { return $result | ConvertTo-Json }
    }
}
