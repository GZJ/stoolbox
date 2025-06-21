<#
.SYNOPSIS
select files in the current working directory using fuzzy matching
#>
function TabCompleteCurrentDir () {
    $item = ""
    fd -H -d 1 | fzf | ForEach-Object { $item = $_ }
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($item)
}

Set-PSReadLineKeyHandler -Chord Alt+t -ScriptBlock { TabCompleteCurrentDir }
