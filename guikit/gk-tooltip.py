import tkinter as tk
from tkinter import ttk
import sys
import threading
import platform

try:
    from pynput import keyboard
    from pynput.mouse import Listener as MouseListener
    PYNPUT_AVAILABLE = True
except ImportError:
    PYNPUT_AVAILABLE = False
    print("Warning: pynput not available. Hotkey functionality will be limited.")

# Cross-platform cursor position function
def get_cursor_pos():
    if PYNPUT_AVAILABLE:
        from pynput.mouse import Listener as MouseListener
        import pynput.mouse as mouse
        controller = mouse.Controller()
        pos = controller.position
        return int(pos[0]), int(pos[1])
    else:
        # Fallback for systems without pynput
        if platform.system() == "Windows":
            try:
                import ctypes
                from ctypes import wintypes
                user32 = ctypes.windll.user32
                
                class POINT(ctypes.Structure):
                    _fields_ = [("x", ctypes.c_long), ("y", ctypes.c_long)]
                
                pt = POINT()
                user32.GetCursorPos(ctypes.byref(pt))
                return pt.x, pt.y
            except:
                pass
        return 100, 100  # Default position

class ToolTipWindow:
    def __init__(self, label_text, exit_key_modifiers, exit_key_code, 
                 fg_color, bg_color, size, font_size, location=None):
        self.root = tk.Tk()
        self.exit_key_modifiers = exit_key_modifiers
        self.exit_key_code = exit_key_code
        self.last_location = None
        self.hotkey_listener = None
        
        # Configure window
        self.root.title("")
        self.root.overrideredirect(True)
        self.root.attributes('-topmost', True)
        self.root.attributes('-toolwindow', True)
        self.root.focus_set()  # Set focus to receive key events
        
        # Set size
        width, height = size
        self.root.geometry(f"{width}x{height}")
        
        # Set position
        if location:
            x, y = location
        else:
            x, y = get_cursor_pos()
        self.root.geometry(f"{width}x{height}+{x}+{y}")
        
        # Configure background
        self.root.configure(bg=bg_color)
        
        # Create label
        self.label = tk.Label(
            self.root,
            text=label_text,
            fg=fg_color,
            bg=bg_color,
            font=("Arial", font_size),
            justify=tk.CENTER
        )
        self.label.pack(expand=True, fill=tk.BOTH)
        
        # Bind events
        self.root.bind("<Button-1>", self.on_mouse_down)
        self.root.bind("<B1-Motion>", self.on_mouse_move)
        self.root.bind("<KeyPress>", self.handle_key_press)
        self.root.bind("<Return>", lambda e: self.on_closing())
        self.root.bind("<Escape>", lambda e: self.on_closing())
        self.label.bind("<Button-1>", self.on_mouse_down)
        self.label.bind("<B1-Motion>", self.on_mouse_move)
        
        # Make window focusable
        self.root.focus_force()
        
        # Handle window close
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        
        # Register hotkey after window is created
        self.root.after(100, self.register_hotkey)
    
    def register_hotkey(self):
        """Register global hotkey using pynput"""
        if not PYNPUT_AVAILABLE:
            print("pynput not available, hotkey registration skipped")
            return
            
        try:
            # Build key combination string for pynput
            hotkey_parts = []
            
            # Add modifiers
            if self.exit_key_modifiers & 0x0002:  # MOD_CONTROL
                hotkey_parts.append('<ctrl>')
            if self.exit_key_modifiers & 0x0001:  # MOD_ALT
                hotkey_parts.append('<alt>')
            if self.exit_key_modifiers & 0x0004:  # MOD_SHIFT
                hotkey_parts.append('<shift>')
            
            # Add main key
            if self.exit_key_code == 0x0D:  # VK_RETURN
                hotkey_parts.append('<enter>')
            elif self.exit_key_code >= ord('A') and self.exit_key_code <= ord('Z'):
                hotkey_parts.append(chr(self.exit_key_code).lower())
            if hotkey_parts:
                # Join with + for pynput format
                hotkey_str = '+'.join(hotkey_parts)
                
                # Register the hotkey
                self.hotkey_listener = keyboard.GlobalHotKeys({
                    hotkey_str: self.on_hotkey_pressed
                })
                self.hotkey_listener.start()
                print(f"Hotkey registered: {hotkey_str}")
                
        except Exception as e:
            print(f"Error registering hotkey: {e}")
    
    def unregister_hotkey(self):
        """Unregister global hotkey"""
        try:
            if self.hotkey_listener:
                self.hotkey_listener.stop()
                self.hotkey_listener = None
        except Exception as e:
            print(f"Error unregistering hotkey: {e}")
    
    def on_hotkey_pressed(self):
        """Handle hotkey press"""
        # Schedule the closing on the main thread
        self.root.after(0, self.on_closing)
    
    def handle_key_press(self, event):
        """Handle key press events"""
        # Check if it's the exit key combination
        if event.keysym == 'Return' or event.keycode == self.exit_key_code:
            self.on_closing()
    
    def on_mouse_down(self, event):
        """Handle mouse down event for dragging"""
        self.last_location = (event.x, event.y)
    
    def on_mouse_move(self, event):
        """Handle mouse move event for dragging"""
        if self.last_location:
            x = self.root.winfo_x() + (event.x - self.last_location[0])
            y = self.root.winfo_y() + (event.y - self.last_location[1])
            self.root.geometry(f"+{x}+{y}")
    
    def on_closing(self):
        """Handle window closing"""
        self.unregister_hotkey()
        self.root.destroy()
    
    def show(self):
        """Show the tooltip window"""
        self.root.mainloop()

