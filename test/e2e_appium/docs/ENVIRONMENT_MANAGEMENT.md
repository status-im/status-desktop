# Environment Management

YAML-based configuration system for managing different test environments.

## Overview

The framework uses YAML configuration files to manage environment-specific settings like device configuration, timeouts, and directories.

## Available Environments

```bash
# List available environments
python cli/env_manager.py list
```

**Built-in environments:**
- **local** - Local emulator testing
- **lambdatest** - LambdaTest cloud testing

## Environment Files

Located in `config/environments/`:

```
config/environments/
├── base.yaml        # Common settings for all environments
├── local.yaml       # Local testing configuration  
└── lambdatest.yaml  # LambdaTest cloud configuration
```

### Configuration Structure

Each environment file contains:

```yaml
metadata:
  environment: "local"
  description: "Local development environment"

device:
  name: "sdk_gphone64_arm64"
  platform_version: "15"

timeouts:
  default: 60
  element_wait: 45

logging:
  level: "DEBUG"
  enable_video_recording: false

directories:
  logs: "logs/local"
  reports: "reports/local"

app:
  source_type: "local_file"
  path_template: "${LOCAL_APP_PATH}"
```

## Environment Variables

Required environment variables:

**For Local Testing:**
```bash
export LOCAL_APP_PATH="/path/to/your/Status-tablet-arm64.apk"
export CURRENT_TEST_ENVIRONMENT="local"
```

**For LambdaTest:**
```bash
export LT_USERNAME="your_username"
export LT_ACCESS_KEY="your_access_key" 
export STATUS_APP_URL="lt://APP123456789"
export CURRENT_TEST_ENVIRONMENT="lambdatest"
```

## CLI Management

### Validate Environment
```bash
# Check if environment is properly configured
python cli/env_manager.py validate local
python cli/env_manager.py validate lambdatest
```

### Auto-Detection
```bash
# Automatically detect best environment
python cli/env_manager.py auto-detect
```

Auto-detection logic:
1. If `LT_USERNAME` and `LT_ACCESS_KEY` set → "lambdatest"
2. If Appium server running on localhost:4723 → "local"  
3. Otherwise → "local" (fallback)

## Usage in Tests

### Command Line Override
```bash
# Override environment variable with --env flag
pytest tests/test_onboarding_flow.py --env=local -v
pytest tests/test_onboarding_flow.py --env=lambdatest -v
```

### Environment Precedence
1. **--env flag** (highest priority)
2. **CURRENT_TEST_ENVIRONMENT** environment variable
3. **Default: "lambdatest"** (lowest priority)

## Configuration Loading

The framework:
1. Loads `base.yaml` for common settings
2. Loads environment-specific file (e.g., `local.yaml`)
3. Merges configurations (environment overrides base)
4. Substitutes environment variables (e.g., `${LOCAL_APP_PATH}`)
5. Validates against JSON schema

## Validation

Configuration files are validated using JSON schema in `config/schemas/environment.json`.

Common validation checks:
- Required fields present
- Valid environment names
- Timeout values within range (5-300 seconds)
- Valid platform names ("android", "ios")

## Example Validation Output

```bash
$ python cli/env_manager.py validate local
✅ Environment 'local' is valid

Configuration Summary:
  Device: sdk_gphone64_arm64
  Platform: android 15
  App Source: local_file
  Appium Server: http://localhost:4723
```

## Troubleshooting

### Environment Not Found
```bash
❌ Environment 'staging' not found. Available: local, lambdatest
```
**Solution:** Use existing environment or create new YAML file.

### Missing Variables
```bash
❌ Missing LambdaTest variables: ['LT_USERNAME', 'LT_ACCESS_KEY']
```
**Solution:** Set required environment variables.

### App Not Found
```bash
❌ Local app not found: /path/to/missing.apk
```
**Solution:** Verify `LOCAL_APP_PATH` points to existing file.

### Appium Connection Failed
```bash
❌ Cannot connect to Appium server
```
**Solution:** Start Appium server with `appium` command.

## File Locations

After configuration loading, files are organized by environment:

**Local Environment:**
```
logs/local/
reports/local/
screenshots/local/
```

**LambdaTest Environment:**
```
logs/
reports/
screenshots/
```

This environment management system provides consistent configuration across different testing environments. 