SetTitleMatchMode, 1
WindowTitle := A_Args[1]
NewWidth := A_Args[2]
NewHeight := A_Args[3]

WinMove, %WindowTitle%,,,, %NewWidth%, %NewHeight%
