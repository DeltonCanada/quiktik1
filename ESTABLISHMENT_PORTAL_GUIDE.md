# QuikTik Establishment Portal

This guide explains how to access and use the QuikTik Establishment Portal from a different device to manage queues.

## 🚀 Quick Start

### Option 1: Web-based Establishment Portal (Recommended)

1. **Start the QuikTik customer app** on your main device (Android emulator, iOS, or web)
2. **Open a web browser** on any device (phone, tablet, computer) connected to the same network
3. **Navigate to**: `http://[MAIN_DEVICE_IP]:8080/web/establishment_portal.html`
   
   For local testing: `http://localhost:8080/web/establishment_portal.html`

4. **Configure connection settings**:
   - WebSocket URL: `ws://[MAIN_DEVICE_IP]:8081`
   - API URL: `http://[MAIN_DEVICE_IP]:8080`
   - Establishment ID: `servus_credit_union_edmonton` (or your establishment ID)

5. **Click "Connect to QuikTik System"** to start managing queues

### Option 2: Existing External Device Interface

1. Open: `http://[MAIN_DEVICE_IP]:8080/web/external_device_interface.html`
2. Use the basic queue controls available

## 🎮 Establishment Portal Features

### Real-time Queue Management
- **Currently Serving**: View and manually set the number being served
- **People Waiting**: See total customers in queue with estimated wait times
- **Available Numbers**: View all purchasable queue numbers
- **Live Activity Log**: Monitor all queue activities in real-time

### Queue Controls
- **⏭️ Next Customer**: Advance queue to next number
- **⏸️ Pause Queue**: Temporarily pause queue operations
- **🔄 Reset Queue**: Clear queue and start fresh (with confirmation)
- **🎯 Set Number**: Manually set any serving number

### Live Updates
- Real-time synchronization with customer app
- Automatic updates when customers purchase tickets
- Instant feedback for all queue operations
- Connection status monitoring

## 🔧 Technical Setup

### Network Configuration

For different devices to access the establishment portal:

1. **Find your main device's IP address**:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr show`
   - Android: Settings > Network > Wi-Fi > Advanced

2. **Ensure devices are on same network**:
   - Same Wi-Fi network for local access
   - Use port forwarding for external access

3. **Update URLs in portal**:
   - Replace `localhost` with actual IP address
   - Example: `192.168.1.100` instead of `localhost`

### Supported Platforms

**Establishment Portal works on**:
- ✅ Desktop browsers (Chrome, Firefox, Safari, Edge)
- ✅ Tablet browsers (iPad, Android tablets)
- ✅ Mobile browsers (iPhone, Android phones)
- ✅ Kiosk displays and embedded systems

## 📡 API Endpoints

The establishment portal communicates via:

### HTTP API (Port 8080)
```
GET  /api/queue/{establishmentId}           # Get queue status
POST /api/queue/{establishmentId}/advance   # Advance queue
POST /api/queue/{establishmentId}/set-serving # Set serving number
POST /api/queue/{establishmentId}/pause     # Pause queue
POST /api/queue/{establishmentId}/reset     # Reset queue
GET  /api/establishments                    # List establishments
```

### WebSocket (Port 8081)
```javascript
// Connect to real-time updates
ws://[IP]:8081

// Send commands
{
  "type": "advance_queue",
  "establishment_id": "your_establishment_id",
  "device_id": "establishment_portal"
}
```

## 🏪 Multi-Establishment Support

### Setting Up Different Establishments

1. **Create establishment-specific portals**:
   ```
   establishment_portal.html?establishment_id=location_1
   establishment_portal.html?establishment_id=location_2
   ```

2. **Use different establishment IDs**:
   - `servus_credit_union_edmonton`
   - `rogers_place_box_office`
   - `west_edmonton_mall_info`
   - Or create your own in the location data service

3. **Deploy on separate devices**:
   - Each location can have dedicated tablets/computers
   - All sync with central QuikTik system

## 🛡️ Security Considerations

### For Production Use:
- [ ] Add authentication/authorization
- [ ] Use HTTPS/WSS for encrypted connections
- [ ] Implement rate limiting
- [ ] Add audit logging for all queue operations
- [ ] Configure proper firewall rules

### Current State:
- ⚠️ Demo/development mode - no authentication
- ⚠️ HTTP connections (not encrypted)
- ⚠️ CORS enabled for all origins

## 🎯 Use Cases

### Bank/Credit Union
- Teller manages queue from their workstation
- Security desk monitors overall queue status
- Mobile tablet for floor assistance

### Retail Store
- Customer service desk controls queue
- Manager monitors from back office
- Seasonal staff use tablets

### Government Office
- Each service window has queue control
- Supervisor dashboard monitors all queues
- Citizens see real-time updates on displays

### Medical Clinic
- Reception desk manages appointments
- Nurses advance queue from treatment rooms
- Patients see current status on waiting room displays

## 🚨 Troubleshooting

### Connection Issues
1. **Check IP address**: Ensure correct IP in portal settings
2. **Verify network**: Both devices on same Wi-Fi/network
3. **Check ports**: 8080 (HTTP) and 8081 (WebSocket) must be open
4. **Firewall**: Allow Flutter app through firewall

### Portal Not Loading
1. **Verify QuikTik app is running** on main device
2. **Check URL format**: `http://[IP]:8080/web/establishment_portal.html`
3. **Try localhost first**: If testing on same device

### Queue Commands Not Working
1. **Check connection status**: Should show "Connected" in top-right
2. **Verify establishment ID**: Must match exactly (case-sensitive)
3. **Check browser console**: F12 for error messages
4. **Refresh connection**: Disconnect and reconnect

## 📞 Support

For issues with the establishment portal:
1. Check the browser console (F12) for error messages
2. Verify the QuikTik app logs for connection attempts
3. Test with localhost first, then external IP
4. Ensure all devices are on the same network

---

**Ready to manage queues from anywhere! 🎉**