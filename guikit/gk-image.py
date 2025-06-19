import sys
import argparse
from PyQt5.QtWidgets import QApplication, QLabel, QMainWindow
from PyQt5.QtCore import Qt, QThread, pyqtSignal
from PyQt5.QtGui import QPixmap, QColor, QPalette


class StdinReader(QThread):
    image_received = pyqtSignal(str)

    def run(self):
        while True:
            try:
                line = sys.stdin.readline()
                if line:
                    self.image_received.emit(line.strip())
            except Exception:
                break

class ImageWindow(QMainWindow):
    def __init__(self, args):
        super().__init__()
        self.setWindowFlags(
            Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
            if args.always_on_top
            else Qt.FramelessWindowHint
        )
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.setGeometry(0, 0, args.width, args.height)
        self.setWindowTitle(args.title)
        self.label = QLabel(self)
        self.label.setAlignment(Qt.AlignCenter)
        self.label.setGeometry(0, 0, args.width, args.height)
        self.label.setStyleSheet(
            f"border: 2px solid green; background-color: {args.bg_color};"
        )
        self.stdin_thread = StdinReader()
        self.stdin_thread.image_received.connect(self.update_image)
        self.stdin_thread.start()
        self.target_x = args.x
        self.target_y = args.y

    def showEvent(self, event):
        super().showEvent(event)
        if self.target_x is not None and self.target_y is not None:
            self.move(self.target_x, self.target_y)

    def keyPressEvent(self, event):
        if event.key() == Qt.Key_Q:
            QApplication.quit()
        super().keyPressEvent(event)

    def update_image(self, file_path):
        try:
            pixmap = QPixmap(file_path)
            if pixmap.isNull():
                raise ValueError(f"Cannot load image: {file_path}")
            self.label.setPixmap(
                pixmap.scaled(
                    self.label.width(),
                    self.label.height(),
                    Qt.KeepAspectRatio,
                    Qt.SmoothTransformation,
                )
            )
        except Exception as e:
            print(f"Failed to load image: {e}", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(description="gk-image")
    parser.add_argument("--title", default="gk-fimage", help="Window title")
    parser.add_argument("--width", type=int, default=800, help="Width of the window")
    parser.add_argument("--height", type=int, default=600, help="Height of the window")
    parser.add_argument("--x", type=int, default=100, help="X position of the window")
    parser.add_argument("--y", type=int, default=100, help="Y position of the window")
    parser.add_argument(
        "--bg-color", default="black", help="Background color of the window"
    )
    parser.add_argument(
        "--always-on-top", action="store_true", help="Keep the window always on top"
    )
    args = parser.parse_args()
    app = QApplication(sys.argv)
    window = ImageWindow(args)
    window.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
