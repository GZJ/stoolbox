import sys
from PyQt5.QtCore import Qt, QEvent, QPoint
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QListWidget, QFrame, QListWidgetItem, QDesktopWidget

class GkList(QWidget):
    def __init__(self, x=None, y=None, width=None, height=None, items=None, title=None, keep_open=False):
        super().__init__()
        self.initUI(x, y, width, height, title)
        self.populate_list(items)
        self.keep_open = keep_open

        self.dragging = False
        self.offset = QPoint()

    def initUI(self, x=None, y=None, width=None, height=None, title=None):
        self.setWindowTitle(title if title else "gk-list")
        self.setWindowFlags(Qt.FramelessWindowHint)

        desktop = QDesktopWidget()
        screen_rect = desktop.screenGeometry()
        screen_width = screen_rect.width()
        screen_height = screen_rect.height()

        window_width = width if width is not None else int(screen_width / 3)  
        window_height = height if height is not None else int(screen_height / 3)

        x = x if x is not None else int((screen_width - window_width) / 2)
        y = y if y is not None else int((screen_height - window_height) / 2)

        self.setGeometry(x, y, window_width, window_height)

        self.frame = QFrame(self)
        self.frame.setGeometry(0, 0, self.width(), self.height())

        layout = QVBoxLayout(self.frame)
        layout.setContentsMargins(0, 0, 0, 0)

        self.list_widget = QListWidget()
        self.list_widget.setStyleSheet("""
        QListView {
            outline: 0;
        }

        QListWidget {
            border : 1px solid green;
            background : black;
        }

        QListWidget QScrollBar {
            background: black;
            color: green;
        }
        QListWidget QScrollBar:vertical, QListWidget QScrollBar:horizontal {
            background-color: green;
        }
        QListWidget QScrollBar::handle:vertical, QListWidget QScrollBar::handle:horizontal {
            background-color: green;
        }
        QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical,
        QScrollBar::add-page:horizontal, QScrollBar::sub-page:horizontal {
            background: none;
        }
        QScrollBar::sub-page:vertical, QScrollBar::sub-page:horizontal {
            background: black;
        }
        QScrollBar::add-page:vertical, QScrollBar::add-page:horizontal {
            background: black;
        }

        QListWidget::item {
            border : 2px solid black;
            color: green;
        }
        QListWidget::item:selected {
            border-style: none;
            border : 2px solid black;
            background : green;
            color: black;
        }
        """)

        layout.addWidget(self.list_widget)
        self.setLayout(layout)

        self.list_widget.installEventFilter(self)
        self.list_widget.viewport().installEventFilter(self)

    def populate_list(self, items):
        if items:
            for item_text in items:
                item = QListWidgetItem(item_text)
                item.setTextAlignment(Qt.AlignCenter)
                self.list_widget.addItem(item)
        
        if self.list_widget.count() > 0:
            self.list_widget.setCurrentRow(0)

    def eventFilter(self, source, event):
        if event.type() == QEvent.MouseButtonPress:
            if event.button() == Qt.LeftButton:
                self.dragging = True
                self.offset = event.pos()
        elif event.type() == QEvent.MouseButtonDblClick:
            if event.button() == Qt.LeftButton:
                self.handle_enter()
        elif event.type() == QEvent.MouseMove:
            if self.dragging:
                self.move(self.mapToParent(event.pos() - self.offset))
        elif event.type() == QEvent.MouseButtonRelease:
            if event.button() == Qt.LeftButton:
                self.dragging = False
        elif event.type() == QEvent.KeyPress:
            key = event.key()
            if key == Qt.Key_J:
                self.move_selection(1)
                return True
            elif key == Qt.Key_K:
                self.move_selection(-1)
                return True
            elif key == Qt.Key_Q:
                QApplication.quit()
                return True
            elif key == Qt.Key_Return or key == Qt.Key_Enter:
                self.handle_enter()
                return True
        return super().eventFilter(source, event)

    def move_selection(self, direction):
        current_row = self.list_widget.currentRow()
        total_rows = self.list_widget.count()
        new_row = (current_row + direction) % total_rows
        self.list_widget.setCurrentRow(new_row)

    def handle_enter(self):
        selected_item = self.list_widget.currentItem()
        if selected_item:
            selected_text = selected_item.text()
            print(selected_text, flush=True)
            if not self.keep_open:
                QApplication.quit()

def parse_args():
    args = sys.argv[1:]
    x, y, width, height, title = None, None, None, None, None
    items = []
    keep_open = False
    i = 0
    while i < len(args):
        if args[i] == '-x' and i + 1 < len(args):
            x = int(args[i + 1])
            i += 2
        elif args[i] == '-y' and i + 1 < len(args):
            y = int(args[i + 1])
            i += 2
        elif args[i] == '-width' and i + 1 < len(args):
            width = int(args[i + 1])
            i += 2
        elif args[i] == '-height' and i + 1 < len(args):
            height = int(args[i + 1])
            i += 2
        elif args[i] == '-title' and i + 1 < len(args):
            title = args[i + 1]
            i += 2
        elif args[i] in ['-k', '--keep-open']:
            keep_open = True
            i += 1
        else:
            items.append(args[i])
            i += 1
    return x, y, width, height, title, keep_open, items

if __name__ == '__main__':
    app = QApplication(sys.argv)

    x, y, width, height, title, keep_open, items = parse_args()

    if not items:
        items = sys.stdin.read().splitlines()

    widget = GkList(x, y, width, height, items, title, keep_open)
    widget.show()
    sys.exit(app.exec_())
