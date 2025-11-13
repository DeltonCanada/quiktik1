#!/usr/bin/env python3
"""
QuikTik External Device Test Script
==================================

This script demonstrates how to connect your external device to QuikTik.
Run this script while your QuikTik app is running to see live updates!

Requirements:
pip install requests websocket-client

Usage:
python external_device_test.py
"""

import json
import time
import threading
import requests
from datetime import datetime
try:
    import websocket
    WEBSOCKET_AVAILABLE = True
except ImportError:
    WEBSOCKET_AVAILABLE = False
    print("⚠️  websocket-client not installed. Install with: pip install websocket-client")

class QuikTikExternalDevice:
    def __init__(self, device_name="Python Test Device"):
        self.device_name = device_name
        self.device_id = f"python_device_{int(time.time())}"
        self.establishment_id = "est_001"  # Default establishment
        self.ws = None
        self.connected = False
        self.current_serving = 0
        
        print(f"🔌 QuikTik External Device: {self.device_name}")
        print(f"📱 Device ID: {self.device_id}")
        print("-" * 50)
    
    def test_http_api(self):
        """Test HTTP REST API connection"""
        print("🌐 Testing HTTP API Connection...")
        
        try:
            # Test system status
            response = requests.get("http://localhost:8080/api/status", timeout=5)
            if response.status_code == 200:
                data = response.json()
                print(f"✅ HTTP API Connected - Status: {data['status']}")
                print(f"   Connected WebSockets: {data.get('connected_websockets', 0)}")
                print(f"   Registered Devices: {data.get('registered_devices', 0)}")
            else:
                print(f"❌ HTTP API Error: Status {response.status_code}")
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"❌ HTTP API Connection Failed: {e}")
            print("   Make sure QuikTik app is running and services are started!")
            return False
        
        try:
            # Get establishments
            response = requests.get("http://localhost:8080/api/establishments")
            if response.status_code == 200:
                data = response.json()
                establishments = data.get('establishments', [])
                if establishments:
                    self.establishment_id = establishments[0]['id']
                    print(f"🏪 Found establishment: {establishments[0]['name']}")
                else:
                    print("⚠️  No establishments found")
        except:
            pass
        
        try:
            # Get queue status
            response = requests.get(f"http://localhost:8080/api/queue?establishment_id={self.establishment_id}")
            if response.status_code == 200:
                data = response.json()
                self.current_serving = data['current_serving']
                print(f"📊 Queue Status:")
                print(f"   Currently Serving: #{data['current_serving']}")
                print(f"   People Waiting: {data['total_waiting']}")
                print(f"   Available Numbers: {len(data['available_numbers'])}")
            else:
                print(f"⚠️  Queue status unavailable: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"⚠️  Could not get queue status: {e}")
        
        try:
            # Register device
            response = requests.post("http://localhost:8080/api/device/register", 
                json={
                    "device_id": self.device_id,
                    "device_type": "generic",
                    "device_name": self.device_name
                })
            if response.status_code == 200:
                print(f"📱 Device registered successfully")
            else:
                print(f"⚠️  Device registration failed: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"⚠️  Device registration error: {e}")
        
        return True
    
    def advance_queue_http(self):
        """Advance queue using HTTP API"""
        try:
            new_number = self.current_serving + 1
            response = requests.post("http://localhost:8080/api/queue/advance",
                json={
                    "establishment_id": self.establishment_id,
                    "new_serving_number": new_number
                })
            
            if response.status_code == 200:
                self.current_serving = new_number
                print(f"⏭️  Queue advanced to #{new_number} via HTTP API")
                return True
            else:
                print(f"❌ Failed to advance queue: {response.status_code}")
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Queue advance error: {e}")
            return False
    
    def connect_websocket(self):
        """Connect to WebSocket for real-time updates"""
        if not WEBSOCKET_AVAILABLE:
            print("❌ WebSocket not available - install websocket-client")
            return False
        
        print("⚡ Connecting to WebSocket...")
        
        def on_message(ws, message):
            try:
                data = json.loads(message)
                self.handle_websocket_message(data)
            except json.JSONDecodeError:
                print(f"⚠️  Invalid JSON received: {message}")
        
        def on_error(ws, error):
            print(f"❌ WebSocket error: {error}")
            self.connected = False
        
        def on_close(ws, close_status_code, close_msg):
            print("🔌 WebSocket connection closed")
            self.connected = False
        
        def on_open(ws):
            print("✅ WebSocket connected!")
            self.connected = True
            
            # Subscribe to establishment updates
            ws.send(json.dumps({
                "type": "subscribe",
                "establishment_id": self.establishment_id,
                "device_id": self.device_id
            }))
            
            # Send heartbeat every 30 seconds
            def heartbeat():
                while self.connected:
                    time.sleep(30)
                    if self.connected:
                        try:
                            ws.send(json.dumps({"type": "ping", "device_id": self.device_id}))
                            print("💓 Heartbeat sent")
                        except:
                            break
            
            threading.Thread(target=heartbeat, daemon=True).start()
        
        try:
            self.ws = websocket.WebSocketApp("ws://localhost:8081",
                on_open=on_open,
                on_message=on_message,
                on_error=on_error,
                on_close=on_close)
            
            # Run WebSocket in background thread
            wst = threading.Thread(target=self.ws.run_forever, daemon=True)
            wst.start()
            
            # Wait for connection
            time.sleep(2)
            return self.connected
            
        except Exception as e:
            print(f"❌ WebSocket connection failed: {e}")
            return False
    
    def handle_websocket_message(self, data):
        """Handle incoming WebSocket messages"""
        msg_type = data.get('type', 'unknown')
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        if msg_type == 'connected':
            print(f"[{timestamp}] 🎉 Connected to QuikTik WebSocket service")
            
        elif msg_type == 'subscribed':
            print(f"[{timestamp}] 📡 Subscribed to establishment: {data.get('establishment_id')}")
            
        elif msg_type == 'queue_update':
            self.current_serving = data['current_serving']
            print(f"[{timestamp}] 📊 Queue Update:")
            print(f"                Now Serving: #{data['current_serving']}")
            print(f"                People Waiting: {data['total_waiting']}")
            print(f"                Available Numbers: {len(data.get('available_numbers', []))}")
            
        elif msg_type == 'ticket_purchased':
            print(f"[{timestamp}] 🎫 New Ticket Purchased: #{data['queue_number']}")
            print(f"                Amount: ${data['amount']}")
            
        elif msg_type == 'queue_advanced':
            print(f"[{timestamp}] ⏭️  Queue Advanced to #{data['new_serving_number']}")
            
        elif msg_type == 'pong':
            print(f"[{timestamp}] 💓 Heartbeat acknowledged")
            
        else:
            print(f"[{timestamp}] 📨 Message: {msg_type} - {data}")
    
    def advance_queue_websocket(self):
        """Advance queue using WebSocket"""
        if not self.connected or not self.ws:
            print("❌ WebSocket not connected")
            return False
        
        try:
            new_number = self.current_serving + 1
            message = {
                "type": "advance_queue",
                "establishment_id": self.establishment_id,
                "new_serving_number": new_number,
                "device_id": self.device_id
            }
            
            self.ws.send(json.dumps(message))
            print(f"⏭️  Queue advance command sent: #{new_number}")
            return True
            
        except Exception as e:
            print(f"❌ WebSocket advance error: {e}")
            return False
    
    def interactive_menu(self):
        """Interactive menu for testing"""
        while True:
            print("\n" + "="*50)
            print("🎮 QuikTik External Device Test Menu")
            print("="*50)
            print("1. Test HTTP API Connection")
            print("2. Get Current Queue Status")
            print("3. Advance Queue (HTTP)")
            print("4. Connect WebSocket")
            print("5. Advance Queue (WebSocket)")
            print("6. Show Connection Info")
            print("7. Exit")
            print("-"*50)
            
            choice = input("Enter your choice (1-7): ").strip()
            
            if choice == '1':
                self.test_http_api()
                
            elif choice == '2':
                self.get_queue_status()
                
            elif choice == '3':
                self.advance_queue_http()
                
            elif choice == '4':
                if WEBSOCKET_AVAILABLE:
                    self.connect_websocket()
                    if self.connected:
                        print("✅ WebSocket connected! You'll now see real-time updates.")
                        print("   Try purchasing a ticket in the QuikTik app to see live notifications!")
                else:
                    print("❌ WebSocket not available. Install with: pip install websocket-client")
                    
            elif choice == '5':
                self.advance_queue_websocket()
                
            elif choice == '6':
                self.show_connection_info()
                
            elif choice == '7':
                print("👋 Goodbye!")
                if self.ws:
                    self.ws.close()
                break
                
            else:
                print("❌ Invalid choice. Please try again.")
            
            input("\nPress Enter to continue...")
    
    def get_queue_status(self):
        """Get current queue status"""
        try:
            response = requests.get(f"http://localhost:8080/api/queue?establishment_id={self.establishment_id}")
            if response.status_code == 200:
                data = response.json()
                print("📊 Current Queue Status:")
                print(f"   Establishment: {self.establishment_id}")
                print(f"   Currently Serving: #{data['current_serving']}")
                print(f"   People Waiting: {data['total_waiting']}")
                print(f"   Available Numbers: {data['available_numbers']}")
                print(f"   Last Updated: {data['last_updated']}")
            else:
                print(f"❌ Failed to get queue status: {response.status_code}")
        except Exception as e:
            print(f"❌ Error getting queue status: {e}")
    
    def show_connection_info(self):
        """Show connection information"""
        print("🔌 Connection Information:")
        print(f"   Device Name: {self.device_name}")
        print(f"   Device ID: {self.device_id}")
        print(f"   Establishment: {self.establishment_id}")
        print(f"   HTTP API: http://localhost:8080/api")
        print(f"   WebSocket: ws://localhost:8081")
        print(f"   WebSocket Connected: {'✅ Yes' if self.connected else '❌ No'}")
        print(f"   Current Serving: #{self.current_serving}")

def main():
    print("🎫 QuikTik External Device Test Script")
    print("=====================================")
    print()
    print("This script will help you test connecting your external device to QuikTik.")
    print("Make sure your QuikTik Flutter app is running and services are started!")
    print()
    print("Steps to prepare QuikTik:")
    print("1. Run your QuikTik app")
    print("2. Go to Welcome Screen → Establishment Portal")
    print("3. Login with PIN: 1234")
    print("4. Click the antenna icon (External Device Manager)")
    print("5. Click 'Start Services' button")
    print()
    
    device_name = input("Enter your device name (or press Enter for default): ").strip()
    if not device_name:
        device_name = "Python Test Device"
    
    device = QuikTikExternalDevice(device_name)
    
    # Quick connection test
    print("\n🔍 Quick Connection Test...")
    if device.test_http_api():
        print("✅ Ready to go! Your device can connect to QuikTik.")
        
        # Try WebSocket connection
        if WEBSOCKET_AVAILABLE:
            print("\n⚡ Testing WebSocket connection...")
            if device.connect_websocket():
                print("✅ WebSocket connected! You'll see real-time updates.")
        
        # Start interactive menu
        device.interactive_menu()
    else:
        print("❌ Connection failed. Please check:")
        print("   1. QuikTik app is running")
        print("   2. External device services are started")
        print("   3. No firewall blocking ports 8080, 8081, 8082")

if __name__ == "__main__":
    main()