package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
)

func main() {
	var inputLines []string
	stat, _ := os.Stdin.Stat()
	if (stat.Mode() & os.ModeCharDevice) == 0 {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			inputLines = append(inputLines, scanner.Text())
		}
	} else {
		inputLines = os.Args[1:]
	}

	app := tview.NewApplication()
	table := tview.NewTable().
		SetBorders(true)

	for row, line := range inputLines {
		cols := strings.Fields(line)
		for col, cell := range cols {
			table.SetCell(row, col,
				tview.NewTableCell(cell).
					SetTextColor(tcell.ColorWhite).
					SetAlign(tview.AlignCenter))
		}
	}

	updateColors := func() {
		rows, cols := table.GetRowCount(), table.GetColumnCount()
		selectedRow, selectedCol := table.GetSelection()
		for row := 0; row < rows; row++ {
			for col := 0; col < cols; col++ {
				cell := table.GetCell(row, col)
				if cell == nil {
					continue
				}
				if row == selectedRow && col == selectedCol {
					cell.SetTextColor(tcell.ColorYellow).SetBackgroundColor(tcell.ColorNavy)
				} else {
					cell.SetTextColor(tcell.ColorWhite).SetBackgroundColor(tcell.ColorDefault)
				}
			}
		}
	}

	updateColors()

	moveSelection := func(rowDelta, colDelta int) {
		row, col := table.GetSelection()
		newRow, newCol := row+rowDelta, col+colDelta
		rowCount, colCount := table.GetRowCount(), table.GetColumnCount()

		if newRow >= 0 && newRow < rowCount && newCol >= 0 && newCol < colCount {
			table.Select(newRow, newCol)
		}
	}

	table.SetSelectionChangedFunc(func(row, col int) {
		updateColors()
	})

	table.SetInputCapture(func(event *tcell.EventKey) *tcell.EventKey {
		switch event.Key() {
		case tcell.KeyCtrlN, tcell.KeyDown:
			moveSelection(1, 0)
			return nil
		case tcell.KeyCtrlP, tcell.KeyUp:
			moveSelection(-1, 0)
			return nil
		case tcell.KeyTab, tcell.KeyRight:
			moveSelection(0, 1)
			return nil
		case tcell.KeyBacktab, tcell.KeyLeft:
			moveSelection(0, -1)
			return nil
		case tcell.KeyEnter:
			row, col := table.GetSelection()
			cell := table.GetCell(row, col)
			if cell != nil {
				app.Stop()
				fmt.Printf("%s", cell.Text)
			}
			return nil
		}
		switch event.Rune() {
		case 'j':
			moveSelection(1, 0)
			return nil
		case 'k':
			moveSelection(-1, 0)
			return nil
		case 'l':
			moveSelection(0, 1)
			return nil
		case 'h':
			moveSelection(0, -1)
			return nil
		}
		return event
	})

	if err := app.SetRoot(table, true).SetFocus(table).Run(); err != nil {
		panic(err)
	}
}
