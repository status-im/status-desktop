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
    
    # Build pytest command
    cmd = [
        "python", "-m", "pytest", 
        "tests/test_basic_tablet.py",
        f"--env={env}",
        "-v"
    ]
    
    print(f"Running command: {' '.join(cmd)}")
    print(f"Environment: {env}")
    
    # Show configuration status
    if env in ["lt", "lambdatest"]:
        lt_username = os.getenv('LT_USERNAME', '')
        app_url = os.getenv('STATUS_APP_URL', '')
        
        if not lt_username:
            print("WARNING: LT_USERNAME not set. Tests may fail.")
        if not app_url:
            print("WARNING: STATUS_APP_URL not set. Using default.")
        
        print(f"LambdaTest User: {lt_username or 'Not configured'}")
        print(f"App URL: {app_url or 'Using default'}")
    
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

Environment Variables:
  See env_variables.example for all configuration options.
  
  Required for LambdaTest:
    LT_USERNAME      - Your LambdaTest username
    LT_ACCESS_KEY    - Your LambdaTest access key
    
  Optional:
    STATUS_APP_URL   - App URL for testing (default provided)
    DEVICE_NAME      - Target device (default: Galaxy Tab S8)
    PLATFORM_VERSION - Android version (default: 13.0)

Examples:
  python run_tests.py lt          # Run on LambdaTest
  python run_tests.py local       # Run locally
""")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] in ["-h", "--help", "help"]:
        print_usage()
        sys.exit(0)
    
    env = sys.argv[1] if len(sys.argv) > 1 else "lt"
    
    if env not in ["lt", "lambdatest", "local"]:
        print(f"Error: Unknown environment '{env}'")
        print_usage()
        sys.exit(1)
    
    exit_code = run_tests(env)
    sys.exit(exit_code) 