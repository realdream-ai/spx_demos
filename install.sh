#!/bin/bash

# Install all app packages from builds directory to connected devices
# Script detects device type (iOS or Android) and installs appropriate packages

# Get the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_PATH=$(pwd)
cd $SCRIPT_DIR

# Function to detect device type
detect_device_type() {
    # Check for iOS device
    if command -v ios-deploy &> /dev/null; then
        IOS_DEVICE=$(ios-deploy -c 2>&1)
        if [[ $IOS_DEVICE != *"No device found"* ]]; then
            echo "ios"
            return
        fi
    fi
    
    # Check for Android device
    if command -v adb &> /dev/null; then
        ANDROID_DEVICE=$(adb devices | grep -v "List" | grep "device")
        if [ ! -z "$ANDROID_DEVICE" ]; then
            echo "android"
            return
        fi
    fi
    
    # No device detected
    echo "none"
}

# Install iOS app
install_ios_app() {
    # Check if ios-deploy is installed
    if ! command -v ios-deploy &> /dev/null; then
        echo "Installing ios-deploy..."
        npm install -g ios-deploy
    fi

    # Check for device connection
    DEVICE_STATUS=$(ios-deploy -c 2>&1)
    if [[ $DEVICE_STATUS == *"No device found"* ]]; then
        echo "Error: No iOS device detected. Please connect your iPhone via USB and trust this computer."
        return 1
    fi

    # Iterate through all .ipa files in builds directory
    for IPA_FILE in builds/*.ipa; do
        if [ -f "$IPA_FILE" ]; then
            echo "Installing: $IPA_FILE"
            ios-deploy --bundle "$IPA_FILE"
            if [ $? -eq 0 ]; then
                echo "✅ Installation successful: $IPA_FILE"
            else
                echo "❌ Installation failed: $IPA_FILE (You may need to manually trust the certificate)"
            fi
        fi
    done
}

# Install Android app
install_android_app() {
    # Check if adb is installed
    if ! command -v adb &> /dev/null; then
        echo "Error: Android Debug Bridge (adb) is not installed. Please install Android SDK."
        return 1
    fi
    
    # Check for device connection
    DEVICE_STATUS=$(adb devices | grep -v "List" | grep "device")
    if [ -z "$DEVICE_STATUS" ]; then
        echo "Error: No Android device detected. Please connect your device via USB and enable USB debugging."
        return 1
    fi
    
    # Iterate through all .apk files in builds directory
    for APK_FILE in builds/*.apk; do
        if [ -f "$APK_FILE" ]; then
            echo "Installing: $APK_FILE"
            adb install -r "$APK_FILE"
            if [ $? -eq 0 ]; then
                echo "✅ Installation successful: $APK_FILE"
            else
                echo "❌ Installation failed: $APK_FILE"
            fi
        fi
    done
}

# Main script
DEVICE_TYPE=$(detect_device_type)

case $DEVICE_TYPE in
    "ios")
        echo "iOS device detected. Installing .ipa files..."
        install_ios_app
        ;;
    "android")
        echo "Android device detected. Installing .apk files..."
        install_android_app
        ;;
    *)
        echo "Error: No iOS or Android device detected. Please connect a device and try again."
        exit 1
        ;;
esac