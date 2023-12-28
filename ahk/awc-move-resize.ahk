SetTitleMatchMode, 1
WindowTitle := A_Args[1]
MoveX := A_Args[2]
MoveY := A_Args[3]
NewWidth := A_Args[4]
NewHeight := A_Args[5]

WinMove, %WindowTitle%,, %MoveX%, %MoveY%, %NewWidth%, %NewHeight%
