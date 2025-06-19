import sys
import os
from PyQt5.QtWidgets import QApplication, QMainWindow
from PyQt5.QtWebEngineWidgets import QWebEngineView
from PyQt5.QtCore import QUrl, Qt
from PyQt5.QtNetwork import QNetworkProxy
from PyQt5.QtCore import QUrlQuery
import argparse
from urllib.parse import urlparse
from pathlib import Path

APP_NAME = "gk-webengine"

class WebEngineViewer(QMainWindow):
    def __init__(self, x, y, width, height, url):
        super().__init__()
        self.setGeometry(x, y, width, height)
        self.setWindowTitle(APP_NAME)
        self.web_view = QWebEngineView(self)
        self.web_view.setGeometry(0, 0, width, height)
        try:
            self.load_url(url)
        except (FileNotFoundError, ValueError) as e:
            print(f"Error: {str(e)}")
            sys.exit(1)
    
    def load_url(self, url):
        if not url:
            raise ValueError("URL cannot be empty")
        
        parsed = urlparse(url)
        path = Path(url)
        is_local = False
        
        if not parsed.scheme or parsed.scheme == 'file':
            if path.is_absolute() or path.is_relative_to('.') or path.exists():
                is_local = True
        
        if is_local:
            if not path.exists():
                raise FileNotFoundError(f"File not found: {url}")
                
            if path.is_relative_to('.'):
                path = Path(__file__).parent / path.relative_to('.')
            
            file_url = QUrl.fromLocalFile(str(path.resolve()))
            self.web_view.setUrl(file_url)
        else:
            if not parsed.scheme:
                url = 'https://' + url
            
            try:
                parsed = urlparse(url)
                if not bool(parsed.netloc) or not bool(parsed.scheme):
                    raise ValueError(f"Invalid URL: {url}")
                
                self.web_view.setUrl(QUrl(url))
            except Exception:
                raise ValueError(f"Invalid URL: {url}")
    
    def keyPressEvent(self, event):
        if event.key() == Qt.Key_Q:
            self.close()
        else:
            super().keyPressEvent(event)

def main():
    parser = argparse.ArgumentParser(description=APP_NAME)
    parser.add_argument('--x', type=int, default=100, help='Window X position')
    parser.add_argument('--y', type=int, default=100, help='Window Y position')
    parser.add_argument('--width', type=int, default=800, help='Window width')
    parser.add_argument('--height', type=int, default=600, help='Window height')
    parser.add_argument('--url', type=str, help='URL or file path to load map')
    parser.add_argument('--proxy-host', type=str, default='127.0.0.1', help='Proxy host address(http)')
    parser.add_argument('--proxy-port', type=int, default=1080, help='Proxy port number')
    parser.add_argument('--proxy-enabled', action='store_true', help='Enable proxy settings')
    
    args = parser.parse_args()
    
    app = QApplication(sys.argv)
    
    if args.proxy_enabled:
        proxy = QNetworkProxy()
        proxy.setType(QNetworkProxy.HttpProxy)
        proxy.setHostName(args.proxy_host)
        proxy.setPort(args.proxy_port)
        QNetworkProxy.setApplicationProxy(proxy)
        print(f"Proxy set to {args.proxy_host}:{args.proxy_port}")
    
    viewer = WebEngineViewer(
        x=args.x,
        y=args.y,
        width=args.width,
        height=args.height,
        url=args.url
    )
    viewer.show()
    
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()
