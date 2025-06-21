<#
.SYNOPSIS
list files with detailed information including size formatting
#>
function ll {
    Get-ChildItem | ForEach-Object {
        $size = $_.Length
        $sizeUnit = "Bytes"

        if ($size -ge 1GB) {
            $size = $size / 1GB
            $sizeUnit = "GB"
        }
        elseif ($size -ge 1MB) {
            $size = $size / 1MB
            $sizeUnit = "MB"
        }
        elseif ($size -ge 1KB) {
            $size = $size / 1KB
            $sizeUnit = "KB"
        }

        [PSCustomObject]@{
            LastWriteTime = $_.LastWriteTime
            Size = "{0:N2} {1}" -f $size, $sizeUnit
            Name = $_.Name
        }
    } | Format-Table
}
