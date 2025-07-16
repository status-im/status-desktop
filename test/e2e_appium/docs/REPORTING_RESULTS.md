# LambdaTest Result Reporting

## Overview

This framework ensures consistent LambdaTest result reporting, preventing "Completed" status in favor of clear "Passed"/"Failed" results.

## Quick Start

### Method 1: Decorator Pattern (Recommended)
```python
from tests.base_test import BaseTest, lambdatest_reporting

class TestExample(BaseTest):
    
    @lambdatest_reporting
    def test_something(self):
        # Your test logic here
        assert something_works()
        # Result automatically reported
```

### Method 2: Explicit Reporting
```python
class TestExample(BaseTest):
    
    def test_something(self):
        try:
            # Your test logic here
            assert something_works()
            self.report_test_result(passed=True)
        except Exception as e:
            self.report_test_result(passed=False, error_message=str(e))
            raise
```

### Method 3: Template Pattern
```python
from tests.base_test import CloudTestCase

class TestExample(BaseTest, CloudTestCase):
    
    def test_something(self):
        def test_logic():
            # Your test logic here
            assert something_works()
        
        self.run_test_with_reporting(test_logic)
```

## Features

### Automatic Enforcement
- Tests without proper reporting patterns receive warnings
- Fallback reporting prevents "Completed" status
- Validation script ensures team compliance

### Error Context
- Failed tests include step-level error information
- Clear failure messages in LambdaTest dashboard
- Automatic error categorization

### Step Tracking
```python
@lambdatest_reporting
def test_flow(self):
    self._current_step = "Login"
    # Login logic
    
    self._current_step = "Navigation"  
    # Navigation logic
    
    # If failure occurs, error will show which step failed
```

## Validation

### Run Pattern Validation
```bash
# Check all tests
python cli/validate_test_patterns.py

# Get fix suggestions
python cli/validate_test_patterns.py --fix-warnings

# Check specific directory
python cli/validate_test_patterns.py --test-dir custom/path
```

### CI Integration
Add to your CI pipeline:
```yaml
- name: Validate Test Patterns
  run: python test/e2e_appium/cli/validate_test_patterns.py
```

## How It Works

### Before (Inconsistent)
- Some tests: "Passed" ✅
- Other tests: "Completed" ❓ 
- Race condition dependent

### After (Consistent) 
- All tests: "Passed" or "Failed" ✅
- Deterministic behavior
- Clear error context

### Architecture
1. **BaseTest**: Tracks reporting state, validates compliance
2. **Decorator**: Automatic try/catch with result reporting
3. **Validation**: AST analysis ensures pattern adoption
4. **Fallback**: Pytest hooks as safety net

## Migration Guide

### Existing Tests
1. Add `@lambdatest_reporting` decorator to test methods
2. Or add explicit `self.report_test_result()` calls
3. Run validation script to verify compliance

### New Tests
- Use decorator pattern for simple tests
- Use explicit reporting for complex error handling
- Use template pattern for shared test logic

## Benefits

- **Consistent Results**: Always "Passed"/"Failed", never "Completed"
- **Better Debugging**: Step-level error context
- **Team Compliance**: Automatic validation and warnings
- **Maintainable**: Clear patterns, no boilerplate duplication
- **Reliable**: No race conditions or timing dependencies

## Troubleshooting

### Warning: "Test didn't explicitly report result"
Add one of the reporting patterns above.

### Error: "Failed to report result to LambdaTest"
Check LambdaTest credentials and network connectivity.

### Test shows "Completed" instead of "Passed"
Ensure you're using one of the supported reporting patterns. 