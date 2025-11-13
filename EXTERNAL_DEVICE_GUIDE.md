# 📺 QuikTik External Device Interface - User Guide

The External Device Interface is designed for digital displays, kiosks, and secondary devices that need to show queue information and basic controls.

## 🚀 Quick Start Guide

### Step 1: Access the Interface
1. **Start the QuikTik system** (customer app must be running)
2. **Open a web browser** on your external device
3. **Navigate to**: `http://[QUIKTIK_SERVER_IP]:8080/external_device_interface.html`

**Local testing**: `http://localhost:8080/external_device_interface.html`

### Step 2: Verify Connection
- Look for the **connection status** at the top:
  - 🟢 **Green dot**: Connected to QuikTik
  - 🔴 **Red dot**: Disconnected (check network/server)

## 📋 Interface Overview

### Main Display Sections

#### 1. **Connection Status Bar**
```
🟢 Connected to QuikTik    or    🔴 Disconnected
```
- Shows real-time connection status
- Automatically attempts reconnection if lost

#### 2. **Establishment Information**
- **Name**: Current establishment being served
- **Address**: Location details
- Automatically loads from server

#### 3. **Queue Status Panel**
- **Currently Serving**: Number being served right now
- **People Waiting**: Total customers in queue
- **Available Numbers**: How many numbers can still be purchased

#### 4. **Large Display Number**
```
Currently Serving: ##
```
- Large, prominent display of current serving number
- Perfect for customer viewing from a distance

#### 5. **Control Buttons**
- **⏭️ Next Customer**: Advance queue to next number
- **⏸️ Pause Queue**: Temporarily pause queue operations
- **🔄 Refresh**: Refresh connection and data
- **📡 Register Device**: Re-register device with server

#### 6. **Activity Log**
- Real-time log of all activities
- Shows connection status, queue updates, errors
- Automatically scrolls and maintains last 50 entries

#### 7. **Connection Information**
- **WebSocket URL**: Real-time communication endpoint
- **HTTP API**: RESTful API endpoint
- **Device ID**: Unique identifier for this device

## 🎮 How to Use the Controls

### Basic Queue Management

#### **Advance Queue (⏭️ Next Customer)**
```
Purpose: Move queue to next number
When to use: When current customer is finished
Effect: Increments serving number by 1
```

**Steps:**
1. Ensure current customer is finished
2. Click "⏭️ Next Customer"
3. Watch the large display update
4. Check activity log for confirmation

#### **Pause Queue (⏸️ Pause Queue)**
```
Purpose: Temporarily stop queue progression
When to use: During breaks, emergencies, or system maintenance
Effect: Prevents automatic queue advancement
```

**Steps:**
1. Click "⏸️ Pause Queue"
2. Queue operations halt
3. Display shows pause status
4. Use "⏭️ Next Customer" to resume when ready

#### **Refresh Data (🔄 Refresh)**
```
Purpose: Reload current queue status
When to use: When data seems outdated or connection issues
Effect: Requests latest data from server
```

#### **Register Device (📡 Register Device)**
```
Purpose: Re-establish device registration
When to use: After connection problems or first setup
Effect: Identifies device to QuikTik system
```

## 🔧 Setup & Configuration

### Network Setup

#### **For Same Device Testing:**
```
URL: http://localhost:8080/external_device_interface.html
WebSocket: ws://localhost:8081
```

#### **For Different Device:**
1. **Find QuikTik server IP address**:
   - Windows: Run `ipconfig` (look for IPv4 Address)
   - Mac/Linux: Run `ifconfig` or `ip addr show`

2. **Update URL**:
   ```
   http://[SERVER_IP]:8080/external_device_interface.html
   Example: http://192.168.1.100:8080/external_device_interface.html
   ```

3. **Ensure network connectivity**:
   - Both devices on same Wi-Fi/network
   - Firewall allows connections on ports 8080 and 8081

### Device Compatibility

#### **✅ Supported Devices:**
- Desktop computers (Windows, Mac, Linux)
- Tablets (iPad, Android tablets)
- Smart TVs with web browsers
- Digital signage displays
- Raspberry Pi with browser
- Industrial kiosks
- Mobile phones (responsive design)

#### **✅ Supported Browsers:**
- Chrome (recommended)
- Firefox
- Safari
- Edge
- Opera

## 📱 Use Cases & Scenarios

### **Scenario 1: Reception Desk Display**
```
Setup: External monitor at reception
Purpose: Show current serving number to customers
Usage: Staff uses controls to advance queue
```

