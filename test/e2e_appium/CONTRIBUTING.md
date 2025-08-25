# Contributing to E2E_Appium Testing Framework

Welcome! This guide helps you contribute to the Status e2e_appium testing framework effectively.

## 🚀 Quick Start for Contributors

### 1. Development Setup (5 min)
```bash
# Fork and clone the repository
git clone https://github.com/status-im/status-desktop.git
cd status-desktop/test/e2e_appium

# Install dependencies
pip install -r requirements.txt
```

### 2. Run Your First Test (10 min)
**Option A: LambdaTest (Recommended)**
```bash
export LT_USERNAME="your_lambdatest_username"
export LT_ACCESS_KEY="your_lambdatest_access_key" 
export STATUS_APP_URL="lt://your_app_id"
pytest -m smoke --env=lambdatest -v
```

**Option B: Local (Advanced)**
```bash
# Start Appium server first: appium
export LOCAL_APP_PATH="/path/to/Status-tablet.apk"
pytest -m smoke --env=local -v
```

## 📋 Before You Start

### Required Knowledge
- **Python**: Basic to intermediate proficiency
- **Pytest**: Understanding of fixtures, markers, and assertions
- **Mobile Testing**: Basic understanding of mobile app testing concepts
- **Git**: Standard workflow (fork, branch, commit, PR)

### Development Environment
- **LambdaTest Account**: For cloud testing (recommended for contributors)
- **Android Setup**: Only needed for local testing (advanced contributors)
- **IDE**: VS Code, PyCharm, or similar with Python support

## 🧪 Writing Tests

### 📖 Complete Tutorial

**New to writing tests?** Follow our comprehensive step-by-step guide:  
**→ [Writing Tests: Complete Guide](docs/WRITING_TESTS.md)**

This tutorial walks you through creating a complete test from scratch, including finding UI elements, creating page objects, and debugging common issues.

### Test Structure Guidelines

**✅ Good Test Structure:**
```python
class TestWalletFeatures(BaseTest):
    
    @pytest.mark.wallet
    @pytest.mark.smoke
    def test_user_can_view_transaction_history(self, onboarded_user):
        """Test that user can access and view their transaction history."""
        # Arrange
        wallet_page = WalletPage(self.driver)
        
        # Act - Navigate and interact (let page methods fail naturally if UI broken)
        wallet_page.navigate_to_wallet()
        wallet_page.open_transaction_history()
        
        # Assert - Test the user outcome that matters
        assert wallet_page.is_transaction_history_visible(), "Transaction history should be accessible"
        assert wallet_page.get_transaction_count() >= 0, "Should show transaction count"
```

**❌ Avoid These Patterns:**
```python
def test_stuff(self):  # Vague test name
    # No docstring
    welcome_page = WelcomePage(self.driver)  # Direct driver access
    assert welcome_page.click_button(), "Should click button"  # Testing implementation, not outcome
    time.sleep(5)  # Hard-coded waits
```

### Code Style Requirements

**Python Standards:**
- **PEP 8 compliance**: Use `black` formatter and `ruff` linter
- **Type hints**: Required for all function parameters and return values
- **Import organization**: All imports at file top, grouped (stdlib, third-party, local)
- **Docstrings**: Required for complex user logic, optional for simple page object methods

**Framework-Specific:**
- **Page Object Model**: All UI interactions through page objects
- **BaseTest inheritance**: All test classes inherit from `BaseTest`
- **Pytest markers**: Tag tests appropriately (`@pytest.mark.smoke`, `@pytest.mark.onboarding`)
- **Safe interactions**: Use `safe_click()`, `qt_safe_input()` for Qt/QML components

### Test Categories and Markers

**Primary Markers:**
- `@pytest.mark.smoke` - Core functionality that must always work
- `@pytest.mark.onboarding` - User registration and initial setup flows  
- `@pytest.mark.critical` - Essential features for app functionality
- `@pytest.mark.performance` - Performance validation tests

