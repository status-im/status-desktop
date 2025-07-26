# Local Testing Setup Guide

Simple guide to run Status tablet E2E tests locally.

## Prerequisites

### 1. Install Required Software
```bash
# Node.js and Appium
brew install node
npm install -g appium
appium driver install uiautomator2

# Python dependencies 
cd test/e2e_appium
pip install -r requirements.txt
```

### 2. Android Setup
- Install Android Studio
- Install Android SDK (API 35 recommended)
- Create ARM64 emulator (for M1 Mac)

## Quick Setup

### 1. Create ARM64 Emulator (M1 Mac)
```bash
# Install ARM64 system image
sdkmanager "system-images;android-35;google_apis;arm64-v8a"

# Create tablet emulator
avdmanager create avd -n status-tablet -k "system-images;android-35;google_apis;arm64-v8a" -d "pixel_tablet"
```

### 2. Start Services (3 Terminals)

**Terminal 1: Appium Server**
```bash
appium
```

**Terminal 2: Android Emulator**
```bash
emulator -avd status-tablet
# Or use your existing tablet AVD
```

**Terminal 3: Run Tests**
```bash
cd test/e2e_appium

# Set environment
export LOCAL_APP_PATH="/path/to/your/Status-tablet-arm64.apk"
export CURRENT_TEST_ENVIRONMENT="local"

# Run onboarding test
pytest tests/test_onboarding_flow.py::TestOnboardingFlow::test_complete_onboarding_flow --env=local -v
```

## Working Configuration

This setup was tested on M1 Mac:

```bash
# Environment
LOCAL_APP_PATH=/Users/username/Status-tablet-arm64.apk
CURRENT_TEST_ENVIRONMENT=local

# Device detected by adb
emulator-5554    device    sdk_gphone64_arm64

# Device properties
Device: sdk_gphone64_arm64
Android: 15 (API 35)
Architecture: ARM64 (QEMU-based)
```

## Verify Setup

### Check Prerequisites
```bash
# Appium running?
curl -s http://localhost:4723/status

# Emulator running?
adb devices

# Get device info
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
```

### Validate Configuration
```bash
cd test/e2e_appium
python cli/env_manager.py validate local
```

Should show:
```
✅ Environment 'local' is valid
Configuration Summary:
  Device: sdk_gphone64_arm64
  Platform: android 15
  App Source: local_file
  Appium Server: http://localhost:4723
```

## Run Tests

### Onboarding Flow
```bash
# Complete onboarding test
pytest tests/test_onboarding_flow.py::TestOnboardingFlow::test_complete_onboarding_flow --env=local -v

# All onboarding tests
pytest tests/test_onboarding_flow.py --env=local -v
```

### Other Test Categories
```bash
pytest -m smoke --env=local -v      # Smoke tests
pytest -m tablet --env=local -v     # Tablet-specific tests
pytest -m onboarding --env=local -v # Onboarding tests
```

## Troubleshooting

### Device Not Found
```bash
# Check ADB connection
adb devices

# Restart ADB if needed
adb kill-server
adb start-server
```

### App Installation Issues
```bash
# Manually install APK to test
adb install -r /path/to/Status-tablet-arm64.apk

# Check if app installed
adb shell pm list packages | grep status
```

### Appium Connection Issues
```bash
# Check Appium status
curl http://localhost:4723/status

# Restart Appium
pkill -f appium
appium
```

### Configuration Issues
```bash
# Check actual device properties
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release

# Update config if needed
# Edit: test/e2e_appium/config/environments/local.yaml
```

## Advanced Usage

### Parallel Testing
```bash
# Install parallel plugin
pip install pytest-xdist

# Run multiple tests in parallel
pytest tests/ --env=local -n 2 -v
```

### Custom Device Configuration
Edit `config/environments/local.yaml`:
```yaml
device:
  name: "your-device-name"
  platform_version: "15"

capabilities:
  platformName: "android"
  automationName: "UiAutomator2"
```

## Performance Tips

### M1 Mac Optimization
- Use ARM64 system images (much faster than x86_64)
- Allocate sufficient RAM to emulator (4GB+)
- Use hardware acceleration

### Emulator Settings
```bash
# Start with performance optimizations
emulator -avd status-tablet \
  -memory 4096 \
  -cores 4 \
  -gpu swiftshader_indirect
``` 