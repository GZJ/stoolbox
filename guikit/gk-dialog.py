import sys
from PyQt5.QtCore import Qt, QEvent, QPoint
from PyQt5.QtWidgets import (QApplication, QDialog, QVBoxLayout, QLabel, 
                           QFrame, QDesktopWidget, QPushButton, QHBoxLayout)

class GkDialog(QDialog):
    def __init__(self, x=None, y=None, width=None, height=None, message=None, 
                 title=None):
        super().__init__()
        self.initUI(x, y, width, height, title)
        self.set_message(message)
        self.dragging = False
        self.offset = QPoint()
        self.result = False

    def initUI(self, x=None, y=None, width=None, height=None, title=None):
        self.setWindowTitle(title if title else "gk-dialog")
        self.setWindowFlags(Qt.FramelessWindowHint)

        desktop = QDesktopWidget()
        screen_rect = desktop.screenGeometry()
        screen_width = screen_rect.width()
        screen_height = screen_rect.height()

        window_width = width if width is not None else 300
        window_height = height if height is not None else 200

        x = x if x is not None else int((screen_width - window_width) / 2)
        y = y if y is not None else int((screen_height - window_height) / 2)

        self.setGeometry(x, y, window_width, window_height)

        self.frame = QFrame(self)
        self.frame.setGeometry(0, 0, self.width(), self.height())
        self.frame.setStyleSheet("QFrame {background: black; border: 2px solid green;}")

        layout = QVBoxLayout(self.frame)
        
        self.message_label = QLabel()
        self.message_label.setWordWrap(True)
        self.message_label.setAlignment(Qt.AlignCenter)
        self.message_label.setStyleSheet("QLabel {color: green; font-size: 12pt; padding: 10px;}")

        button_layout = QHBoxLayout()
        button_style = """
            QPushButton {
                background-color: black;
                color: green;
                border: 1px solid green;
                padding: 5px;
                min-width: 80px;
            }
            QPushButton:hover {
                background-color: green;
                color: black;
            }
        """

        self.yes_button = QPushButton("Yes")
        self.yes_button.setStyleSheet(button_style)
        self.yes_button.clicked.connect(self.handle_yes)

        self.no_button = QPushButton("No")
        self.no_button.setStyleSheet(button_style)
        self.no_button.clicked.connect(self.handle_no)

        button_layout.addWidget(self.yes_button)
        button_layout.addWidget(self.no_button)

        layout.addWidget(self.message_label)
        layout.addLayout(button_layout)

        self.setLayout(layout)

        self.frame.installEventFilter(self)
        self.message_label.installEventFilter(self)

    def set_message(self, message):
        if message:
            self.message_label.setText(message)

    def eventFilter(self, source, event):
        if event.type() == QEvent.MouseButtonPress:
            if event.button() == Qt.LeftButton:
                self.dragging = True
                self.offset = event.pos()
        elif event.type() == QEvent.MouseMove:
            if self.dragging:
                self.move(self.mapToParent(event.pos() - self.offset))
        elif event.type() == QEvent.MouseButtonRelease:
            if event.button() == Qt.LeftButton:
                self.dragging = False
        elif event.type() == QEvent.KeyPress:
            key = event.key()
            if key == Qt.Key_Q:
                self.handle_no()
                return True
            elif key == Qt.Key_Return or key == Qt.Key_Enter:
                self.handle_yes()
                return True
            elif key == Qt.Key_Escape:
                self.handle_no()
                return True
            elif key == Qt.Key_Y:
                self.handle_yes()
                return True
            elif key == Qt.Key_N:
                self.handle_no()
                return True
        return super().eventFilter(source, event)

    def handle_yes(self):
        self.result = True
        print("yes", flush=True)
        QApplication.quit()

    def handle_no(self):
        self.result = False
        print("no", flush=True)
        QApplication.quit()

def parse_args():
    args = sys.argv[1:]
    x, y, width, height, title = None, None, None, None, None
    message = ""
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
        else:
            message += args[i] + " "
            i += 1
            
    return x, y, width, height, title, message.strip()

if __name__ == '__main__':
    app = QApplication(sys.argv)

    x, y, width, height, title, message = parse_args()

    if not message and not sys.stdin.isatty():
        message = sys.stdin.read().strip()

    dialog = GkDialog(x, y, width, height, message, title)
    dialog.show()

    sys.exit(app.exec_())
