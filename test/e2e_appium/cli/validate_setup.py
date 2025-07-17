#!/usr/bin/env python3
"""
Validation script to check E2E framework setup
Verifies all components are in place before running workflows
"""

import os
import sys
import json
import requests
from pathlib import Path

def check_file_exists(filepath, description):
    """Check if a file exists and print status"""
    if os.path.exists(filepath):
        print(f"✅ {description}: {filepath}")
        return True
    else:
        print(f"❌ {description}: {filepath} (missing)")
        return False

def check_github_workflows():
    """Check if GitHub workflows are in place"""
    print("\n📋 Checking GitHub Workflows...")
    workflows_dir = ".github/workflows"
    
    required_workflows = [
        ("android-build.yml", "Android Build workflow"),
        ("e2e-appium-android.yml", "E2E Appium Android workflow")
    ]
    
    all_present = True
    for workflow_file, description in required_workflows:
        filepath = os.path.join(workflows_dir, workflow_file)
        if not check_file_exists(filepath, description):
            all_present = False
    
    return all_present

def check_scripts():
    """Check if required scripts are in place"""
    print("\n🐍 Checking Scripts...")
    scripts_dir = "test/e2e_appium/scripts"
    
    required_scripts = [
        ("upload_apk_to_lambdatest.py", "LambdaTest APK upload script"),
        ("artifact_discovery.py", "Artifact discovery script"),
        ("run_tests.py", "Test execution script"),
        ("local_setup.py", "Local setup script")
    ]
    
    all_present = True
    for script_file, description in required_scripts:
        filepath = os.path.join(scripts_dir, script_file)
        if not check_file_exists(filepath, description):
            all_present = False
    
    return all_present

def check_test_framework():
    """Check if test framework components are in place"""
    print("\n🧪 Checking Test Framework...")
    test_dir = "test/e2e_appium"
    
    required_components = [
        ("conftest.py", "Pytest configuration"),
        ("pytest.ini", "Pytest settings"),
        ("requirements.txt", "Python dependencies"),
        ("tests", "Test directory"),
        ("pages", "Page objects directory"),
        ("config", "Configuration directory")
    ]
    
    all_present = True
    for component, description in required_components:
        filepath = os.path.join(test_dir, component)
        if not check_file_exists(filepath, description):
            all_present = False
    
    return all_present

def check_documentation():
    """Check if documentation is in place"""
    print("\n📚 Checking Documentation...")
    docs_dir = "test/e2e_appium"
    
    required_docs = [
        ("README.md", "Main documentation"),
        ("docs/github-actions.md", "GitHub Actions guide"),
        ("docs/setup-secrets.md", "Secrets setup guide"),
        ("env_template", "Environment template")
    ]
    
    all_present = True
    for doc_file, description in required_docs:
        filepath = os.path.join(docs_dir, doc_file)
        if not check_file_exists(filepath, description):
            all_present = False
    
    return all_present

def check_environment():
    """Check environment requirements"""
    print("\n🌍 Checking Environment...")
    
    # Check Python version
    python_version = sys.version_info
    if python_version >= (3, 8):
        print(f"✅ Python version: {python_version.major}.{python_version.minor}.{python_version.micro}")
    else:
        print(f"❌ Python version: {python_version.major}.{python_version.minor}.{python_version.micro} (requires 3.8+)")
        return False
    
    # Check if we're in the right directory
    if os.path.exists("test/e2e_appium"):
        print("✅ Current directory: status-desktop repository")
    else:
        print("❌ Current directory: Not in status-desktop repository")
        return False
    
    return True

def check_secrets_reminder():
    """Remind about GitHub secrets setup"""
    print("\n🔐 GitHub Secrets Reminder...")
    print("⚠️  Remember to set up these GitHub repository secrets:")
    print("   - LT_USERNAME (your LambdaTest username)")
    print("   - LT_ACCESS_KEY (your LambdaTest access key)")
    print("   📖 See docs/setup-secrets.md for detailed instructions")

def main():
    """Main validation function"""
    print("🔍 E2E Framework Setup Validation")
    print("=" * 50)
    
    checks = [
        ("Environment", check_environment),
        ("GitHub Workflows", check_github_workflows),
        ("Scripts", check_scripts),
        ("Test Framework", check_test_framework),
        ("Documentation", check_documentation)
    ]
    
    all_passed = True
    for check_name, check_func in checks:
        if not check_func():
            all_passed = False
    
    check_secrets_reminder()
    
    print("\n" + "=" * 50)
    if all_passed:
        print("🎉 Setup validation PASSED!")
        print("✅ Framework is ready for testing")
        print("\n📋 Next steps:")
        print("   1. Set up GitHub secrets (see docs/setup-secrets.md)")
        print("   2. Build an x86_64 APK using android-build.yml")
        print("   3. Run E2E tests using e2e-appium-android.yml")
    else:
        print("❌ Setup validation FAILED!")
        print("🔧 Please fix the missing components above")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main()) 