#!/usr/bin/env python3

import xml.etree.ElementTree as ET
import argparse
import sys
from pathlib import Path


def parse_junit_xml(junit_path):
    """Parse JUnit XML file and extract test statistics."""
    try:
        tree = ET.parse(junit_path)
        root = tree.getroot()

        total = int(root.get("tests", 0))
        failures = int(root.get("failures", 0))
        errors = int(root.get("errors", 0))
        skipped = int(root.get("skipped", 0))
        passed = total - failures - errors - skipped
        duration = float(root.get("time", 0))

        return {
            "total": total,
            "passed": passed,
            "failed": failures + errors,
            "skipped": skipped,
            "duration": duration,
        }
    except Exception as e:
        print(f"Error parsing JUnit XML: {e}", file=sys.stderr)
        return None


def generate_summary(results, config):
    """Generate markdown summary from test results and configuration."""
    if not results:
        return "Test results unavailable"

    status_icon = "✅" if results["failed"] == 0 else "❌"

    summary = f"""{status_icon} **Test Results Summary**

**Configuration:**
- APK Source: {config["apk_source_type"]} (`{config["apk_source"]}`)
- Test Selection: {config["test_selection_type"]} (`{config["test_target"]}`)
- Environment: {config["test_environment"]}
- Device: {config["device_name"]}
- Parallel: {config["parallel_execution"]}

**Results:**
- Total: {results["total"]}
- Passed: {results["passed"]}
- Failed: {results["failed"]}
- Skipped: {results["skipped"]}
- Duration: {results["duration"]:.2f}s

**Command:** `pytest {config["pytest_args"]}`"""

    if config.get("build_run_id"):
        summary += f"""

**Source Build:** [Run #{config["build_run_id"]}]({config["repo_url"]}/actions/runs/{config["build_run_id"]})"""

    return summary


def main():
    parser = argparse.ArgumentParser(description="Generate test summary from JUnit XML")
    parser.add_argument("--junit-xml", required=True, help="Path to JUnit XML file")
    parser.add_argument("--output", help="Output markdown file path")
    parser.add_argument("--apk-source-type", help="APK source type")
    parser.add_argument("--apk-source", help="APK source")
    parser.add_argument("--test-selection-type", help="Test selection type")
    parser.add_argument("--test-target", help="Test target")
    parser.add_argument("--test-environment", help="Test environment")
    parser.add_argument("--device-name", help="Device name")
    parser.add_argument("--parallel-execution", help="Parallel execution enabled")
    parser.add_argument("--pytest-args", help="Pytest arguments")
    parser.add_argument("--build-run-id", help="Build run ID")
    parser.add_argument("--repo-url", help="Repository URL")

    args = parser.parse_args()

    results = parse_junit_xml(args.junit_xml)

    config = {
        "apk_source_type": args.apk_source_type or "unknown",
        "apk_source": args.apk_source or "unknown",
        "test_selection_type": args.test_selection_type or "unknown",
        "test_target": args.test_target or "unknown",
        "test_environment": args.test_environment or "unknown",
        "device_name": args.device_name or "unknown",
        "parallel_execution": args.parallel_execution or "false",
        "pytest_args": args.pytest_args or "unknown",
        "build_run_id": args.build_run_id,
        "repo_url": args.repo_url or "https://github.com/status-im/status-app",
    }

    summary = generate_summary(results, config)

    if args.output:
        Path(args.output).write_text(summary)
        print(f"Summary written to {args.output}")
    else:
        print(summary)


if __name__ == "__main__":
    main()