### **Scenario 2: Wall-Mounted Kiosk**
```
Setup: Touch-enabled kiosk in waiting area
Purpose: Self-service queue management
Usage: Staff or supervisors advance queue
```

### **Scenario 3: Secondary Office Screen**
```
Setup: Additional monitor for back-office staff
Purpose: Monitor queue status without main app
Usage: Quick queue checks and controls
```

### **Scenario 4: Digital Signage**
```
Setup: Large TV display in waiting area
Purpose: Show queue information to customers
Usage: Display-only mode with automatic updates
```

## 🔄 Real-time Features

### **Automatic Updates**
- Queue status updates in real-time
- No need to manually refresh
- Instant synchronization with main QuikTik app

### **Live Activity Monitoring**
```
[14:30:15] Connected to QuikTik WebSocket
[14:30:16] Loaded establishment: Servus Credit Union Edmonton
[14:30:45] Queue advanced: Now serving #42
[14:31:12] New ticket purchased: #47
[14:31:30] Queue advanced: Now serving #43
```

### **Connection Recovery**
- Automatically reconnects if connection lost
- Continues operation when server restarts
- Maintains device registration

## 🚨 Troubleshooting

### **Connection Issues**

#### **Problem: Red Status Dot (Disconnected)**
```
Solutions:
1. Check QuikTik main app is running
2. Verify network connection
3. Check IP address in URL
4. Try clicking "🔄 Refresh"
5. Reload the page (F5)
```

#### **Problem: "Failed to register device"**
```
Solutions:
1. Ensure API server is running
2. Check network connectivity
3. Click "📡 Register Device" again
4. Check browser console (F12) for errors
```

#### **Problem: Controls not working**
```
Solutions:
1. Verify green connection status
2. Check activity log for error messages
3. Click "🔄 Refresh" to reload
4. Ensure you have proper permissions
```

### **Display Issues**

#### **Problem: Numbers not updating**
```
Solutions:
1. Check WebSocket connection (green dot)
2. Click "🔄 Refresh"
3. Verify main QuikTik app is advancing queue
4. Check activity log for update messages
```

#### **Problem: Wrong establishment shown**
```
Solutions:
1. Verify correct server URL
2. Check establishment configuration in main app
3. Restart external device interface
```

## ⚙️ Advanced Configuration

### **Custom Establishment ID**
If you need to connect to a specific establishment, modify the JavaScript:

```javascript
// Change this line in the HTML file:
let establishmentId = 'your_establishment_id';
```

### **Custom Styling**
The interface uses CSS that can be customized for branding:

```css
/* Example: Change color scheme */
body {
    background: linear-gradient(135deg, #your-color1, #your-color2);
}
```

### **Auto-Refresh Settings**
Modify heartbeat interval (default 30 seconds):

```javascript
// Change interval in milliseconds
setInterval(() => { ... }, 30000); // 30 seconds
```

## 📊 Activity Log Messages

### **Common Log Messages:**
```
✅ "Connected to QuikTik WebSocket" - Successful connection
✅ "Device registered successfully" - Device recognized by system
✅ "Queue advanced: Now serving #X" - Queue progressed
✅ "Loaded establishment: [Name]" - Establishment data loaded
❌ "Failed to connect" - Connection problem
❌ "Device registration failed" - Registration issue
🔄 "Refreshing data..." - Manual refresh initiated
```

## 🎯 Best Practices

### **For Optimal Performance:**
1. **Use wired network** when possible for stability
2. **Keep browser updated** for best compatibility
3. **Monitor activity log** for any issues
4. **Test connection** before important periods
5. **Have backup plan** if external device fails

### **For Customer Experience:**
1. **Position display** where customers can easily see
2. **Ensure good lighting** for screen visibility
3. **Keep interface simple** for staff training
4. **Regular testing** to ensure reliability

---

## 🆘 Getting Help

### **Quick Diagnostics:**
1. **Check connection status** (green/red dot)
2. **Review activity log** for error messages  
3. **Test with localhost** first
4. **Verify main QuikTik app** is running
5. **Check network connectivity**

### **Support Information:**
- **Interface Type**: External Device Display
- **Ports Used**: 8080 (HTTP), 8081 (WebSocket)
- **Browser Requirements**: Modern browser with JavaScript
- **Network Requirements**: Same network as QuikTik server

**Ready to manage queues from external devices! 📺✨**