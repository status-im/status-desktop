"""
LambdaTest result reporting utilities.

Dedicated module for handling LambdaTest test result reporting
to keep conftest.py focused on pytest configuration.
"""

from config.logging_config import get_logger


class LambdaTestReporter:
    """Handles LambdaTest test result reporting."""

    @staticmethod
    def report_test_result(item, test_report):
        """
        Emergency backup LambdaTest result reporting via pytest hooks.

        Only reports if BaseTest teardown didn't handle it (e.g., test crashed).
        Prevents double reporting by checking if reporting already occurred.

        Args:
            item: pytest test item
            test_report: pytest test report
        """
        test_name = item.name
        test_passed = test_report.passed
        error_message = None

        if test_report.failed and hasattr(test_report, "longrepr"):
            error_message = str(test_report.longrepr)

        try:
            from ..tests.base_test import BaseTest

            test_instance_id = id(item.instance) if hasattr(item, "instance") else None

            if test_instance_id:
                # Check if BaseTest already handled reporting
                test_instance = item.instance if hasattr(item, "instance") else None
                if (
                    test_instance
                    and hasattr(test_instance, "_result_reported")
                    and test_instance._result_reported
                ):
                    # BaseTest already handled reporting, skip
                    logger = get_logger("session")
                    logger.debug(
                        f"Skipping pytest hook reporting for {test_name} - already reported by BaseTest"
                    )
                    return

                driver = BaseTest.get_active_driver_for_test(test_instance_id)
                if driver:
                    BaseTest._report_to_lambdatest(
                        driver, test_name, test_passed, error_message
                    )
                    logger = get_logger("session")
                    logger.info(
                        f"📋 Fallback result reporting: {test_name} = {'PASSED' if test_passed else 'FAILED'}"
                    )
                else:
                    # Only warn for failed tests - passed tests may have already cleaned up
                    if not test_passed:
                        logger = get_logger("session")
                        logger.warning(
                            f"⚠️ No active driver found for failed test: {test_name}"
                        )
            else:
                # Only warn for failed tests - passed tests may have already cleaned up
                if not test_passed:
                    logger = get_logger("session")
                    logger.warning(f"⚠️ No test instance found for failed test: {test_name}")

        except Exception as e:
            logger = get_logger("session")
            logger.error(
                f"⚠️ Error reporting to LambdaTest: {e}",
                extra={"test_name": test_name, "error": str(e)},
            )
