;; get monitors ids.
SysGet, MonitorCount, MonitorCount

Loop, %MonitorCount%
{
    SysGet, Monitor, Monitor, %A_Index%
    
    mx := (MonitorRight - MonitorLeft) / 2 + MonitorLeft
    my := (MonitorBottom - MonitorTop) / 2 + MonitorTop
    
    Gui, New
    Gui, Font, s60 
    Gui, Add, Text,, %A_Index%
    Gui, Show, x%mx% y%my%, %A_Index%
    WinWaitActive, ahk_class AutoHotkeyGUI
}

Sleep 3000
ExitApp
