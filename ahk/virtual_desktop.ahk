;; shift+win+j/k : move left/right on virtual desktops.
^#j::
Send ^#{Right}
return

^#k::
Send ^#{Left}
return

;; shift+win+c : close current virtual desktop.
^#c::
Send ^#{F4}
return