def parse_exit_key(key_string):
    """Parse exit key string into modifiers and key code"""
    # Constants for modifiers
    MOD_ALT = 0x0001
    MOD_CONTROL = 0x0002
    MOD_SHIFT = 0x0004
    
    modifiers = 0
    key_code = 0
    parts = key_string.lower().split('+')
    
    for part in parts:
        part = part.strip()
        if part == "ctrl":
            modifiers |= MOD_CONTROL
        elif part == "alt":
            modifiers |= MOD_ALT
        elif part == "shift":
            modifiers |= MOD_SHIFT
        elif len(part) == 1 and part.isalpha():
            key_code = ord(part.upper())
    
    if key_code == 0:
        raise ValueError("Invalid exit key format")
    
    return modifiers, key_code

def parse_color(color_string):
    """Parse color string to hex format"""
    if color_string.startswith("#"):
        return color_string
    
    # Common color names mapping
    color_map = {
        "white": "#FFFFFF",
        "black": "#000000",
        "red": "#FF0000",
        "green": "#008000",
        "blue": "#0000FF",
        "yellow": "#FFFF00",
        "cyan": "#00FFFF",
        "magenta": "#FF00FF",
        "gray": "#808080",
        "grey": "#808080",
        "darkgray": "#404040",
        "darkgrey": "#404040",
        "lightgray": "#C0C0C0",
        "lightgrey": "#C0C0C0"
    }
    
    return color_map.get(color_string.lower(), color_string)

def main():
    """Main function to parse arguments and create tooltip"""
    # Constants
    VK_RETURN = 0x0D
    
    # Default values
    label = "ToolTip"
    exit_key_modifiers = 0
    exit_key_code = VK_RETURN
    fg_color = "#FFFFFF"  # White
    bg_color = "#404040"  # Dark gray (64, 64, 64)
    width = 200
    height = 30
    font_size = 10
    location = None
    
    # Parse command line arguments
    i = 1
    while i < len(sys.argv):
        if i + 1 < len(sys.argv):
            arg = sys.argv[i].lower()
            value = sys.argv[i + 1]
            
            if arg == "--label":
                label = value
            elif arg == "--exit-key":
                exit_key_modifiers, exit_key_code = parse_exit_key(value)
            elif arg == "--fg-color":
                fg_color = parse_color(value)
            elif arg == "--bg-color":
                bg_color = parse_color(value)
            elif arg == "--width":
                width = int(value)
            elif arg == "--height":
                height = int(value)
            elif arg == "--font-size":
                font_size = int(value)
            elif arg == "--x":
                if location is None:
                    location = [0, 0]
                location[0] = int(value)
            elif arg == "--y":
                if location is None:
                    location = [0, 0]
                location[1] = int(value)
            
            i += 2
        else:
            i += 1
    
    # Convert location to tuple if it was set
    if location:
        location = tuple(location)
    
    # Create and show tooltip
    try:
        tooltip = ToolTipWindow(
            label,
            exit_key_modifiers,
            exit_key_code,
            fg_color,
            bg_color,
            (width, height),
            font_size,
            location
        )
        tooltip.show()
    except Exception as e:
        print(f"Error creating tooltip: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
