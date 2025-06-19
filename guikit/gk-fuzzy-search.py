import sys
import io
import csv
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QLineEdit, QListWidget, QListWidgetItem
from PyQt5.QtGui import QFont
from PyQt5.QtCore import Qt, QSize, pyqtSignal, QEvent
import argparse

class EditLine(QLineEdit):
    ctrlNPressed = pyqtSignal()
    ctrlPPressed = pyqtSignal()
    escapePressed = pyqtSignal()
    enterPressed = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setPlaceholderText("Search...")
        self.kill_ring = []
        self.installEventFilter(self)

    def eventFilter(self, obj, event):
        if event.type() == QEvent.KeyPress:
            key = event.key()
            modifiers = event.modifiers()

            if key == Qt.Key_Escape:
                self.escapePressed.emit()
                return True
            if key == Qt.Key_Return or key == Qt.Key_Enter:
                self.enterPressed.emit()
                return True

            if modifiers == Qt.ControlModifier:
                if key == Qt.Key_A:
                    self.home(False)
                    return True
                elif key == Qt.Key_E:
                    self.end(False)
                    return True
                elif key == Qt.Key_B:
                    self.cursorBackward(False, 1)
                    return True
                elif key == Qt.Key_F:
                    self.cursorForward(False, 1)
                    return True
                elif key == Qt.Key_K:
                    self.kill_line()
                    return True
                elif key == Qt.Key_W:
                    self.backward_kill_word()
                    return True
                elif key == Qt.Key_Y:
                    self.yank()
                    return True
                elif key == Qt.Key_H:
                    self.backspace()
                    return True
                elif key == Qt.Key_D:
                    self.del_()
                    return True
                elif key == Qt.Key_N:
                    self.ctrlNPressed.emit()
                    return True
                elif key == Qt.Key_P:
                    self.ctrlPPressed.emit()
                    return True
            elif modifiers == Qt.AltModifier:
                if key == Qt.Key_B:
                    self.move_word_backward()
                    return True
                elif key == Qt.Key_F:
                    self.move_word_forward()
                    return True

        return super().eventFilter(obj, event)

    def kill_line(self):
        cursor = self.cursorPosition()
        text = self.text()
        killed_text = text[cursor:]
        self.kill_ring.append(killed_text)
        self.setText(text[:cursor])

    def backward_kill_word(self):
        cursor = self.cursorPosition()
        text = self.text()
        start = cursor

        while start > 0 and text[start-1].isspace():
            start -= 1
        while start > 0 and not text[start-1].isspace():
            start -= 1

        killed_text = text[start:cursor]
        self.kill_ring.append(killed_text)
        new_text = text[:start] + text[cursor:]
        self.setText(new_text)
        self.setCursorPosition(start)

    def yank(self):
        if self.kill_ring:
            self.insert(self.kill_ring[-1])

    def move_word_backward(self):
        cursor = self.cursorPosition()
        text = self.text()
        while cursor > 0 and text[cursor - 1].isspace():
            cursor -= 1
        while cursor > 0 and not text[cursor - 1].isspace():
            cursor -= 1
        self.setCursorPosition(cursor)

    def move_word_forward(self):
        cursor = self.cursorPosition()
        text = self.text()
        while cursor < len(text) and not text[cursor].isspace():
            cursor += 1
        while cursor < len(text) and text[cursor].isspace():
            cursor += 1
        self.setCursorPosition(cursor)

class SearchList(QListWidget):
    itemSelected = pyqtSignal(str)
    escapePressed = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setSpacing(2)
        self.itemClicked.connect(self.item_clicked)
        self.itemDoubleClicked.connect(self.item_double_clicked)
        self.installEventFilter(self)

    def eventFilter(self, obj, event):
        if event.type() == QEvent.KeyPress:
            key = event.key()
            modifiers = event.modifiers()

            if key == Qt.Key_Escape:
                self.escapePressed.emit()
                return True

            if modifiers == Qt.ControlModifier:
                if key == Qt.Key_N:
                    self.select_next()
                    return True
                elif key == Qt.Key_P:
                    self.select_previous()
                    return True
            elif key == Qt.Key_Return:
                self.item_selected(self.currentItem())
                return True

        return super().eventFilter(obj, event)

    def select_next(self):
        current_row = self.currentRow()
        next_row = (current_row + 1) % self.count()
        self.setCurrentRow(next_row)

    def select_previous(self):
        current_row = self.currentRow()
        prev_row = (current_row - 1) % self.count()
        self.setCurrentRow(prev_row)

    def item_clicked(self, item):
        self.setCurrentItem(item)

    def item_double_clicked(self, item):
        self.item_selected(item)

    def item_selected(self, item):
        if item:
            self.itemSelected.emit(item.text())

