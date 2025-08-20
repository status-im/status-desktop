# E2E Testing Framework

Automated end-to-end testing for Status Desktop Android tablet/mobile using Appium and LambdaTest.

## ⚡ Quick Start

### 🤖 GitHub Actions (5 min)
1. **Build APK**: Use `android-build.yml` workflow with `x86_64` architecture
2. **Get APK details**: LambdaTest app URL or GitHub workflow run id (from URL) or APK artifact URL  
3. **Run Tests**: Use `e2e-appium-android.yml` workflow with default settings (specify APK source)
4. **View Results**: Check workflow artifacts and summary

### ☁️ Run tests on LambdaTest cloud (10 min)
```bash
cd test/e2e_appium
pip install -r requirements.txt

# Set credentials and run on cloud devices
export LT_USERNAME="your_lambdatest_username"
export LT_ACCESS_KEY="your_lambdatest_access_key" 
export STATUS_APP_URL="lt://your_app_id"
pytest -m onboarding --env=lambdatest -v
```

### 💻 Local Setup (30+ min) 
**Advanced users** - See [Local Testing Setup](#local-testing-setup-advanced) section below

## 📋 Prerequisites

**For Cloud Testing (Recommended):**
- Python 3.11+
- LambdaTest account with credentials:
  ```bash
  export LT_USERNAME="your_lambdatest_username"  
  export LT_ACCESS_KEY="your_lambdatest_access_key"
  export STATUS_APP_URL="lt://your_app_id"  # Upload APK to LambdaTest first
  ```

**For Local Testing (Advanced):**
- Python 3.11+ 
- Android SDK with `adb` command available
- Appium server: `npm install -g appium && appium driver install uiautomator2`
- Android emulator running or physical device connected
- Status Desktop APK file

## 🧪 Test Selection

**By markers:**
```bash
pytest -m smoke          # Core functionality
pytest -m onboarding     # User registration flow
pytest -m critical       # Essential features
pytest -m performance    # Performance validation tests
```

**Specific tests:**
```bash
# Run onboarding tests
pytest tests/test_onboarding_flow.py

# Run specific test method
pytest tests/test_onboarding_flow.py::TestOnboardingFlow::test_onboarding_new_password_skip_analytics
```

## ☁️ LambdaTest Setup Details

1. **Get Credentials**: Create account at [lambdatest.com](https://lambdatest.com) → Settings → Password & Security
2. **Upload APK**: Upload Status-tablet.apk via LambdaTest App Upload → Copy app ID (format: `lt://APP123...`)
3. **Run Tests**:
   ```bash
   export LT_USERNAME="your_lambdatest_username"
   export LT_ACCESS_KEY="your_lambdatest_access_key"
   export STATUS_APP_URL="lt://APP10160232441755188546651464"  # Your app ID
   pytest -m onboarding --env=lambdatest -v
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

## ✍️ Writing Tests

### Using Onboarding Fixture
The framework includes a reusable onboarding fixture:

```python
class TestMyFeature(BaseTest):
    
    @pytest.mark.onboarding
    def test_my_feature(self, onboarded_user):
        # User is already onboarded, test your feature
        assert onboarded_user['success']
        user_data = onboarded_user['user_data']
        # Your test logic here

    # Custom onboarding configuration
    @pytest.mark.onboarding_config(custom_display_name="MyUser")
    def test_with_custom_user(self, onboarded_user):
        assert onboarded_user['user_data']['display_name'] == "MyUser"
```

### Page Object Pattern
```python
from pages.onboarding import WelcomePage

class TestWelcome(BaseTest):
    def test_welcome_screen(self, app_driver):
        welcome_page = WelcomePage(app_driver)
        success = welcome_page.click_create_profile()
        assert success, "Should successfully click create profile button"
```

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

## 🔧 Troubleshooting

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

## 🤝 Contributing

### Code Guidelines
- Follow PEP 8 style guidelines
- Use type hints for all function parameters and return values
- Place all imports at the top of files
- Inherit from `BaseTest` for test classes
- Use Page Object Model for UI interactions
- Add pytest markers for test categorization

### Pull Request Process
1. Fork repository and create feature branch
2. Write tests following existing patterns
3. Run tests locally: `pytest -m onboarding --env=local -v`
4. Submit PR with clear description

**📖 Complete Guide**: See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed development guidelines, code standards, and workflow instructions.

### Framework Structure
```
test/e2e_appium/
├── tests/              # Test files
├── pages/              # Page object models  
├── locators/           # UI element locators
├── fixtures/           # Test fixtures (onboarding, etc.)
├── config/             # Environment configurations
├── scripts/            # Automation scripts
└── utils/              # Helper utilities
```

## 💻 Local Testing Setup (Advanced)

**Prerequisites:** Android SDK, Appium server, emulator/device, Status Desktop APK

**Quick Setup:**
```bash
# 1. Start services
appium &                          # In background
adb devices                       # Verify device connection

# 2. Run tests  
export LOCAL_APP_PATH="/path/to/Status-tablet.apk"
pytest -m onboarding --env=local -v
```

**Full Setup Guide:** See [Prerequisites](#-prerequisites) section above for detailed requirements.

## 📞 Help & Support

- **Issues**: Report bugs or request features in GitHub Issues
- **Discussions**: Ask questions in GitHub Discussions  
- **Framework Status**: See [Epic #18436](https://github.com/status-im/status-desktop/issues/18436) for roadmap