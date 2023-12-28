SetTitleMatchMode, 1
WindowTitle := A_Args[1]
MoveX := A_Args[2]
MoveY := A_Args[3]

WinMove, %WindowTitle%,, %MoveX%, %MoveY%
