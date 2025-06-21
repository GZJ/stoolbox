; SYNOPSIS: mouse wheel control
;; alt+u/i : scroll up/down with the mouse.
!u::
Loop 1
	Click, WheelDown
return

!i::
Loop 1
	Click, WheelUp
return

;; alt+shift+u/i ：scroll the mouse up/down multiple times.
!+u::
Loop 2
	Click, WheelDown
return

!+i::
Loop 2
	Click, WheelUp
return
