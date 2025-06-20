<#
.SYNOPSIS

#>
function untar {
    [CmdletBinding()]
    param(
        [string]$filePath,
        [string]$outputPath = (Get-Location)
    )

    if (-not (Test-Path $filePath)) {
        Write-Host "File not found: $filePath"
        return
    }
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $outputPath = Join-Path $outputPath $fileName

    New-Item -ItemType Directory -Path $outputPath -ErrorAction SilentlyContinue | Out-Null

    7z.exe x -Y $filePath -o"$outputPath" | Out-Null
}
