; SYNOPSIS: window focus control script
SetTitleMatchMode, 1
WindowTitle := A_Args[1]

WinActivate, %WindowTitle%
