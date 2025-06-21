; SYNOPSIS: window minimize control script
SetTitleMatchMode, 1
WindowTitle := A_Args[1]

WinMinimize, %WindowTitle%
