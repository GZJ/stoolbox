<#
.SYNOPSIS
remove files and folders to recycle bin safely
#>
function rm {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Items
    )
    
    $shell = New-Object -ComObject Shell.Application
    
    $Items | ForEach-Object {
        $item = $_
        $fullPath = Resolve-Path $item -ErrorAction SilentlyContinue
        
        if ($fullPath) {
            $folder = $shell.Namespace((Split-Path $fullPath -Parent))
            $itemToMove = $folder.ParseName((Split-Path $fullPath -Leaf))
            
            if ($itemToMove) {
                $itemToMove.InvokeVerb('delete')
                Write-Host "Moved to recycle bin: $fullPath" -ForegroundColor Green
            }
        } else {
            Write-Host "Path '$item' does not exist" -ForegroundColor Yellow
        }
    }
}
