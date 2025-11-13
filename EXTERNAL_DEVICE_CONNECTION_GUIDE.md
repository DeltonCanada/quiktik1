# 🔌 QuikTik External Device Connection Guide

## Quick Start - Connect Your Device in 3 Steps

### Step 1: Start QuikTik Services
1. Run your QuikTik Flutter app
2. Go to **Welcome Screen** → **Establishment Portal**  
3. Login with PIN: **1234**
4. Click the **antenna icon** (External Device Manager)
5. Click **"Start Services"** button

✅ **Services Now Running:**
- HTTP API: `http://localhost:8080/api`
- WebSocket: `ws://localhost:8081` 
- TCP Server: `localhost:8082`

### Step 2: Choose Your Connection Method

#### 🌐 **Option A: Web Browser (Easiest)**
1. Open the file: `web/external_device_interface.html` in any browser
2. Automatically connects and shows live queue status
3. Use buttons to advance queue and control system

#### 📱 **Option B: Custom App/Device**
Use the API endpoints below for your own application

#### 🔧 **Option C: Hardware Device**
Connect via TCP socket for embedded systems

### Step 3: Test the Connection
- Your device should appear in the External Device Manager
- Real-time queue updates will flow to your device
- You can control the queue from your external device

---

## 🌐 Web Browser Connection (Instant Setup)

**Perfect for: Tablets, iPads, any device with a web browser**

1. **Navigate to the HTML file:**
   ```
   file:///C:/QuikTik/quiktik1/web/external_device_interface.html
   ```

2. **Or host it on a web server:**
   ```bash
   # Simple Python web server
   cd C:\QuikTik\quiktik1\web
   python -m http.server 3000
   # Then open: http://localhost:3000/external_device_interface.html
   ```

3. **Features you get:**
   - ✅ Real-time queue status display
   - ✅ "Next Customer" button to advance queue
   - ✅ Live activity log
   - ✅ Automatic reconnection
   - ✅ Works on any device with a browser

---

## 📡 HTTP REST API Connection

**Perfect for: Mobile apps, web applications, server integrations**

### Base URL: `http://localhost:8080/api`

### 🔍 **Get System Status**
```http
GET /api/status
```
```json
{
  "status": "online",
  "version": "1.0.0",
  "connected_websockets": 2,
  "connected_tcp_clients": 1,
  "registered_devices": 3
}
```

### 🏪 **Get All Establishments**
```http
GET /api/establishments
```
```json
{
  "establishments": [
    {
      "id": "est_001",
      "name": "Innovation Credit Union",
      "address": "1330 20th St W, Saskatoon, SK",
      "status": "open"
    }
  ]
}
```

### 📊 **Get Queue Status**
```http
GET /api/queue?establishment_id=est_001
```
```json
{
  "establishment_id": "est_001",
  "current_serving": 25,
  "available_numbers": [28, 29, 30, 31, 32],
  "total_waiting": 12,
  "last_updated": "2025-10-27T10:30:00Z"
}
```

### ⏭️ **Advance Queue**
```http
POST /api/queue/advance
Content-Type: application/json

{
  "establishment_id": "est_001",
  "new_serving_number": 26
}
```

### 🎫 **Get Tickets**
```http
GET /api/tickets?establishment_id=est_001
```

### 📱 **Register Your Device**
```http
POST /api/device/register
Content-Type: application/json

{
  "device_id": "my_tablet_001",
  "device_type": "tablet",
  "device_name": "Reception Tablet"
}
```

---

## ⚡ WebSocket Real-Time Connection

**Perfect for: Live updates, real-time displays, instant notifications**

