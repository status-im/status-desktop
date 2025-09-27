# Writing Tests: Complete Guide

A step-by-step tutorial for adding new tests to the Status Desktop E2E framework.

## 🎯 Overview

This guide walks you through creating a complete test from scratch, including:
- Setting up your development environment
- Finding UI elements using inspection tools
- Creating page objects and locators
- Writing and running tests
- Debugging common issues

**Time Estimate**: 45-60 minutes for your first test

## 🎯 Testing Pattern

**Page methods**: Focus on UI interactions, return `None`
**Tests**: Focus on asserting user outcomes

```python
# Page method - simple, focused
def navigate_to_send(self) -> None:
    self.safe_click(self.locators.WALLET_TAB)
    self.safe_click(self.locators.SEND_BUTTON)

# Test - assert what matters to the user
def test_send_transaction(self, onboarded_user):
    send_page.navigate_to_send()
    send_page.enter_amount("0.001")
    
    review_details = send_page.get_review_details()
    assert review_details['amount'] == "0.001 ETH"
```

## 📋 Prerequisites

Before starting, ensure you have:
- ✅ [Development environment setup](../CONTRIBUTING.md#development-setup-5-min) completed
- ✅ Access to LambdaTest account OR local Android setup
- ✅ Basic understanding of Python and pytest
- ✅ Status Desktop APK available

## 🛠️ Tutorial: Adding a Wallet Send Transaction Test

We'll create a complete test for wallet transaction functionality as a real-world example.

### Step 1: Planning Your Test

**Define the Test Scope:**
```python
# Test Goal: Verify user can initiate a send transaction
# User Flow: Main App → Wallet → Send → Enter Details → Review
# Assertions: 
#   - Send button is clickable
#   - Transaction form accepts input
#   - Review screen displays correct details
```

**Choose Test Category:**
- Primary marker: eg. `@pytest.mark.wallet`
- Secondary marker: eg. `@pytest.mark.smoke` (if critical functionality)

### Step 2: Environment Setup

**Option A: LambdaTest (Recommended)**
```bash
cd test/e2e_appium

# Set environment variables
export LT_USERNAME="your_lambdatest_username"
export LT_ACCESS_KEY="your_lambdatest_access_key"
export STATUS_APP_URL="lt://your_app_id"

# Run existing test to verify setup
pytest -m onboarding --env=lambdatest -v
```

**Option B: Local Development**
```bash
# Start Appium server
appium &

# Verify Android device/emulator
adb devices

# Set local environment
export LOCAL_APP_PATH="/path/to/Status-tablet.apk"
export CURRENT_TEST_ENVIRONMENT="local"

# Run existing test to verify setup
pytest -m onboarding --env=local -v
```

### Step 3: Exploring the UI

**Manual App Navigation:**
1. Launch Status app (via test or manually)
2. Complete onboarding (or use `onboarded_user` fixture)
3. Navigate to: Main App → Wallet → Send
4. Identify all interactive elements you'll need to test

**Key Elements to Identify:**
- Wallet tab/button
- Send transaction button
- Recipient address field
- Amount input field
- Asset selector
- Next/Continue buttons
- Review screen elements

### Step 4: Finding UI Locators

**Option A: LambdaTest Inspector (Easiest)**
1. Start a test session on LambdaTest
2. Click "Inspector" button in the session toolbar
3. Navigate to your target screen in the app
4. Click elements to see their properties in the inspector panel
5. Copy accessibility ID, resource ID, or content description

**Option B: XML Source Dump**

**Method 1: Manual ADB Dump (No Code Needed)**
```bash
# Get current screen XML directly via ADB
adb shell uiautomator dump /sdcard/screen.xml
adb pull /sdcard/screen.xml .

# Open screen.xml in any text editor and search for your element
# Look for: resource-id, content-desc, text attributes
```

**Method 2: Programmatic Dump (From Tests)**
```python
# Add this to any test to get complete screen XML
def debug_current_screen(self):
    xml_source = self.driver.page_source
    with open("current_screen.xml", "w") as f:
        f.write(xml_source)
    print("📄 XML saved to current_screen.xml - search for your element")
```

**Option C: Appium Inspector Desktop App**
1. Download from GitHub: `appium/appium-inspector/releases`
2. Connect to session:
   ```json
   {
     "platformName": "Android",
     "appium:deviceName": "Galaxy Tab S8",
     "appium:app": "lt://your_app_id", 
     "appium:automationName": "UiAutomator2"
   }
   ```
3. Click "Start Session" to inspect elements visually

**Locator Stability Priority:**
```python
# ✅ BEST - Accessibility ID (most stable)
SEND_BUTTON = BaseLocators.accessibility_id("Send Transaction")

# ✅ GOOD - Resource ID
AMOUNT_INPUT = BaseLocators.id("amount-input-field")

# ⚠️ OK - Content description  
WALLET_TAB = BaseLocators.android_uiautomator('description("Wallet")')

# ❌ AVOID - XPath (fragile)
SEND_BUTTON = (By.XPATH, "//android.widget.Button[3]")
```

**Quick Locator Testing:**
```python
# Test locators in Python console or add to existing test
element = self.driver.find_element(By.ACCESSIBILITY_ID, "Send Transaction")
print(f"Found: {element.is_displayed()}")
```

### Step 5: Creating Locators File

**Create**: `locators/wallet/send_transaction_locators.py`

```python
from locators.base_locators import BaseLocators


class SendTransactionLocators(BaseLocators):
    """Locators for wallet send transaction functionality."""
    
    WALLET_TAB = BaseLocators.id("wallet-tab")
    SEND_BUTTON = BaseLocators.accessibility_id("Send Transaction")
    RECIPIENT_INPUT = BaseLocators.id("recipient-address-input")
    AMOUNT_INPUT = BaseLocators.id("amount-input-field")
    NEXT_BUTTON = BaseLocators.accessibility_id("Next")
    REVIEW_RECIPIENT = BaseLocators.id("review-recipient-address")
    REVIEW_AMOUNT = BaseLocators.id("review-amount")
    ERROR_MESSAGE = BaseLocators.id("transaction-error-message")
```

### Step 6: Creating Page Object

**Create**: `pages/wallet/send_transaction_page.py`

```python
from typing import Optional
from pages.base_page import BasePage
from locators.wallet.send_transaction_locators import SendTransactionLocators


class SendTransactionPage(BasePage):
    """Page object for wallet send transaction functionality."""
    
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = SendTransactionLocators()
    
    def navigate_to_send(self) -> None:
        self.safe_click(self.locators.WALLET_TAB)
        self.safe_click(self.locators.SEND_BUTTON)
    
    def enter_recipient_address(self, address: str) -> None:
        self.qt_safe_input(self.locators.RECIPIENT_INPUT, address)
    
    def enter_amount(self, amount: str) -> None:
        self.qt_safe_input(self.locators.AMOUNT_INPUT, amount)
    
    def click_next(self) -> None:
        self.safe_click(self.locators.NEXT_BUTTON)
    
    def get_review_details(self) -> dict:
        """Get transaction details from review screen."""
        recipient_element = self.find_element(self.locators.REVIEW_RECIPIENT)
        amount_element = self.find_element(self.locators.REVIEW_AMOUNT)
        
        return {
            'recipient': recipient_element.get_attribute("text") if recipient_element else "",
            'amount': amount_element.get_attribute("text") if amount_element else ""
        }
    
    def get_error_message(self) -> Optional[str]:
        """Get error message if transaction failed."""
        if self.is_element_visible(self.locators.ERROR_MESSAGE):
            error_element = self.find_element(self.locators.ERROR_MESSAGE)
            return error_element.get_attribute("text") if error_element else None
        return None
```

### Step 7: Writing the Test

**Create**: `tests/test_wallet_send_transaction.py`

```python
import pytest
from tests.base_test import BaseTest, lambdatest_reporting
from pages.wallet.send_transaction_page import SendTransactionPage
from utils.generators import generate_seed_phrase


class TestWalletSendTransaction(BaseTest):
    """Test suite for wallet send transaction functionality."""
    
    @pytest.mark.wallet
    @pytest.mark.smoke
    @lambdatest_reporting
    def test_send_transaction_form_validation(self, onboarded_user):
        """Test that send transaction form accepts valid input."""
        # Arrange
        send_page = SendTransactionPage(self.driver)
        test_address = "0x742d35Cc6B5F9E5F27ff6E7B3F5c37b4D7E0d5B7"  # Valid test address
        test_amount = "0.001"
        
        # Act
        send_page.navigate_to_send()
        send_page.enter_recipient_address(test_address)
        send_page.enter_amount(test_amount)
        send_page.click_next()
        
        # Assert
        review_details = send_page.get_review_details()
        assert review_details['recipient'] == test_address, "Review should show correct recipient"
        assert test_amount in review_details['amount'], "Review should show correct amount"
        
        self.logger.info("✅ Send transaction form validation completed successfully")
    
    @pytest.mark.wallet
    @lambdatest_reporting  
    def test_send_transaction_error_handling(self, onboarded_user):
        """Test error handling for invalid transaction inputs."""
        # Arrange
        send_page = SendTransactionPage(self.driver)
        invalid_address = "not-a-valid-address"
        
        # Act
        send_page.navigate_to_send()
        send_page.enter_recipient_address(invalid_address)
        send_page.enter_amount("999999")  # Excessive amount
        send_page.click_next()
        
        # Assert
        error_message = send_page.get_error_message()
        assert error_message is not None, "Should display error message for invalid input"
        assert "invalid" in error_message.lower() or "insufficient" in error_message.lower(), \
            "Error message should indicate the specific problem"
        
        self.logger.info("✅ Send transaction error handling validated")
```

### Step 8: Running Your Test

**Local Execution:**
```bash
# Run your specific test
pytest tests/test_wallet_send_transaction.py -v

# Run with specific marker
pytest -m wallet -v

# Run single test method
pytest tests/test_wallet_send_transaction.py::TestWalletSendTransaction::test_send_transaction_form_validation -v
```

**LambdaTest Execution:**
```bash
# Run on cloud devices
pytest -m wallet --env=lambdatest -v

# With detailed logging
pytest -m wallet --env=lambdatest -v -s
```

**Verify Results:**
- Check console output for test results
- Review generated HTML reports in `reports/` directory
- Check LambdaTest dashboard for video recordings

### Step 9: Debugging Common Issues

**Element Not Found:**
```python
# Add debug information to your page object
def navigate_to_send(self) -> None:
    self.logger.info("Debugging: Looking for wallet tab")
    if not self.is_element_visible(self.locators.WALLET_TAB):
        self.logger.error("Wallet tab not visible")
        self.take_screenshot("wallet_tab_missing")
        raise Exception("Wallet tab not found")
    self.safe_click(self.locators.WALLET_TAB)
```

**Timing Issues:**
```python
# Use explicit waits instead of sleep
from selenium.webdriver.support import expected_conditions as EC

def wait_for_send_screen(self) -> bool:
    """Wait for send transaction screen to load."""
    try:
        self.wait.until(EC.element_to_be_clickable(self.locators.RECIPIENT_INPUT))
        return True
    except TimeoutException:
        self.logger.error("Send screen did not load within timeout")
        return False
```

**Qt/QML Input Issues:**
```python
# Use qt_safe_input for Qt components
def enter_recipient_address(self, address: str) -> None:
    # Clear field first
    element = self.find_element(self.locators.RECIPIENT_INPUT)
    element.clear()
    
    # Use framework's Qt-safe input method
    self.qt_safe_input(self.locators.RECIPIENT_INPUT, address)
```

## 🔧 Troubleshooting Guide

### Common Issues and Solutions

**Test Fails on "Navigate to Send":**
- Verify onboarding completed successfully
- Check if wallet is initialized (may need funded wallet fixture)
- Ensure app is in correct state before navigation

**Locators Not Working:**
- Use Appium Inspector to verify current locators
- Check if UI has changed since locator creation
- Try alternative locator strategies (accessibility ID → resource ID → XPath)

**Input Fields Not Accepting Text:**
- Use `qt_safe_input()` for Qt/QML components
- Ensure field is clickable before entering text
- Check for virtual keyboard interference

**Test Passes Locally, Fails on LambdaTest:**
- Verify device capabilities match test requirements
- Check for timing differences (add waits if needed)
- Ensure APK version matches between environments

## 📋 Code Review Checklist

Before submitting your test:

**Code Quality:**
- [ ] All imports at top of file
- [ ] Type hints for all methods
- [ ] Clear test method names following `test_[action]_[expected_result]` pattern
- [ ] Appropriate pytest markers
- [ ] Error messages in assertions explain what should happen

**Framework Compliance:**
- [ ] Inherits from `BaseTest`
- [ ] Uses page objects for UI interactions
- [ ] Locators in separate file following naming conventions
- [ ] Uses framework utility methods (`safe_click`, `qt_safe_input`)
- [ ] Includes `@lambdatest_reporting` decorator
- [ ] Page methods return `None`, tests assert user outcomes

**Test Quality:**
- [ ] Test has clear purpose and scope
- [ ] Uses appropriate fixtures (`onboarded_user`, etc.)
- [ ] Independent from other tests
- [ ] Includes positive and negative test cases
- [ ] Proper cleanup (framework handles this automatically)

## 🎯 Next Steps

After completing your first test:

1. **Add More Test Cases**: Consider edge cases and error scenarios
2. **Optimize Page Objects**: Extract common patterns into base classes
3. **Add Test Data**: Use fixtures for complex test data setup
4. **Review Existing Tests**: Study patterns in `tests/test_onboarding_flow.py`
5. **Contribute Back**: Submit PR following [CONTRIBUTING.md](../CONTRIBUTING.md) guidelines

## 📚 Additional Resources

- **[Framework Structure](../CONTRIBUTING.md#framework-structure)**: Understanding the codebase organization
- **[Code Guidelines](../CONTRIBUTING.md#code-guidelines)**: Style and quality requirements
- **[Existing Tests](../tests/)**: Examples and patterns to follow
- **[Appium Documentation](http://appium.io/docs/)**: Official Appium guides
- **[Pytest Documentation](https://docs.pytest.org/)**: Test framework reference

---

**Need Help?** See the [Getting Help](../CONTRIBUTING.md#getting-help) section in CONTRIBUTING.md for communication channels and how to ask effective questions.
