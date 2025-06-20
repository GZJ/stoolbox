$template = "README.md.tmpl"
$readme = "README.md"

$templateContent = Get-Content -Path $template -Raw

$synopsisList = @()

Get-ChildItem -Path . -Filter *.ps1 -Recurse | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content -Path $file -Raw

    if ($content -match '<#([\s\S]*?)#>') {
        $commentBlock = $matches[1]

        if ($commentBlock -match '\.SYNOPSIS\s*(.+)') {
            $synopsis = $matches[1].Trim()
            $synopsisList += "- **$($_.BaseName)**: $synopsis"
        }
    }
}

$synopsisText = $synopsisList -join "`n"
$finalContent = $templateContent -replace "{{SYNOPSIS_LIST}}", $synopsisText
Set-Content -Path $readme -Value $finalContent -Encoding UTF8 -NoNewline

Write-Host ".SYNOPSIS sections added to $readme."
