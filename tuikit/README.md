# tuikit


## Usage Examples

`tuikit` provides tools to display data in TUI format. Below are some basic usage examples:

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
