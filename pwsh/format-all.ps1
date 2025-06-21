<#
.SYNOPSIS
format all PowerShell scripts in current directory recursively
#>
Get-ChildItem -Path . -Include *.ps1,*.psm1 -Recurse | Edit-DTWBeautifyScript -IndentType FourSpaces
