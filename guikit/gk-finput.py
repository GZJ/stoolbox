import sys
import argparse
from PyQt5.QtWidgets import QApplication, QWidget, QLineEdit, QDesktopWidget
from PyQt5.QtCore import Qt, QEvent, pyqtSignal
from PyQt5.QtGui import QFocusEvent, QKeyEvent, QFont

class EmacsLineEdit(QLineEdit):
    returnPressed = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setContextMenuPolicy(Qt.NoContextMenu)

    def keyPressEvent(self, event: QKeyEvent) -> None:
        if event.key() == Qt.Key_Return or event.key() == Qt.Key_Enter:
            self.returnPressed.emit(self.text())
            return
        if event.modifiers() & Qt.ControlModifier:
            key = event.key()
            if key == Qt.Key_B:
                self.cursorBackward(False)
            elif key == Qt.Key_F:
                self.cursorForward(False)
            elif key == Qt.Key_A:
                self.home(False)
            elif key == Qt.Key_E:
                self.end(False)
            elif key == Qt.Key_D:
                self.del_()
            elif key == Qt.Key_H:
                self.backspace()
            elif key == Qt.Key_K:
                self.deleteEndOfLine()
            elif key == Qt.Key_U:
                self.deleteStartOfLine()
            elif key == Qt.Key_W:
                self.cut()
            elif key == Qt.Key_Y:
                self.paste()
            else:
                super().keyPressEvent(event)
        elif event.modifiers() & Qt.AltModifier:
            key = event.key()
            if key == Qt.Key_B:
                self.cursorWordBackward(False)
            elif key == Qt.Key_F:
                self.cursorWordForward(False)
            elif key == Qt.Key_D:
                self.deleteWordForward()
            else:
                super().keyPressEvent(event)
        else:
            super().keyPressEvent(event)

    def deleteEndOfLine(self):
        self.setSelection(self.cursorPosition(), len(self.text()))
        self.cut()

    def deleteStartOfLine(self):
        self.setSelection(0, self.cursorPosition())
        self.cut()

    def deleteWordForward(self):
        end = self.cursorPosition()
        while end < len(self.text()) and not self.text()[end].isspace():
            end += 1
        self.setSelection(self.cursorPosition(), end)
        self.cut()

class FloatingInputWindow(QWidget):
    def __init__(self, title, width, height, x, y, bg_color, font_color, font_size, font_family, keep_open):
        super().__init__()
        self.setWindowTitle(title)
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.bg_color = bg_color
        self.font_color = font_color
        self.font_size = font_size
        self.font_family = font_family
        self.keep_open = keep_open
        self.initUI()

    def initUI(self):
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint)
        self.setAttribute(Qt.WA_TranslucentBackground)
        
        if self.x is None or self.y is None:
            self.center()
        else:
            self.setGeometry(self.x, self.y, self.width, self.height)

        self.search_input = EmacsLineEdit(self)
        self.search_input.setGeometry(0, 0, self.width, self.height)

        font = QFont(self.font_family, self.font_size)
        self.search_input.setFont(font)

        self.search_input.setStyleSheet(f"""
            QLineEdit {{
                border: 2px solid #4a4a4a;
                border-radius: {self.height // 2}px;
                padding: 0 15px;
                background-color: {self.bg_color};
                color: {self.font_color};
            }}
            QLineEdit:focus {{
                border-color: #00ff00;
            }}
        """)

        self.search_input.setPlaceholderText("Emacs keybindings enabled...")
        self.search_input.setFocus()
        
        self.search_input.returnPressed.connect(self.return_selection)

        self.installEventFilter(self)

    def center(self):
        qr = self.frameGeometry()
        cp = QDesktopWidget().availableGeometry().center()
        qr.moveCenter(cp)
        self.move(qr.topLeft())

    def eventFilter(self, obj, event):
        if event.type() == QEvent.KeyPress:
            if event.key() == Qt.Key_Escape:
                self.close()
                return True
        return super().eventFilter(obj, event)

    def focusOutEvent(self, event: QFocusEvent) -> None:
        if not self.keep_open:
            self.close()
        super().focusOutEvent(event)

    def return_selection(self, text):
        print(f"{text}", flush=True)
        if not self.keep_open:
            self.close()
        else:
            self.search_input.clear()
            self.search_input.setFocus()

def parse_arguments():
    parser = argparse.ArgumentParser(description="Customizable Floating Search Window")
    parser.add_argument("--title", default="gk-finput", help="Window title")
    parser.add_argument("--width", type=int, default=1000, help="Width of the search window")
    parser.add_argument("--height", type=int, default=50, help="Height of the search window")
    parser.add_argument("--x", type=int, default=None, help="X position of the search window")
    parser.add_argument("--y", type=int, default=None, help="Y position of the search window")
    parser.add_argument("--bg-color", default="rgba(0, 0, 0, 255)", help="Background color of the search window")
    parser.add_argument("--font-color", default="#00ff00", help="Font color of the search text")
    parser.add_argument("--font-size", type=int, default=16, help="Font size of the search text")
    parser.add_argument("--font-family", default="Arial", help="Font family of the search text")
    parser.add_argument("-k", "--keep-open", action="store_true", help="Keep the window open after selection")
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_arguments()
    app = QApplication(sys.argv)
    mainWin = FloatingInputWindow(
        title=args.title,
        width=args.width,
        height=args.height,
        x=args.x,
        y=args.y,
        bg_color=args.bg_color,
        font_color=args.font_color,
        font_size=args.font_size,
        font_family=args.font_family,
        keep_open=args.keep_open
    )
    mainWin.show()
    sys.exit(app.exec_())
