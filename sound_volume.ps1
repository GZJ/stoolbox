function sound_volume {
    while ($true) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($key.VirtualKeyCode -eq 0x4A) {
            Write-Host "volume down"
            (New-Object -com wscript.shell).SendKeys([char]174)
        }
        if ($key.VirtualKeyCode -eq 0x4B) {
            Write-Host "volume up"
            (New-Object -com wscript.shell).SendKeys([char]175)
        }
    }
}
