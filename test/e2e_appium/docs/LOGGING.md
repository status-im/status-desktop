# Logging Guide

Comprehensive logging system for Status E2E tests with multiple output formats.

## Overview

Each test run generates **4 types of files**:

| File Type | Purpose | Example |
|-----------|---------|---------|
| **Main Log** | Human-readable debug logs | `test_run_20250716_135012.log` |
| **JSON Log** | Machine-readable structured data | `structured_20250716_135012.json` |
| **HTML Report** | Visual test report with screenshots | `pytest_report_20250716_135012.html` |
| **XML Report** | JUnit format for CI/CD integration | `pytest_results_20250716_135012.xml` |

## File Locations

```
test/e2e_appium/
├── logs/                          # Debug logs
│   ├── test_run_TIMESTAMP.log     # Human-readable logs
│   └── structured_TIMESTAMP.json  # JSON logs
└── reports/local/                 # Test reports  
    ├── pytest_report_TIMESTAMP.html  # Visual report
    └── pytest_results_TIMESTAMP.xml # CI/CD results
```

## Log File Details

### 1. Main Log File (`test_run_*.log`)
**Purpose:** Human-readable debugging information

**Contains:**
- Test execution steps
- Page object actions
- Element interactions
- Timing information
- Error details

**Example:**
```
2025-07-16 13:50:29,348 | INFO | e2e_appium.pages | ✅ click_element: accessibility id: Create profile (160ms)
2025-07-16 13:50:30,546 | INFO | e2e_appium.pages | ✅ click_element: accessibility id: Not now (155ms)
```

**Use for:** Debugging test failures, understanding test flow

### 2. JSON Log File (`structured_*.json`)
**Purpose:** Machine-readable structured logging

**Contains:**
- Same information as main log
- Structured JSON format
- Timestamps, levels, modules

**Example:**
```json
{
  "timestamp": "2025-07-16T13:50:29.348",
  "level": "INFO",
  "logger": "e2e_appium.pages",
  "message": "✅ click_element: accessibility id: Create profile (160ms)",
  "module": "base_page",
  "function": "click_element"
}
```

**Use for:** Log analysis tools, monitoring systems, data processing

### 3. HTML Report (`pytest_report_*.html`)
**Purpose:** Visual test reporting

**Contains:**
- Test results summary
- Execution timeline
- Failed test details
- Environment information
- Metadata

**Use for:** Sharing results with team, visual debugging

### 4. XML Report (`pytest_results_*.xml`)
**Purpose:** CI/CD integration

**Contains:**
- JUnit XML format
- Test results summary
- Execution times
- Pass/fail status

**Example:**
```xml
<testsuites>
  <testsuite name="pytest" errors="0" failures="0" tests="1" time="87.494">
    <testcase classname="tests.test_onboarding_flow.TestOnboardingFlow" 
              name="test_complete_onboarding_flow" time="87.355" />
  </testsuite>
</testsuites>
```

**Use for:** Jenkins, GitHub Actions, test result tracking

## Configuration

### Log Levels
```yaml
# config/environments/local.yaml
logging:
  level: "DEBUG"    # DEBUG, INFO, WARNING, ERROR
```

### Enable/Disable Reports
```yaml
# config/environments/base.yaml
logging:
  enable_xml_report: true
  enable_html_report: true
  enable_junit_report: true
```

### Custom Directories
```yaml
# config/environments/local.yaml
directories:
  logs: "logs/local"
  reports: "reports/local"
```

## Runtime Control

### Disable Reports via Command Line
```bash
# Disable XML report
pytest tests/test_onboarding_flow.py --env=local --no-xml

# Disable HTML report
pytest tests/test_onboarding_flow.py --env=local --no-html

# Disable both
pytest tests/test_onboarding_flow.py --env=local --no-xml --no-html
```

### Custom Report Directory
```bash
pytest tests/test_onboarding_flow.py --env=local --reports-dir=custom_reports/
```

## Debugging with Logs

### Finding Test Failures
1. **Check HTML Report** - Visual overview of what failed
2. **Check Main Log** - Detailed execution flow
3. **Look for ERROR/WARNING** - Specific failure points

### Common Log Patterns

**Successful Element Interaction:**
```
✅ click_element: accessibility id: Create profile (160ms)
```

**Failed Element Interaction:**
```
❌ click_element: accessibility id: Invalid button (timeout after 45s)
```

**Configuration Loading:**
```
✅ Configuration loaded for local
   Device: sdk_gphone64_arm64 (android 15)
   App: /Users/username/Status-tablet-arm64.apk
   Timeouts: default=60s, wait=45s
```

**Test Progress:**
```
🧪 Starting test: test_complete_onboarding_flow
Step 1: Welcome Screen
Step 2: Analytics Screen
✅ Test PASSED: test_complete_onboarding_flow
```

## LambdaTest Result Reporting Logs

### Result Reporting Success
```
✅ Reported to LambdaTest: test_complete_onboarding_flow = PASSED
```

