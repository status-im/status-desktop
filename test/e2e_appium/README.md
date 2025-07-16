# Status Desktop E2E Appium Tests

Simple E2E test framework for Status tablet app using Appium.

> **🚀 New here?** See [docs/QUICK_START.md](docs/QUICK_START.md) for 5-minute setup guide.

## Quick Start (Local Testing)

### Prerequisites
- Appium installed: `npm install -g appium`
- Android Studio with emulator
- Status tablet APK

### 1. Start Services

```bash
# Terminal 1: Start Appium
appium

# Terminal 2: Start Android emulator (ARM64 for M1 Mac)
emulator -avd your-tablet-avd
```

### 2. Set Environment

```bash
export LOCAL_APP_PATH="/path/to/your/Status-tablet-arm64.apk"
export CURRENT_TEST_ENVIRONMENT="local"
```

### 3. Run Tests

```bash
cd test/e2e_appium

# Run onboarding flow
pytest tests/test_onboarding_flow.py::TestOnboardingFlow::test_complete_onboarding_flow --env=local -v

# Run all onboarding tests
pytest tests/test_onboarding_flow.py --env=local -v

# Run smoke tests
pytest -m smoke --env=local -v
```

## Working Example (M1 Mac)

This setup was tested and works:

```bash
# 1. Environment variables
export LOCAL_APP_PATH="/Users/username/Status-tablet-arm64.apk"
export CURRENT_TEST_ENVIRONMENT="local"

# 2. Device: ARM64 emulator (QEMU-based)
# - Device: sdk_gphone64_arm64
# - Android: 15 (API 35)
# - Emulator: emulator-5554

# 3. Run test
pytest tests/test_onboarding_flow.py::TestOnboardingFlow::test_complete_onboarding_flow --env=local -v
```

## Cloud Testing (LambdaTest)

### Basic Setup
```bash
export LT_USERNAME="your_username" 
export LT_ACCESS_KEY="your_access_key"
export STATUS_APP_URL="lt://your_app_id"
export CURRENT_TEST_ENVIRONMENT="lambdatest"

# Run tests
pytest tests/test_onboarding_flow.py --env=lambdatest -v
```

### Advanced LambdaTest Configuration

**Custom Build and Test Names:**
```bash
# Optional: Customize LambdaTest build and test names
export BUILD_NUMBER="v1.2.3"
export TEST_NAME="Galaxy Tab S8 Onboarding Flow"
export GIT_BRANCH="feature/new-onboarding"

# Run tests with custom naming
pytest tests/test_onboarding_flow.py --env=lambdatest -v
```

**Result in LambdaTest Dashboard:**
- 🏗️ **Build:** `Status E2E Tests - v1.2.3`
- 📱 **Test:** `Galaxy Tab S8 Onboarding Flow (feature/new-onboarding)`
- 📁 **Project:** `Status E2E_Appium`

**Professional Defaults (No Environment Variables Required):**
```bash
# Just the essentials - framework provides intelligent defaults
export LT_USERNAME="your_username"
export LT_ACCESS_KEY="your_access_key" 
export STATUS_APP_URL="lt://your_app_id"

# Results in:
# Build: "Status E2E Tests - 20250716_1612" (auto-timestamp)
# Test: "Automated Test"
# Device: Galaxy Tab S8 (Android 14, Appium 2.16.2)
```

## Test Markers

```bash
pytest -m onboarding --env=local -v   # Onboarding flow tests
pytest -m smoke --env=local -v        # Quick critical tests
pytest -m tablet --env=local -v       # Tablet-specific tests
```

## Configuration Details

### Environment-Specific Settings

**Local Development:**
- Device: `sdk_gphone64_arm64` (Android 15)
- Timeouts: Extended for debugging
- Video recording: Disabled for performance

**LambdaTest Cloud:**
- Device: `Galaxy Tab S8` (Android 14)
- Appium: `2.16.2` (latest stable)
- Full video/screenshot capture enabled

### Template Variables Supported

**Build Names:**
- `${BUILD_NUMBER}` - CI build number
- `${TIMESTAMP}` - Auto-generated timestamp fallback

**Test Names:**
- `${TEST_NAME}` - Custom test description
- `${GIT_BRANCH}` - Auto-appended branch info

## Troubleshooting

**Device not found?**
```bash
# Check devices
adb devices

# Check actual device name
adb shell getprop ro.product.model
```

**Configuration issues?**
```bash
# Validate environment
python cli/env_manager.py validate local
```

**LambdaTest naming issues?**
```bash
# Verify environment variables
echo "Build: $BUILD_NUMBER"
echo "Test: $TEST_NAME"
echo "Branch: $GIT_BRANCH"
``` 