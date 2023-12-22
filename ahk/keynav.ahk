;; ctrl+; for mouse movement, h/j/k/l for navigation.
^;::
  release_focus()
  ToolTip, keynav mode
  ;ToolTip, keynav mode, , , , cFF0000

  Loop {
    If (GetKeyState("h", "P")) {
        MouseMove, -hlx1, hly1, speed, R
    } Else If (GetKeyState("j", "P")) {
        MouseMove, jkx1, jky1, speed, R
    } Else If (GetKeyState("k", "P")) {
        MouseMove, jkx1, -jky1, speed, R
    } Else If (GetKeyState("l", "P")) {
        MouseMove, hlx1, hly1, speed, R
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
