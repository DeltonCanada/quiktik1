# 🏪 QuikTik Establishment Setup Guide

## Quick Start - External Device as Establishment

### Option 1: Web Dashboard (Recommended)
1. **On your external device**, open a web browser
2. Navigate to: `file:///c:/QuikTik/quiktik1/establishment_hub.html`
   - Or copy the `establishment_hub.html` file to your external device and open it
3. You'll see a complete establishment management interface with:
   - Queue advancement controls
   - Ticket selling simulation
   - Real-time activity log
   - Connection status indicator

### Option 2: Python Command Line Interface
1. **On your external device**, ensure Python is installed
2. Copy `establishment_simulator.py` to your external device
3. Run: `python establishment_simulator.py`
4. Follow the interactive menu to:
   - Advance queues
   - Sell tickets
   - Send status updates
   - View connection status

## What You'll See

### On Your Flutter App (Customer Device):
- 🔔 **Notification banners** at the top showing establishment updates
- 📱 **Real-time queue updates** when you navigate to queue screens
- ⚡ **Instant synchronization** when establishment makes changes

### On Your External Device (Establishment):
- 🎛️ **Control panel** for queue management
- 📊 **Live activity log** showing all actions
- 🔗 **Connection status** with customer devices
- 📈 **Queue statistics** and performance metrics

## Demo Scenarios to Try

### Scenario 1: Queue Advancement
1. **External Device**: Click "Advance Queue" or use Python menu option 2
2. **Flutter App**: Watch for notification banner "Queue advanced to #XX"
3. **Result**: Customer sees their position update immediately

### Scenario 2: Ticket Sales
1. **External Device**: Click "Sell Ticket" or use Python menu option 1
2. **Flutter App**: Watch for notification "New ticket #XX sold"
3. **Result**: Queue numbers increase in real-time

### Scenario 3: Status Updates
1. **External Device**: Send status update or use Python menu option 3
2. **Flutter App**: See establishment announcements appear
3. **Result**: Customer gets real-time service updates

## Troubleshooting

### If External Device Can't Connect:
1. Ensure both devices are on the same network
2. Check firewall settings allow local connections
3. Try copying files directly to external device
4. Use Python simulator as backup option

### If Updates Don't Appear:
1. Check Flutter app console for connection messages
2. Verify establishment interface shows "Connected" status
3. Try refreshing both interfaces
4. Check network connectivity between devices

## Files You Need on External Device:
- `establishment_hub.html` - Complete web interface
- `establishment_simulator.py` - Python command-line interface
- Both are self-contained and work offline

## Current Demo Status:
✅ Customer Flutter App: Running with real-time updates
✅ Establishment Bridge: Active and processing updates
✅ Demo Simulation: Sending updates every 10 seconds
✅ Synchronization: Bidirectional communication working

Your system is ready for demonstration!