class AdvancedFuzzySearchWindow(QWidget):
    def __init__(self, x, y, width, height, font, line_bg, line_fg, list_bg, list_fg, keep_running, items):
        super().__init__()
        self.keep_running = keep_running
        self.all_items = items
        self.initUI(x, y, width, height, font, line_bg, line_fg, list_bg, list_fg)
        
    def initUI(self, x, y, width, height, font, line_bg, line_fg, list_bg, list_fg):
        self.setStyleSheet(f'''
            QWidget {{
                background-color: {list_bg};
                color: {list_fg};
                font-family: {font};
            }}
            QLineEdit {{
                border: none;
                padding: 10px;
                background-color: {line_bg};
                color: {line_fg};
                font-size: 16px;
                border: 1px solid #29a329;
            }}
            QListWidget {{
                border: none;
                font-size: 14px;
                border: 1px solid #29a329;
            }}
            QListWidget::item {{
                padding: 10px;
            }}
            QListWidget::item:selected {{
                background-color: #29a329;
            }}
        ''')
        
        layout = QVBoxLayout()
        layout.setSpacing(0)
        layout.setContentsMargins(0, 0, 0, 0)

        self.list_widget = SearchList()
        self.list_widget.itemSelected.connect(self.item_selected)
        self.list_widget.escapePressed.connect(self.close)

        self.search_input = EditLine()
        self.search_input.textChanged.connect(self.update_list)
        self.search_input.ctrlNPressed.connect(self.list_widget.select_next)
        self.search_input.ctrlPPressed.connect(self.list_widget.select_previous)
        self.search_input.escapePressed.connect(self.close)
        self.search_input.enterPressed.connect(
            lambda: self.item_selected(self.list_widget.currentItem().text()) if self.list_widget.currentItem() else None
        )

        layout.addWidget(self.search_input)
        layout.addWidget(self.list_widget)
        
        self.setLayout(layout)
        self.update_list("")
        
        self.setGeometry(x, y, width, height)
        self.setWindowFlags(Qt.FramelessWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground)
        
    def update_list(self, text):
        self.list_widget.clear()
        items = self.all_items if text == "" else [item for item in self.all_items if text.lower() in item.lower()]
        for item in items:
            list_item = QListWidgetItem(item)
            list_item.setSizeHint(QSize(0, 40))
            self.list_widget.addItem(list_item)
        if items:
            self.list_widget.setCurrentRow(0)
            
    def item_selected(self, text):
        print(text, flush=True)
        if not self.keep_running:
            QApplication.quit()
                
    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.dragPosition = event.globalPos() - self.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if event.buttons() == Qt.LeftButton:
            self.move(event.globalPos() - self.dragPosition)
            event.accept()

def main():
    parser = argparse.ArgumentParser(description='Advanced Fuzzy Search UI')
    parser.add_argument('--x', type=int, default=700, help='X position of the window')
    parser.add_argument('--y', type=int, default=300, help='Y position of the window')
    parser.add_argument('--width', type=int, default=400, help='Width of the window')
    parser.add_argument('--height', type=int, default=500, help='Height of the window')
    parser.add_argument('--font', type=str, default='Arial', help='Font family')
    parser.add_argument('--line-bg', type=str, default='#000000', help='Background color of the line edit')
    parser.add_argument('--line-fg', type=str, default='#29a329', help='Foreground color of the line edit')
    parser.add_argument('--list-bg', type=str, default='#000000', help='Background color of the list')
    parser.add_argument('--list-fg', type=str, default='#29a329', help='Foreground color of the list')
    parser.add_argument('--keep', action='store_true', help='Keep the program running after selection')
    parser.add_argument('--items', type=str, help='Comma-separated list of items')

    args = parser.parse_args()

    if args.items:
        items_list = list(csv.reader(io.StringIO(args.items)))[0]
    else:
        if sys.stdin.isatty():
            print("Error: No items provided. Please use --items or pipe in a list of items.", file=sys.stderr)
            sys.exit(1)
        items_list = [line.strip() for line in sys.stdin]

    app = QApplication(sys.argv)

    screen = app.primaryScreen().geometry()
    
    window_center_x = args.width // 2
    window_center_y = args.height // 2
    x = (screen.width() // 2) - (args.width // 2)
    y = (screen.height() // 2) - (args.height // 2)

    window = AdvancedFuzzySearchWindow(x, y, args.width, args.height, args.font, 
                                       args.line_bg, args.line_fg, args.list_bg, args.list_fg, 
                                       args.keep, items_list)

    window.show()
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()
