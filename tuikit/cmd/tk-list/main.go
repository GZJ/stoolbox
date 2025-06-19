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
	// retrieve input lines from args or pipe
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
	list := tview.NewList().
		ShowSecondaryText(false)

	for _, line := range inputLines {
		items := strings.Fields(line)
		for _, item := range items {
			list.AddItem(item, "", 0, nil)
		}
	}

	list.SetInputCapture(func(event *tcell.EventKey) *tcell.EventKey {
		switch event.Key() {
		case tcell.KeyCtrlN, tcell.KeyDown:
			list.SetCurrentItem(list.GetCurrentItem() + 1)
			return nil
		case tcell.KeyCtrlP, tcell.KeyUp:
			list.SetCurrentItem(list.GetCurrentItem() - 1)
			return nil
		case tcell.KeyEnter:
			m, _ := list.GetItemText(list.GetCurrentItem())
			app.Stop()

			fmt.Printf("%s", m)
			return nil
		}

		switch event.Rune() {
		case 'j':
			list.SetCurrentItem(list.GetCurrentItem() + 1)
			return nil
		case 'k':
			list.SetCurrentItem(list.GetCurrentItem() - 1)
			return nil
		}

		return event
	})

	if err := app.SetRoot(list, true).SetFocus(list).Run(); err != nil {
		panic(err)
	}
}
