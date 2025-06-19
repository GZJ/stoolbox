# tui-widgets

`tui-widgets` is a project designed to help command-line programs display data using TUI (Text User Interface). It provides simple tools and examples to make creating intuitive user interfaces in the command line easier.

## Installation

Ensure you have Go installed. You can install `tui-widgets` with the following command:

```
go get -u github.com/gzj/tui-widgets/cmd/tk-list
```

## Usage Examples

`tui-widgets` provides tools to display data in TUI format. Below are some basic usage examples:

Using Pipe to Get Data

```shell
#bash
echo "a b c d" | go run tk-list.go | xargs echo

#pwsh
echo "a b c d" | go run tk-list.go | ForEach-Object { echo $_ }
```

Using Arguments to Get Data

```shell
#bash
go run tk-list.go "a \
b \
c \
d" | xargs echo

#pwsh
go run tk-list.go "a `
b `
c `
d" | ForEach-Object { echo $_ }
```
