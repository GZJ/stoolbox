<#
.SYNOPSIS
copy files to clipboard within the command-line
#>

function gcopy {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromRemainingArguments = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Specify the file(s) to copy."
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Items
    )

    process {
        if (-not ("System.Windows.Forms.Clipboard" -as [type])) {
            Add-Type -AssemblyName System.Windows.Forms
        }
        $Paths = [System.Collections.Specialized.StringCollection]::new()
        foreach ($item in $Items) {
            $path = Get-Item $item
            if ($path) {
                $Paths.Add($path) | Out-Null
                Write-Host "Copy file：$path"
            }
        }
        [System.Windows.Forms.Clipboard]::SetFileDropList($Paths)
    }
}
