#!/usr/bin/env python3
"""
Test Pattern Validation Script

Validates that cloud tests follow proper result reporting patterns:
- Use @lambdatest_reporting decorator, OR
- Call self.report_test_result() explicitly, OR
- Use CloudTestCase.run_test_with_reporting()

Usage:
    python scripts/validate_test_patterns.py
    python scripts/validate_test_patterns.py --fix-warnings
"""

import argparse
import ast
import sys
from pathlib import Path
from typing import List, Dict


class TestPatternValidator:
    def __init__(self):
        self.issues = []
        self.test_files = []

    def validate_project(self, test_dir: Path) -> Dict[str, List[str]]:
        """Validate all test files in the project."""
        results = {"compliant": [], "warnings": [], "errors": []}

        # Find all test files
        for test_file in test_dir.rglob("test_*.py"):
            if test_file.name == "__init__.py":
                continue

            validation_result = self.validate_file(test_file)

            if validation_result["status"] == "compliant":
                results["compliant"].append(str(test_file))
            elif validation_result["status"] == "warning":
                results["warnings"].append(
                    f"{test_file}: {validation_result['message']}"
                )
            else:
                results["errors"].append(f"{test_file}: {validation_result['message']}")

        return results

    def validate_file(self, file_path: Path) -> Dict[str, str]:
        """Validate a single test file."""
        try:
            with open(file_path, "r") as f:
                content = f.read()

            tree = ast.parse(content)

            # Find test classes
            test_classes = [
                node
                for node in ast.walk(tree)
                if isinstance(node, ast.ClassDef) and "Test" in node.name
            ]

            if not test_classes:
                return {"status": "compliant", "message": "No test classes found"}

            # Check for cloud test patterns
            for test_class in test_classes:
                result = self._validate_test_class(test_class, content)
                if result["status"] != "compliant":
                    return result

            return {
                "status": "compliant",
                "message": "All tests follow proper patterns",
            }

        except Exception as e:
            return {"status": "error", "message": f"Failed to parse file: {e}"}

    def _validate_test_class(
        self, test_class: ast.ClassDef, content: str
    ) -> Dict[str, str]:
        """Validate patterns in a test class."""
        # Check if it inherits from BaseTest (likely cloud test)
        is_cloud_test = any(
            isinstance(base, ast.Name) and base.id == "BaseTest"
            for base in test_class.bases
        )

        if not is_cloud_test:
            return {"status": "compliant", "message": "Not a cloud test class"}

        # Find test methods
        test_methods = [
            node
            for node in test_class.body
            if isinstance(node, ast.FunctionDef) and node.name.startswith("test_")
        ]

        for test_method in test_methods:
            result = self._validate_test_method(test_method, content)
            if result["status"] != "compliant":
                return result

        return {
            "status": "compliant",
            "message": "All test methods properly configured",
        }

    def _validate_test_method(
        self, test_method: ast.FunctionDef, content: str
    ) -> Dict[str, str]:
        """Validate a single test method."""
        method_name = test_method.name

        # Check for @lambdatest_reporting decorator
        has_decorator = any(
            (isinstance(dec, ast.Name) and dec.id == "lambdatest_reporting")
            or (isinstance(dec, ast.Attribute) and dec.attr == "lambdatest_reporting")
            for dec in test_method.decorator_list
        )

        if has_decorator:
            return {
                "status": "compliant",
                "message": f"{method_name} uses decorator pattern",
            }

        # Check for explicit report_test_result calls
        method_source = ast.get_source_segment(content, test_method) or ""
        has_explicit_reporting = "report_test_result" in method_source

        if has_explicit_reporting:
            return {
                "status": "compliant",
                "message": f"{method_name} uses explicit reporting",
            }

        # Check for run_test_with_reporting usage
        has_template_pattern = "run_test_with_reporting" in method_source

        if has_template_pattern:
            return {
                "status": "compliant",
                "message": f"{method_name} uses template pattern",
            }

        # No proper pattern found
        return {
            "status": "warning",
            "message": f"{method_name} missing result reporting pattern. "
            f"Add @lambdatest_reporting decorator or call self.report_test_result()",
        }


def main():
    parser = argparse.ArgumentParser(description="Validate test patterns")
    parser.add_argument(
        "--test-dir",
        default="test/e2e_appium/tests",
        help="Directory to scan for test files",
    )
    parser.add_argument(
        "--fix-warnings",
        action="store_true",
        help="Show suggestions for fixing warnings",
    )

    args = parser.parse_args()

    test_dir = Path(args.test_dir)
    if not test_dir.exists():
        print(f"❌ Test directory not found: {test_dir}")
        sys.exit(1)

    validator = TestPatternValidator()
    results = validator.validate_project(test_dir)

    print("=" * 60)
    print("🔍 TEST PATTERN VALIDATION RESULTS")
    print("=" * 60)

    if results["compliant"]:
        print(f"✅ Compliant files ({len(results['compliant'])}):")
        for file in results["compliant"]:
            print(f"  {file}")
        print()

    if results["warnings"]:
        print(f"⚠️  Warnings ({len(results['warnings'])}):")
        for warning in results["warnings"]:
            print(f"  {warning}")
        print()

        if args.fix_warnings:
            print("💡 To fix warnings:")
            print("  1. Add @lambdatest_reporting decorator to test methods")
            print("  2. Or call self.report_test_result(passed=True/False) explicitly")
            print("  3. Or use CloudTestCase.run_test_with_reporting() pattern")
            print()

    if results["errors"]:
        print(f"❌ Errors ({len(results['errors'])}):")
        for error in results["errors"]:
            print(f"  {error}")
        print()

    # Summary
    total = (
        len(results["compliant"]) + len(results["warnings"]) + len(results["errors"])
    )
    if total > 0:
        compliance_rate = len(results["compliant"]) / total * 100
        print(
            f"📊 Compliance Rate: {compliance_rate:.1f}% ({len(results['compliant'])}/{total})"
        )

    # Exit with error code if issues found
    if results["warnings"] or results["errors"]:
        print("\n💡 Run with --fix-warnings for suggestions")
        sys.exit(1)
    else:
        print("🎉 All tests follow proper patterns!")
        sys.exit(0)


if __name__ == "__main__":
    main()
