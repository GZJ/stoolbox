jkx1=0
jky1=80
hlx1=80
hly1=0

jkx2=0
jky2=160
hlx2=160
hly2=0

^;::
  release_focus()
  ToolTip, keynav mode

  Loop {
    hlx := hlx1
    hly := hly1
    jkx := jkx1
    jky := jky1

    if GetKeyState("Ctrl", "P") {
        hlx := hlx2
        hly := hly2
        jkx := jkx2
        jky := jky2
    }

    If (GetKeyState("h", "P")) {
        MouseMove, -hlx, hly, speed, R
    } Else If (GetKeyState("j", "P")) {
        MouseMove, jkx, jky, speed, R
    } Else If (GetKeyState("k", "P")) {
        MouseMove, jkx, -jky, speed, R
    } Else If (GetKeyState("l", "P")) {
        MouseMove, hlx, hly, speed, R
    }

    If (GetKeyState("Enter", "P")) {
        click, down
        click, up
        ToolTip
        Break
    }
  }

return

release_focus() {
    hwnd := DllCall("GetDesktopWindow")
    DllCall("SetForegroundWindow", "UInt", hwnd)
}