**Secondary Markers:**
- `@pytest.mark.wallet` - Crypto wallet functionality
- `@pytest.mark.messaging` - Chat and messaging features
- `@pytest.mark.communities` - Community features
- `@pytest.mark.settings` - App configuration and settings

### Page Object Guidelines

**✅ Good Page Object:**
```python
class CreateProfilePage(BasePage):
    
    def click_create_with_password(self) -> bool:
        """Click the 'Create with password' button."""
        return self.safe_click(self.locators.CREATE_WITH_PASSWORD_BUTTON)
    
    def enter_display_name(self, name: str) -> bool:
        """Enter display name in the input field."""
        return self.qt_safe_input(self.locators.DISPLAY_NAME_INPUT, name)
```

**❌ Avoid These Patterns:**
```python
class CreateProfilePage(BasePage):
    
    def do_everything(self):  # Too many responsibilities
        # 50 lines of code doing multiple things
    
    def click_button(self):  # Vague method name
        self.driver.find_element(By.ID, "button").click()  # Direct driver access
```

## 📁 File Organization

### Where to Put New Files

**Test Files**: `tests/test_[feature_name].py`
```python
# tests/test_wallet_operations.py
class TestWalletOperations(BaseTest):
    pass
```

**Page Objects**: `pages/[area]/[page_name]_page.py`
```python  
# pages/wallet/send_transaction_page.py
class SendTransactionPage(BasePage):
    pass
```

**Locators**: `locators/[area]/[page_name]_locators.py`
```python
# locators/wallet/send_transaction_locators.py
class SendTransactionLocators(BaseLocators):
    pass
```

**Fixtures**: `fixtures/[feature_name]_fixtures.py`
```python
# fixtures/wallet_fixtures.py
@pytest.fixture
def funded_wallet():
    pass
```

### Naming Conventions

**Files**: `snake_case.py`
**Classes**: `PascalCase`
**Methods**: `snake_case`
**Constants**: `UPPER_SNAKE_CASE`
**Test Methods**: `test_[action]_[expected_result]`

## 🔄 Development Workflow

### 1. Issue and Branch Management
```bash
# Create feature branch
git checkout -b feature/wallet-send-transaction

# Or bug fix branch  
git checkout -b fix/onboarding-password-validation
```

### 2. Development Process
1. **Write tests**
1. **Add locators** as needed
2. **Implement page objects** as needed
3. **Run tests locally** to verify functionality
4. **Add appropriate markers** and documentation
5. **Ensure code style compliance**

### 3. Testing Your Changes
```bash
# Run your specific tests
pytest tests/test_your_feature.py -v

# Run affected test categories  
pytest -m wallet -v

# Run smoke tests to ensure no regressions
pytest -m smoke --env=lambdatest -v
```

### 4. Pre-Commit Checklist
- [ ] Tests pass locally or on LambdaTest
- [ ] Code follows style guidelines (run `black` and `ruff`)
- [ ] New tests have appropriate markers
- [ ] Page objects follow framework patterns
- [ ] No hardcoded waits or magic numbers
- [ ] Documentation updated if needed

## 📤 Submitting Contributions

### Pull Request Requirements

**PR Title Format:**
- `feat: add wallet transaction history tests`
- `fix: resolve onboarding password validation issue` 
- `docs: update contributing guidelines`
- `refactor: improve page object structure`

**PR Description Must Include:**
- **What**: Clear description of changes
- **Why**: Reason for the change
- **Testing**: How you tested the changes
- **Screenshots**: For UI-related changes

**Example PR Description:**
```markdown
## What
Adds comprehensive tests for wallet transaction history functionality.

## Why  
Transaction history is a critical wallet feature that was not covered by automated tests.

## Testing
- [x] Ran `pytest -m wallet --env=lambdatest -v` 
- [x] All new tests pass on Galaxy Tab S8
- [x] Existing smoke tests still pass

## Related Issues
Closes #123
```

### Code Review Process

