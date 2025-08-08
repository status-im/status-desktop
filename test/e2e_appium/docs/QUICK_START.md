# Quick Start Guide

Simple 5-minute setup to run Status tablet onboarding tests locally.

## What You Need
- Status tablet APK
- Android emulator running
- Appium installed

## Setup (One Time)

### 1. Install Appium
```bash
npm install -g appium
appium driver install uiautomator2
```

### 2. Python Dependencies
```bash
cd test/e2e_appium
pip install -r requirements.txt
```

## Run Tests (Every Time)

### 1. Start Services (2 terminals)
```bash
# Terminal 1: Appium
appium

# Terminal 2: Android emulator
emulator -avd your-tablet-avd
```

### 2. Set Environment & Run
```bash
# Set your APK path
export LOCAL_APP_PATH="/path/to/your/Status-tablet-arm64.apk"
export CURRENT_TEST_ENVIRONMENT="local"

# Run onboarding test
cd test/e2e_appium
pytest tests/test_onboarding_flow.py::TestOnboardingFlow::test_complete_onboarding_flow --env=local -v
```

## Working Example (Mac arm64)

This exact setup worked:
```bash
# Environment
export LOCAL_APP_PATH="/Users/magnus/dev/Status-tablet-arm64.apk"
export CURRENT_TEST_ENVIRONMENT="local"

# Device (auto-detected)
emulator-5554    device    sdk_gphone64_arm64

# Test command
pytest tests/test_onboarding_flow.py::TestOnboardingFlow::test_complete_onboarding_flow --env=local -v
```

## Verify Setup
```bash
# Check if everything is ready
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

## Troubleshooting

**No device found?**
```bash
adb devices                           # Check emulator
adb shell getprop ro.product.model    # Get device name
```

**Can't connect to Appium?**
```bash
curl http://localhost:4723/status     # Check Appium
```

That's it! 🎉 