### JavaScript Example:
```javascript
// Connect to WebSocket
const ws = new WebSocket('ws://localhost:8081');

// Handle connection
ws.onopen = function() {
    console.log('Connected to QuikTik!');
    
    // Register your device
    ws.send(JSON.stringify({
        type: 'subscribe',
        establishment_id: 'est_001',
        device_id: 'my_device_123'
    }));
};

// Handle real-time messages
ws.onmessage = function(event) {
    const data = JSON.parse(event.data);
    
    switch(data.type) {
        case 'queue_update':
            console.log('Queue Update:', data);
            // Update your display:
            document.getElementById('currentServing').textContent = data.current_serving;
            document.getElementById('totalWaiting').textContent = data.total_waiting;
            break;
            
        case 'ticket_purchased':
            console.log('New ticket purchased:', data.queue_number);
            // Show notification or update display
            break;
    }
};

// Send commands to QuikTik
function advanceQueue() {
    ws.send(JSON.stringify({
        type: 'advance_queue',
        establishment_id: 'est_001',
        new_serving_number: currentNumber + 1
    }));
}
```

---

## 🔧 TCP Direct Connection

**Perfect for: Embedded systems, Arduino, Raspberry Pi, hardware devices**

### Python Example:
```python
import socket
import json
import threading

class QuikTikDevice:
    def __init__(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.connected = False
    
    def connect(self):
        try:
            self.socket.connect(('localhost', 8082))
            self.connected = True
            print("Connected to QuikTik TCP server")
            
            # Start listening for messages
            threading.Thread(target=self.listen, daemon=True).start()
            
        except Exception as e:
            print(f"Connection failed: {e}")
    
    def listen(self):
        while self.connected:
            try:
                data = self.socket.recv(1024).decode('utf-8')
                if data:
                    message = json.loads(data.strip())
                    self.handle_message(message)
            except Exception as e:
                print(f"Listen error: {e}")
                break
    
    def handle_message(self, message):
        if message['type'] == 'queue_update':
            print(f"Queue update: Now serving #{message['current_serving']}")
        elif message['type'] == 'connected':
            print("Successfully connected to QuikTik")
    
    def send_message(self, message):
        if self.connected:
            self.socket.send((json.dumps(message) + '\n').encode('utf-8'))
    
    def get_queue_status(self, establishment_id):
        self.send_message({
            'type': 'get_queue',
            'establishment_id': establishment_id
        })
    
    def advance_queue(self, establishment_id, new_number):
        self.send_message({
            'type': 'advance',
            'establishment_id': establishment_id,
            'new_serving_number': new_number
        })

# Usage
device = QuikTikDevice()
device.connect()
device.get_queue_status('est_001')
device.advance_queue('est_001', 26)
```

---

## 📱 Mobile App Integration

### React Native Example:
```javascript
import { useState, useEffect } from 'react';

export default function QuikTikIntegration() {
    const [queueStatus, setQueueStatus] = useState(null);
    const [ws, setWs] = useState(null);
    
    useEffect(() => {
        // Connect to WebSocket
        const websocket = new WebSocket('ws://localhost:8081');
        
        websocket.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.type === 'queue_update') {
                setQueueStatus(data);
            }
        };
        
        setWs(websocket);
        
        return () => websocket.close();
    }, []);
    
    const advanceQueue = () => {
        if (ws) {
            ws.send(JSON.stringify({
                type: 'advance_queue',
                establishment_id: 'est_001',
                new_serving_number: queueStatus.current_serving + 1
            }));
        }
    };
    
    return (
        <View>
            <Text>Now Serving: #{queueStatus?.current_serving}</Text>
            <Text>People Waiting: {queueStatus?.total_waiting}</Text>
            <Button title="Next Customer" onPress={advanceQueue} />
        </View>
    );
}
```

---

## 🛠️ Arduino/ESP32 Integration

