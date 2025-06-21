<#
.SYNOPSIS
move untracked git files to 'z' directory for cleanup
#>
$untrackedFiles = git ls-files --others --exclude-standard

# 创建目录（如果不存在）
$destinationDirectory = "z"
New-Item -ItemType Directory -Force -Path $destinationDirectory | Out-Null

# 移动文件到目标目录
foreach ($file in $untrackedFiles) {
      if ($file -ne "clear.ps1") {
        $destinationPath = Join-Path $destinationDirectory (Split-Path $file -Leaf)
        Move-Item -Path $file -Destination $destinationPath
    }
}

Write-Host "Untracked files moved to '$destinationDirectory' directory."
