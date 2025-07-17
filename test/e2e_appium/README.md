# E2E Testing Framework

Automated end-to-end testing for Status Desktop using Appium and LambdaTest.

## Quick Start

### 1. Setup
```bash
cd test/e2e_appium
pip install -r requirements.txt
```

### 2. Configure LambdaTest (GitHub Secrets)
Repository administrators need to set:
- `LT_USERNAME` - Your LambdaTest username
- `LT_ACCESS_KEY` - Your LambdaTest access key

### 3. Run Tests via GitHub Actions
1. Build APK using `android-build.yml` workflow (architecture: `x86_64`)
2. Run tests using `e2e-appium-android.yml` workflow
3. Use artifact name: `Status-tablet-x86_64`

## Test Selection

**By markers:**
```bash
pytest -m smoke          # Core functionality
pytest -m onboarding     # User registration flow
pytest -m critical       # Essential features
```

**Specific tests:**
```bash
pytest tests/test_onboarding_flow.py::test_complete_onboarding_flow
```

## Local Testing

```bash
# Setup local environment
python scripts/local_setup.py

# Run tests with local APK
export LOCAL_APP_PATH="/path/to/Status-tablet.apk"
pytest -m onboarding --env=local -v
```

## GitHub Actions Workflows

### Build APK Workflow
- **File**: `android-build.yml`
- **Architecture**: `x86_64` (required for LambdaTest)
- **Output**: `Status-tablet-x86_64` artifact

### E2E Testing Workflow
- **File**: `e2e-appium-android.yml`
- **APK source**: GitHub artifact (default)
- **Test target**: `onboarding` (default)
- **Device**: Galaxy Tab S8 (default)

## Workflow Input Options

### APK Sources
- **GitHub artifacts**: `Status-tablet-x86_64` (recommended)
- **Direct URLs**: `https://example.com/app.apk`
- **LambdaTest IDs**: `lt://APP123456789`

### Device Options
- **default**: Galaxy Tab S8 (Android 14)
- **pixel_tablet**: Google Pixel Tablet
- **galaxy_tab_a**: Samsung Galaxy Tab A

### Test Targets
- **onboarding**: Complete user onboarding flow
- **smoke**: Quick critical functionality tests
- **critical**: Essential features that must pass

## Environment Configuration

### For LambdaTest (Cloud)
```bash
# Set in GitHub repository secrets
LT_USERNAME=your_username
LT_ACCESS_KEY=your_access_key
```

### For Local Testing
```bash
export LOCAL_APP_PATH="/path/to/Status-tablet.apk"
export CURRENT_TEST_ENVIRONMENT="local"
```

## Troubleshooting

**APK Build Issues:**
- Verify x86_64 architecture selected in android-build.yml
- Check build workflow completed successfully

**Test Execution Issues:**
- Verify LambdaTest credentials in repository secrets
- Check APK artifact name matches exactly: `Status-tablet-x86_64`
- Review workflow logs for detailed error messages

**Local Testing Issues:**
- Ensure Appium server running: `appium`
- Verify Android emulator running with correct device name
- Check LOCAL_APP_PATH points to valid APK file

## Framework Structure

```
test/e2e_appium/
├── tests/              # Test files
├── pages/              # Page object models
├── config/             # Configuration files
├── scripts/            # Automation and setup scripts
├── docs/               # Documentation
└── .github/actions/    # Reusable workflow actions
```

## Documentation

- **Workflow Quick Reference**: `docs/WORKFLOW_QUICKREF.md`
- **GitHub Actions Guide**: `docs/github-actions.md`
- **Local Setup Guide**: `docs/LOCAL_SETUP.md` 
- **Quick Start Guide**: `docs/QUICK_START.md`
- **Environment Management**: `docs/ENVIRONMENT_MANAGEMENT.md`
- **Logging Guide**: `docs/LOGGING.md`
- **Refactoring Details**: `docs/REFACTORING.md` 