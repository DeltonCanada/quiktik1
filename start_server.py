#!/usr/bin/env python3
import http.server
import socketserver
import webbrowser
import threading
import time
import os
import sys

PORT = 8080

class QuikTikHTTPServer(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.path.join(os.getcwd(), "build", "web"), **kwargs)
    
    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()

def open_browsers():
    """Open both customer app and establishment portal in browsers"""
    time.sleep(2)  # Wait for server to start
    
    # Open customer app
    webbrowser.open(f'http://localhost:{PORT}')
    
    # Wait a moment then open establishment portal
    time.sleep(1)
    webbrowser.open(f'http://localhost:{PORT}/establishment_portal.html')

def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    # Check if build/web directory exists
    if not os.path.exists("build/web"):
        print("❌ build/web directory not found!")
        print("Run 'flutter build web' first.")
        return 1
    
    try:
        with socketserver.TCPServer(("", PORT), QuikTikHTTPServer) as httpd:
            print(f"🌐 QuikTik Web Server started at http://localhost:{PORT}")
            print(f"📱 Customer App: http://localhost:{PORT}")
            print(f"🏪 Establishment Portal: http://localhost:{PORT}/establishment_portal.html")
            print(f"📺 External Device Interface: http://localhost:{PORT}/external_device_interface.html")
            print("\nPress Ctrl+C to stop the server")
            
            # Open browsers in a separate thread
            browser_thread = threading.Thread(target=open_browsers)
            browser_thread.daemon = True
            browser_thread.start()
            
            httpd.serve_forever()
            
    except KeyboardInterrupt:
        print("\n🛑 Server stopped")
        return 0
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())