### Result Reporting Failure
```
⚠️ Failed to report result to LambdaTest: Connection timeout
```

### Compliance Validation
```
⚠️ Test 'test_example' didn't explicitly report result.
   Add 'self.report_test_result(passed=True/False)' for consistent LambdaTest status.
   Or use @lambdatest_reporting decorator for automatic reporting.
```

### Fallback Reporting
```
📋 Using fallback result reporting
```

### Step-Level Error Context
```
❌ Test failed at Password Screen: AssertionError: Password field not found
```

### Emergency Backup Reporting
```
📋 Emergency backup reporting: test_onboarding_flow = PASSED
```
**Note:** Only appears if test crashed before BaseTest teardown could report results.

## Test Pattern Validation Logs

### Validation Script Output
```bash
# Successful validation
✅ Compliant files (2):
  tests/test_onboarding_flow.py
  tests/test_data_manager.py
📊 Compliance Rate: 100.0% (2/2)
🎉 All tests follow proper patterns!

# With warnings
⚠️  Warnings (1):
  tests/test_example.py: test_method missing result reporting pattern.
💡 To fix warnings:
  1. Add @lambdatest_reporting decorator to test methods
  2. Or call self.report_test_result(passed=True/False) explicitly
```

## Log Analysis

### Quick Commands
```bash
# View latest log
tail -f logs/test_run_*.log

# Search for errors
grep "ERROR\|❌" logs/test_run_*.log

# Find timing issues
grep "timeout\|slow" logs/test_run_*.log

# Check element interactions
grep "click_element\|find_element" logs/test_run_*.log
```

### JSON Log Processing
```bash
# Extract test timings
jq '.message | select(contains("Test PASSED"))' logs/structured_*.json

# Filter by log level
jq 'select(.level == "ERROR")' logs/structured_*.json

# Get page object actions
jq 'select(.logger == "e2e_appium.pages")' logs/structured_*.json

# Check LambdaTest result reporting
jq 'select(.message | contains("Reported to LambdaTest"))' logs/structured_*.json

# Find compliance warnings
jq 'select(.message | contains("didn'\''t explicitly report"))' logs/structured_*.json
```

### LambdaTest Debugging
```bash
# Check result reporting status
grep "Reported to LambdaTest\|Failed to report" logs/test_run_*.log

# Find compliance issues
grep "didn't explicitly report\|fallback result reporting" logs/test_run_*.log

# Validate test patterns
python cli/validate_test_patterns.py --test-dir tests

# Check step-level failures
grep "Test failed at" logs/test_run_*.log
```

## Best Practices

### For Developers
1. **Use DEBUG level** for local development
2. **Check main log first** for quick debugging
3. **Use HTML report** for sharing results
4. **Keep logs organized** by timestamp

### For CI/CD
1. **Use XML reports** for result integration
2. **Set INFO level** to reduce log size
3. **Archive logs** for failed builds
4. **Configure log retention** policies

### For QA Teams
1. **Use HTML reports** for test reviews
2. **Check element timings** for performance issues
3. **Look for timeout patterns** indicating stability issues
4. **Share logs** with developers for bug reports

## File Size Management

### Typical Sizes
- Main Log: ~150KB per test
- JSON Log: ~150KB per test  
- HTML Report: ~170KB per test
- XML Report: <1KB per test

### Cleanup Commands
```bash
# Remove logs older than 7 days
find logs/ -name "*.log" -mtime +7 -delete
find logs/ -name "*.json" -mtime +7 -delete

# Remove old reports
find reports/ -name "*.html" -mtime +7 -delete
find reports/ -name "*.xml" -mtime +7 -delete
```

## Troubleshooting

### No Logs Generated
- Check directory permissions
- Verify `logs/` directory exists
- Check configuration in YAML files

### Missing Reports
- Verify `enable_xml_report: true` in config
- Check `reports/` directory exists
- Ensure no `--no-xml` flags used

### Large Log Files
- Reduce log level from DEBUG to INFO
- Implement log rotation
- Clean up old files regularly

### LambdaTest Result Reporting Issues

**Problem:** Tests show "Completed" instead of "Passed" in LambdaTest
**Solution:** 
- Check for compliance warnings in logs
- Run `python scripts/validate_test_patterns.py`
- Add `@lambdatest_reporting` decorator or explicit `report_test_result()` calls

**Problem:** "Failed to report result to LambdaTest" errors
**Solution:**
- Verify LambdaTest credentials (`LT_USERNAME`, `LT_ACCESS_KEY`)
- Check network connectivity
- Confirm driver session is still active

**Problem:** Missing step context in error messages
**Solution:**
- Add `self._current_step = "Step Name"` before each test step
- Use decorator pattern which automatically includes step context

**Problem:** Compliance warnings for all tests
**Solution:**
- Migrate tests to use supported reporting patterns
- Run validation script to identify specific issues
- See `README_result_reporting.md` for migration guide

This logging system provides comprehensive debugging and reporting capabilities for the Status E2E test framework, including specialized LambdaTest result reporting and compliance validation. 