```cpp
#include <WiFi.h>
#include <WebSocketsClient.h>
#include <ArduinoJson.h>

WebSocketsClient webSocket;

void setup() {
    Serial.begin(115200);
    
    // Connect to WiFi
    WiFi.begin("your_wifi", "password");
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.println("Connecting...");
    }
    
    // Connect to QuikTik WebSocket
    webSocket.begin("192.168.1.100", 8081, "/");
    webSocket.onEvent(webSocketEvent);
    webSocket.setReconnectInterval(5000);
}

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
    switch(type) {
        case WStype_CONNECTED:
            Serial.println("Connected to QuikTik!");
            // Subscribe to updates
            webSocket.sendTXT("{\"type\":\"subscribe\",\"establishment_id\":\"est_001\"}");
            break;
            
        case WStype_TEXT:
            Serial.printf("Received: %s\n", payload);
            handleMessage((char*)payload);
            break;
    }
}

void handleMessage(String message) {
    DynamicJsonDocument doc(1024);
    deserializeJson(doc, message);
    
    if (doc["type"] == "queue_update") {
        int currentServing = doc["current_serving"];
        Serial.printf("Now serving: #%d\n", currentServing);
        
        // Update your display/LEDs/etc
        updateDisplay(currentServing);
    }
}

void loop() {
    webSocket.loop();
    
    // Check button press to advance queue
    if (digitalRead(BUTTON_PIN) == LOW) {
        advanceQueue();
        delay(1000); // Debounce
    }
}

void advanceQueue() {
    String message = "{\"type\":\"advance_queue\",\"establishment_id\":\"est_001\",\"new_serving_number\":26}";
    webSocket.sendTXT(message);
}
```

---

## 🖨️ Printer Integration

### Thermal Printer Example (Python):
```python
from escpos.printer import Network
import requests
import time

class QuikTikPrinter:
    def __init__(self):
        # Connect to network printer
        self.printer = Network("192.168.1.200")
        
    def print_queue_status(self):
        # Get current queue status
        response = requests.get('http://localhost:8080/api/queue?establishment_id=est_001')
        data = response.json()
        
        # Print queue status
        self.printer.text("QUIKTIK QUEUE STATUS\n")
        self.printer.text("=" * 30 + "\n")
        self.printer.text(f"Now Serving: #{data['current_serving']}\n")
        self.printer.text(f"People Waiting: {data['total_waiting']}\n")
        self.printer.text(f"Available Numbers: {len(data['available_numbers'])}\n")
        self.printer.text("=" * 30 + "\n")
        self.printer.cut()
    
    def print_ticket(self, ticket_number):
        self.printer.text("QUEUE TICKET\n")
        self.printer.set(align='center', text_type='B', width=2, height=2)
        self.printer.text(f"#{ticket_number}\n")
        self.printer.set(align='left', text_type='normal', width=1, height=1)
        self.printer.text(f"Time: {time.strftime('%H:%M:%S')}\n")
        self.printer.cut()

# Usage
printer = QuikTikPrinter()
printer.print_queue_status()
```

---

## 🔍 Testing Your Connection

### 1. **Test HTTP API:**
```bash
# Test with curl
curl http://localhost:8080/api/status
curl "http://localhost:8080/api/queue?establishment_id=est_001"
```

### 2. **Test WebSocket:**
```javascript
// Browser console test
const ws = new WebSocket('ws://localhost:8081');
ws.onmessage = (e) => console.log(JSON.parse(e.data));
ws.onopen = () => ws.send('{"type":"ping"}');
```

### 3. **Monitor in Device Manager:**
- Open External Device Manager in QuikTik app
- Your device should appear in "Connected Devices"
- Watch live connection status and activity

---

## 🚨 Troubleshooting

### Connection Issues:
- ✅ Ensure QuikTik services are started
- ✅ Check firewall settings (allow ports 8080, 8081, 8082)
- ✅ Verify device is on same network
- ✅ Test with the HTML interface first

### Device Not Appearing:
- ✅ Call the device registration endpoint
- ✅ Send heartbeat messages periodically
- ✅ Check External Device Manager for errors

### No Real-Time Updates:
- ✅ Ensure WebSocket connection is established
- ✅ Subscribe to the correct establishment_id
- ✅ Check browser console for errors

---

## 🎯 Ready-to-Use Examples

I've created several ready-to-use examples in your project:

1. **`web/external_device_interface.html`** - Complete web interface
2. **HTTP API endpoints** - REST API documentation above
3. **Sample code** - JavaScript, Python, Arduino examples
4. **Device Manager** - Monitor all connections

**Start with the HTML interface** - it's the quickest way to see your external device connected and working!

Your QuikTik system is now ready to connect unlimited external devices! 🚀