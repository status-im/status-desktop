import os
from functools import wraps

from core.test_context import TestContext, TestConfiguration
from config.logging_config import get_logger

# Constants
CLOUD_ENVIRONMENTS = ["lt", "lambdatest"]


def lambdatest_reporting(func):

    @wraps(func)
    def wrapper(self, *args, **kwargs):
        try:
            result = func(self, *args, **kwargs)
            if hasattr(self, "report_test_result"):
                self.report_test_result(passed=True)
            return result
        except Exception as e:
            if hasattr(self, "report_test_result"):
                error_msg = str(e)
                self.report_test_result(passed=False, error_message=error_msg)
            raise

    return wrapper


class BaseTest:
    def setup_method(self, method):
        # Initialize logger for test instance
        self.logger = get_logger("tests")

        # Initialize test tracking
        self._result_reported = False

        # Get environment from pytest config or environment variable
        test_env = os.getenv("CURRENT_TEST_ENVIRONMENT", "lambdatest")

        # Try to get environment from pytest if available
        if hasattr(self, "request") and hasattr(self.request, "config"):
            test_env = self.request.config.getoption("--env", default=test_env)

        # Initialize test context (owns session/driver)
        self.ctx = TestContext(environment=test_env).initialize(
            TestConfiguration(environment=test_env)
        )

        self.session_manager = self.ctx._session_manager
        self.driver = self.ctx.driver
        self.test_name = method.__name__

        if not hasattr(self.__class__, "_active_drivers"):
            self.__class__._active_drivers = {}
        self.__class__._active_drivers[id(self)] = self.driver

        try:
            self.session_id = self.driver.session_id
        except Exception:
            self.session_id = "unknown_session"

    def teardown_method(self, method):
        if hasattr(self, "session_manager") and self.driver:
            try:
                # Validate explicit reporting was used for cloud tests
                self._validate_result_reporting()

            except Exception as e:
                logger = get_logger("session")
                logger.error(
                    f"⚠️ Error in teardown: {e}",
                    extra={"error": str(e), "test_name": self.test_name},
                )
            finally:
                # Remove from active drivers dict before cleanup
                if hasattr(self.__class__, "_active_drivers"):
                    self.__class__._active_drivers.pop(id(self), None)

                # Clean up via TestContext to avoid double cleanup
                try:
                    if hasattr(self, "ctx") and self.ctx:
                        self.ctx.cleanup()
                finally:
                    # Fallback to direct cleanup if context not present
                    try:
                        if self.session_manager and self.session_manager.driver:
                            self.session_manager.cleanup_driver()
                    except Exception:
                        pass

    def _validate_result_reporting(self):
        if self.session_manager.environment in CLOUD_ENVIRONMENTS:
            if not self._result_reported:
                error_msg = f"Test '{self.test_name}' failed to report result."
                self.logger.error(f"❌ {error_msg}")
                raise RuntimeError(error_msg)

    def report_test_result(
        self, passed: bool = None, error_message: str = None, status: str = None
    ):
        """
        Report test result to LambdaTest.

        Args:
            passed: Whether the test passed
            error_message: Optional error message for failed tests
            status: Direct status override ("passed", "failed", "error", "unknown", "skipped", "ignored")
        """
        self._result_reported = True

        if self.driver and self.session_manager.environment in CLOUD_ENVIRONMENTS:
            try:
                final_status = status or ("passed" if passed else "failed")
                self._report_to_lambdatest(
                    self.driver, self.test_name, final_status, error_message
                )
                logger = get_logger("session")
                logger.info(
                    f"✅ Reported to LambdaTest: {self.test_name} = {final_status.upper()}"
                )
            except Exception as e:
                logger = get_logger("session")
                logger.error(f"⚠️ Failed to report result to LambdaTest: {e}")

    @classmethod
    def _report_to_lambdatest(cls, driver, test_name, status, error_message=None):
        logger = get_logger("session")

        try:
            driver.execute_script(f"lambda-status={status}")
        except Exception:
            pass
        try:
            driver.execute_script(f"lambda-name={test_name}")
        except Exception:
            pass

        # Optional description (not supported on all drivers)
        is_passed = status == "passed"
        if not is_passed and error_message:
            try:
                clean_error = error_message.replace('"', '\\"').replace("\n", "\\n")[
                    :500
                ]
                driver.execute_script(f"lambda-description=Test failed: {clean_error}")
            except Exception:
                pass

        log_data = {
            "test_name": test_name,
            "lambdatest_status": status,
            "success": is_passed,
        }
        if error_message:
            log_data["error_message"] = error_message[:200]

        if is_passed:
            logger.info(f"✅ LambdaTest Report: {test_name} = PASSED", extra=log_data)
        else:
            logger.warning(
                f"❌ LambdaTest Report: {test_name} = FAILED", extra=log_data
            )
            if error_message:
                logger.error(
                    f"   Error Details: {error_message[:200]}...",
                    extra={"test_name": test_name, "full_error": error_message},
                )

    @classmethod
    def get_active_driver_for_test(cls, test_instance_id):
        if hasattr(cls, "_active_drivers"):
            return cls._active_drivers.get(test_instance_id)
        return None


class BaseAppReadyTest(BaseTest):
    def setup_method(self, method):
        super().setup_method(method)
        try:
            self.ctx.get_home()
        except Exception as e:
            self.logger.error(f"Failed to prepare app in BaseAppReadyTest: {e}")
            raise
