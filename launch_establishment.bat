@echo off
echo.
echo ============================================
echo 🏪 QuikTik Establishment Hub Launcher
echo ============================================
echo.
echo Choose your establishment interface:
echo.
echo 1. Web Dashboard (Recommended)
echo 2. Python Command Line
echo 3. View Setup Guide
echo 4. Exit
echo.

:menu
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo.
    echo 🌐 Starting Web Dashboard...
    echo Opening establishment_hub.html in your default browser...
    start establishment_hub.html
    echo.
    echo ✅ Web dashboard should now be open!
    echo You can now manage queues and see real-time updates.
    echo.
    pause
    goto menu
)

if "%choice%"=="2" (
    echo.
    echo 🐍 Starting Python Command Line Interface...
    if exist establishment_simulator.py (
        python establishment_simulator.py
    ) else (
        echo ❌ establishment_simulator.py not found!
        echo Please copy it from the main QuikTik directory.
    )
    goto menu
)

if "%choice%"=="3" (
    echo.
    echo 📖 Opening Setup Guide...
    if exist ESTABLISHMENT_SETUP_GUIDE.md (
        start ESTABLISHMENT_SETUP_GUIDE.md
    ) else (
        echo Setup Guide:
        echo 1. Copy establishment_hub.html to this device
        echo 2. Copy establishment_simulator.py to this device
        echo 3. Open establishment_hub.html in web browser
        echo 4. Use the interface to manage queues
        echo 5. Watch Flutter app for real-time updates
    )
    echo.
    pause
    goto menu
)

if "%choice%"=="4" (
    echo.
    echo 👋 Thanks for using QuikTik Establishment Hub!
    exit /b 0
)

echo Invalid choice. Please try again.
goto menu