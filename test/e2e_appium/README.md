# Status Desktop E2E Appium Tests

E2E test framework for Status tablet and mobile builds using Appium and LambdaTest.

## Quick Start

### 1. Set Environment Variables

```bash
export LT_USERNAME="your_lambdatest_username"
export LT_ACCESS_KEY="your_lambdatest_access_key"
export STATUS_APP_URL="lt://APP123456789"  # Your LambdaTest app ID
```

### 2. Run the Onboarding Test

```bash
# Run onboarding flow test
pytest tests/test_onboarding_flow.py::TestOnboardingFlow::test_complete_onboarding_flow -v

# Run all onboarding tests
pytest tests/test_onboarding_flow.py -v
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `LT_USERNAME` | ✅ | - | LambdaTest username |
| `LT_ACCESS_KEY` | ✅ | - | LambdaTest access key |
| `STATUS_APP_URL` | ✅ | - | LambdaTest app ID (lt://APP123...) |
| `BUILD_NAME` | ❌ | "E2E_Appium Tests" | Build name in LambdaTest |
| `TEST_NAME` | ❌ | "Automated Test Run" | Test name in LambdaTest |
| `DEVICE_NAME` | ❌ | "Galaxy Tab S8" | Device for testing |
| `PLATFORM_VERSION` | ❌ | "14" | Android version |

## Test Markers

```bash
# Run only smoke tests
pytest -m smoke

# Run onboarding tests
pytest -m onboarding

# Run component tests
pytest -m component
```

## Reports

Test reports are generated in the `reports/` directory:
- `pytest_report.html` - HTML test report
- `pytest_results.xml` - JUnit XML report 