**What Reviewers Look For:**
1. **Test Quality**: Clear intent, proper assertions, good coverage
2. **Code Style**: PEP 8 compliance, proper typing, clear naming
3. **Framework Consistency**: Follows established patterns
4. **Performance**: No unnecessary waits, efficient selectors
5. **Maintainability**: Code is readable and well-organized

**Review Timeline:**
- **Initial Review**: Within 3 work days
- **Follow-up Reviews**: Within 2 work day
- **Approval**: Requires 2 approval from maintainer

## 🔧 Common Issues and Solutions

### Test Development Issues

**Issue: Test is flaky/unreliable**
```python
# ❌ Don't do this
time.sleep(5)

# ✅ Do this instead  
self.wait.until(EC.element_to_be_clickable(locator))
```

**Issue: Can't find UI elements**
```python
# ❌ Generic locators
By.ID, "button" 

# ✅ Specific, stable locators
By.ACCESSIBILITY_ID, "Send Transaction Button"
```

**Issue: Qt/QML text input not working**
```python
# ❌ Standard web input
element.send_keys(text)

# ✅ Qt-safe input method
self.qt_safe_input(locator, text)
```

### Environment Issues

**LambdaTest Connection Issues:**
- Verify credentials are correct
- Check STATUS_APP_URL format (`lt://APP123...`)
- Ensure LambdaTest account has active subscription

**Local Testing Issues:**
- Ensure Appium server is running (`appium`)
- Verify Android emulator/device is connected (`adb devices`)
- Check LOCAL_APP_PATH points to valid APK file

## 🎯 Testing Best Practices

### Test Design Principles

1. **Independent Tests**: Each test should run in isolation
2. **Clear Intent**: Test name and content should be self-explanatory
3. **Minimal Setup**: Use fixtures to reduce test complexity
4. **Focused Assertions**: Test one concept per test method
5. **Stable Locators**: Use accessibility IDs over XPath when possible

### Mobile Testing Considerations

1. **Device Orientation**: Tests should work in both landscape and portrait
2. **Different Screen Sizes**: Consider tablet vs mobile form factors
3. **Network Conditions**: Tests should handle slow networks gracefully
4. **Keyboard Interference**: Always hide keyboard after text input
5. **App State**: Clean up after tests to avoid state pollution

## 📚 Resources

### Learning Materials
- **[Appium Documentation](http://appium.io/docs/en/2.0/)**: Official Appium guide
- **[Pytest Documentation](https://docs.pytest.org/)**: Comprehensive pytest guide
- **[Page Object Model](https://selenium-python.readthedocs.io/page-objects.html)**: Design pattern explanation

### Framework Resources
- **[Framework Architecture](docs/ARCHITECTURE.md)**: Detailed design documentation (coming soon)
- **[Epic #18436](https://github.com/status-im/status-desktop/issues/18436)**: Project roadmap and status
- **[Test Examples](tests/test_onboarding_flow.py)**: Reference implementation

## 💬 Getting Help

### Communication Channels
- **GitHub Issues**: Bug reports and feature requests
- **Status Discord / Status App**: Questions and general discussion
- **Pull Request Comments**: Code-specific questions

### When to Ask for Help
- **Stuck for > 30 minutes**: Don't hesitate to ask
- **Framework Questions**: Architecture or design decisions
- **Test Strategy**: Unsure how to test a specific feature
- **Environment Issues**: Setup or configuration problems

### How to Ask Good Questions
1. **Context**: What are you trying to achieve?
2. **Problem**: What specifically isn't working?
3. **Attempts**: What have you already tried?
4. **Environment**: LambdaTest vs local, device details
5. **Code**: Include relevant code snippets

## 🎉 Recognition

Contributors who make meaningful improvements to the framework will be:
- **Acknowledged** in release notes
- **Added** to contributor documentation
- **Invited** to participate in framework design discussions

Thank you for contributing to the Status e2e_appium testing framework! Your efforts help ensure the quality and reliability of the Status tablet and mobile apps.
