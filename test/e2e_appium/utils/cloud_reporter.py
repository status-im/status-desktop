"""
Cloud provider result reporting utilities.

Used as a final safety net to report pass/fail status for tests that
crash before BaseTest can invoke SessionManager-driven reporting.
"""

from config.logging_config import get_logger


class CloudResultReporter:
    """Handles cloud test result reporting via pytest hooks."""

    @staticmethod
    def report_test_result(item, test_report):
        """
        Attempt to report the test result using the active driver session.

        Only executes if BaseTest did not already report a result, providing a
        safeguard for unexpected failures during setup/teardown.

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

            if not test_instance_id:
                if not test_passed:
                    logger = get_logger("session")
                    logger.warning(
                        "No test instance found for failed test: %s", test_name
                    )
                return

            # Skip if the BaseTest hook already reported a result
            test_instance = item.instance if hasattr(item, "instance") else None
            if (
                test_instance
                and hasattr(test_instance, "_result_reported")
                and test_instance._result_reported
            ):
                logger = get_logger("session")
                logger.debug(
                    f"Skipping pytest hook reporting for {test_name} - already reported by BaseTest"
                )
                return

            driver = BaseTest.get_active_driver_for_test(test_instance_id)
            if driver:
                session_manager = getattr(test_instance, "session_manager", None)
                status = "passed" if test_passed else "failed"
                BaseTest._report_to_cloud(
                    session_manager,
                    driver,
                    test_name,
                    status,
                    error_message,
                )
                logger = get_logger("session")
                logger.info(
                    "Fallback result reporting: %s = %s",
                    test_name,
                    "PASSED" if test_passed else "FAILED",
                )
                return

            if not test_passed:
                logger = get_logger("session")
                logger.warning("No active driver found for failed test: %s", test_name)

        except Exception as e:
            logger = get_logger("session")
            logger.error(
                "Error reporting cloud result: %s",
                e,
                extra={"test_name": test_name, "error": str(e)},
            )
