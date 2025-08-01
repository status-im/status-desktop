#!/usr/bin/env python3
"""
Simple test runner for Status Desktop E2E tests.
Supports environment variable configuration.
"""

import subprocess
import sys
import os


def run_tests(env="lt"):
    """Run the E2E tests with specified environment."""
    
    # Validate environment before running tests
    try:
        sys.path.insert(0, os.path.dirname(__file__))
        from core import EnvironmentSwitcher, ConfigurationError
        
        switcher = EnvironmentSwitcher()
        if env == "auto":
            env = switcher.auto_detect_environment()
            print(f"🔍 Auto-detected environment: {env}")
        
        config = switcher.switch_to(env)
        print(f"✅ Using environment: {env}")
        print(f"   Device: {config.device_name}")
        print(f"   App: {config.get_resolved_app_path()}")
        
    except ConfigurationError as e:
        print(f"❌ Configuration error: {e}")
        return 1
    
    # Build pytest command
    cmd = [
        "python", "-m", "pytest", 
        "tests/test_basic_tablet.py",
        f"--env={env}",
        "-v"
    ]
    
    print(f"Running command: {' '.join(cmd)}")
    
    # Run the tests
    result = subprocess.run(cmd, cwd=os.path.dirname(__file__))
    return result.returncode


def print_usage():
    """Print usage information."""
    print("""
Usage: python run_tests.py [environment]

Environments:
  lt, lambdatest  - Run tests on LambdaTest cloud (default)
  local          - Run tests on local Appium server
  auto           - Auto-detect best environment

Environment Variables:
  Required for LambdaTest:
    LT_USERNAME      - Your LambdaTest username
    LT_ACCESS_KEY    - Your LambdaTest access key
    STATUS_APP_URL   - LambdaTest app ID (lt://APP123...)
    
  Required for Local:
    LOCAL_APP_PATH   - Path to APK file

Examples:
  python run_tests.py auto        # Auto-detect environment
  python run_tests.py lt          # Run on LambdaTest
  python run_tests.py local       # Run locally
  
Environment Management:
  python cli/env_manager.py list         # List available environments
  python cli/env_manager.py validate lt  # Validate environment
""")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] in ["-h", "--help", "help"]:
        print_usage()
        sys.exit(0)
    
    env = sys.argv[1] if len(sys.argv) > 1 else "lt"
    
    if env not in ["lt", "lambdatest", "local", "auto"]:
        print(f"Error: Unknown environment '{env}'")
        print_usage()
        sys.exit(1)
    
    exit_code = run_tests(env)
    sys.exit(exit_code) 