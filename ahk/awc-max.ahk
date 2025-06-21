; SYNOPSIS: window maximize control script
SetTitleMatchMode, 1
WindowTitle := A_Args[1]

WinMaximize, %WindowTitle%
