#!/usr/bin/env python3

import argparse
import subprocess
import sys
import os
from datetime import datetime
from pathlib import Path
from config import get_config

project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))




def run_command(cmd, description):
    print(f"\n🚀 {description}")
    print(f"Command: {' '.join(cmd)}")
    print("-" * 60)

    try:
        _ = subprocess.run(cmd, check=True, capture_output=False)
        print(f"✅ {description} completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed with exit code {e.returncode}")
        return False


def validate_environment():
    print("\n🔍 Validating environment configuration")

    try:
        config = get_config()
        print("✅ Configuration loaded successfully")
        print(
            f"Device: {config.device_name} ({config.platform_name} {config.platform_version})"
        )
        print(f"LambdaTest User: {config.lt_username}")
        print(f"App URL: {config.status_app_url}")
        return True
    except Exception as e:
        print(f"❌ Configuration validation failed: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Test Runner with XML/HTML Reports")
    parser.add_argument(
        "--category",
        "-c",
        choices=["smoke", "tablet", "critical", "all"],
        default="smoke",
        help="Test category to run (default: smoke)",
    )
    parser.add_argument(
        "--parallel",
        "-n",
        type=int,
        default=None,
        help="Number of parallel processes (default: from config)",
    )
    parser.add_argument(
        "--env",
        "-e",
        choices=["local", "lambdatest", "template", "lt"],
        default=None,
        help="Environment to run tests in (default: auto-detect)",
    )
    parser.add_argument("--config", "-f", help="Custom configuration file path")
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    parser.add_argument(
        "--retry", "-r", action="store_true", help="Enable retry for flaky tests"
    )
    parser.add_argument(
        "--test",
        "-t",
        help="Run specific test (e.g., test_click_create_profile_button)",
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Only validate configuration, don't run tests",
    )
    parser.add_argument(
        "--no-xml", action="store_true", help="Disable XML report generation"
    )
    parser.add_argument(
        "--no-html", action="store_true", help="Disable HTML report generation"
    )
    parser.add_argument(
        "--reports-dir", help="Custom reports directory (overrides config)"
    )

    args = parser.parse_args()

    if args.env == "lt":
        args.env = "lambdatest"

    if args.env:
        os.environ["TEST_ENVIRONMENT"] = args.env

    try:
        config = get_config()

        if args.reports_dir:
            config.reports_dir = args.reports_dir

        if args.no_xml:
            config.enable_xml_report = False
        if args.no_html:
            config.enable_html_report = False

        if not validate_environment():
            print("\n💥 Environment validation failed!")
            return 1
        if args.validate_only:
            print("\n✅ Configuration validation completed successfully!")
            return 0

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        reports_dir = Path(config.reports_dir)
        reports_dir.mkdir(exist_ok=True)

        cmd = ["python", "-m", "pytest"]
        cmd.extend(["--env", args.env or "lambdatest"])

        if args.category != "all":
            cmd.extend(["-m", args.category])

        parallel_processes = args.parallel or 1
        if parallel_processes > 1:
            cmd.extend(["-n", str(parallel_processes)])

        if args.retry:
            cmd.extend(["--reruns", "2", "--reruns-delay", "1"])

        if args.verbose:
            cmd.append("-v")

        if args.test:
            cmd.extend(["-k", args.test])

        xml_file = None
        if config.enable_xml_report:
            xml_file = reports_dir / f"pytest_results_{timestamp}.xml"
            cmd.extend(["--junitxml", str(xml_file)])

        html_file = None
        if config.enable_html_report:
            html_file = reports_dir / f"pytest_report_{timestamp}.html"
            cmd.extend(["--html", str(html_file), "--self-contained-html"])

        if "test/e2e_appium/tests" in cmd:
            cmd.remove("test/e2e_appium/tests")
        cmd.append("test/e2e_appium/tests")

        print("=" * 60)
        print("🎯 E2E TEST RUNNER")
        print("=" * 60)
        print(f"Environment: {args.env or 'lambdatest'}")
        print(f"Category: {args.category}")
        print(f"Parallel: {parallel_processes} processes")
        print(f"Retry: {'Enabled' if args.retry else 'Disabled'}")
        print(f"Verbose: {'Yes' if args.verbose else 'No'}")
        if args.test:
            print(f"Specific Test: {args.test}")
        print("Reports:")
        if config.enable_xml_report:
            print(f"  📄 XML (JUnit): {xml_file}")
        if config.enable_html_report:
            print(f"  🌐 HTML: {html_file}")
        print("=" * 60)

        success = run_command(cmd, f"Running {args.category} tests")
        if success:
            print("\n🎉 All tests completed successfully!")
            print("📊 Generated Reports:")
            if config.enable_xml_report and xml_file and xml_file.exists():
                print(f"  ✅ XML Report: {xml_file}")
            if config.enable_html_report and html_file and html_file.exists():
                print(f"  ✅ HTML Report: {html_file}")
            return 0
        else:
            print("\n💥 Some tests failed!")
            print("📊 Reports available for analysis:")
            if config.enable_xml_report and xml_file and xml_file.exists():
                print(f"  📄 XML Report: {xml_file}")
            if config.enable_html_report and html_file and html_file.exists():
                print(f"  🌐 HTML Report: {html_file}")
            return 1
    except ValueError as e:
        print(f"\n💥 Configuration error: {e}")
        return 1
    except Exception as e:
        print(f"\n💥 Unexpected error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
