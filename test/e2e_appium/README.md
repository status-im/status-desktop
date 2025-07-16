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

## Test Markers

```bash
pytest -m onboarding --env=local -v   # Onboarding flow tests
pytest -m smoke --env=local -v        # Quick critical tests
pytest -m tablet --env=local -v       # Tablet-specific tests
```

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

## Cloud Testing (LambdaTest)

```bash
export LT_USERNAME="your_username" 
export LT_ACCESS_KEY="your_access_key"
export STATUS_APP_URL="lt://APP123456789"

pytest tests/test_onboarding_flow.py --env=lambdatest -v
```

## Environment Management

```bash
# List environments
python cli/env_manager.py list

# Auto-detect environment  
python cli/env_manager.py auto-detect

# Validate configuration
python cli/env_manager.py validate local
```

## Documentation

- **[Quick Start Guide](docs/QUICK_START.md)** - 5-minute setup
- **[Local Setup Guide](docs/LOCAL_SETUP.md)** - Detailed local testing setup  
- **[Environment Management](docs/ENVIRONMENT_MANAGEMENT.md)** - YAML configurations and CLI tools
- **[Logging Guide](docs/LOGGING.md)** - Understanding logs and reports 