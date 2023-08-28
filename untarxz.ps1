function untarxz {
    [CmdletBinding()]
    param(
        [string]$filePath,
        [string]$outputPath = (Get-Location)
    )

    if (-not (Test-Path $filePath)) {
        Write-Host "File not found: $filePath"
        return
    }
    $tarName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $fileName = $tarName -replace '\.tar$',''
    $outputPath = Join-Path $outputPath $fileName
    $outputTarPath = Join-Path $outputPath $tarName

    New-Item -ItemType Directory -Path $outputPath -ErrorAction SilentlyContinue | Out-Null

    7z.exe x -Y $filePath -o"$outputPath" | Out-Null
    7z.exe x -Y $outputTarPath -o"$outputPath" | Out-Null

    Remove-Item $outputTarPath
}
