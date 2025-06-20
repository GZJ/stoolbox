<#
.SYNOPSIS

#>
function timer {
    if ($args.count -eq 0) {
        Write-Output "no args"
    } else {
        $t = $args[0]
        $cmd = $args[1]
        for ([int]$i = 0; $i -le $t; $i++) {
            #Write-Progress -Activity "Running a logn Task" -Status "$i% Complete:" -PercentComplete $i;
            Write-Status -Current $i -Total $t -Statustext "Running a long Task" -CurStatusText "Working on Position $i"
            sleep 1
        }
        Invoke-Expression $cmd
    }
}
