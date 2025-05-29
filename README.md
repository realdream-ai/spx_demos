# spx2 demos for test
## How to Run

### 1. Basic Method

Download spx (branch dev)

```bash
# cd path/to/spx

git clone https://github.com/realdream-ai/spx_demos.git demos

cd demos/AircraftWar # cd to the demo dir which you want to run

spx run .
```

### 2. Using run.sh Script

The run.sh script allows you to batch run, export, or run all demo projects in a web browser.

```bash
# Clear all demo caches
./run.sh 

# Run all demo projects locally
./run.sh --pc

# Run all demo projects in web mode
./run.sh --web

# Export all demo projects as Android APK files
./run.sh --apk

# Export all demo projects as iOS IPA files
./run.sh --ios
```

Exported APK and IPA files will be saved in the `demos/builds` directory.

### 3. Using install.sh Script

The install.sh script can install exported applications to connected devices. The script automatically detects the device type (iOS or Android) and installs the corresponding application packages.

```bash
# Run the installation script
./install.sh
```

Script features:
- Automatically detects the type of connected device (iOS or Android)
- For iOS devices, installs all .ipa files in the builds directory
- For Android devices, installs all .apk files in the builds directory
- Displays an error message if no device is detected

**Note**:
- iOS devices require the ios-deploy tool (the script will automatically check and install it)
- Android devices require Android SDK and adb tools
- Devices need to be connected to the computer via USB and have appropriate debugging modes enabled
