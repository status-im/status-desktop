import os
import json
from functools import wraps

from core.config_manager import EnvironmentSwitcher
from core.test_context import TestContext, TestConfiguration
from config.logging_config import get_logger

# Known cloud providers handled via the provider abstraction
CLOUD_PROVIDERS = {"browserstack"}


def cloud_reporting(func):
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


lambdatest_reporting = cloud_reporting  # Backward-compatible alias for older tests


class BaseTest:
    def setup_method(self, method):
        # Initialize logger for test instance
        self.logger = get_logger("tests")

        # Initialize test tracking
        self._result_reported = False

        # Get environment from pytest config or environment variable
        switcher = EnvironmentSwitcher()
        detected_env = os.getenv("CURRENT_TEST_ENVIRONMENT") or os.getenv(
            "TEST_ENVIRONMENT"
        )
        if not detected_env:
            detected_env = switcher.auto_detect_environment()

        # Try to get environment from pytest if available
        test_env = detected_env
        if hasattr(self, "request") and hasattr(self.request, "config"):
            test_env = self.request.config.getoption("--env", default=detected_env)

        os.environ["CURRENT_TEST_ENVIRONMENT"] = test_env

        self.test_name = method.__name__

        # Initialize test context (owns session/driver)
        self.ctx = TestContext(environment=test_env).initialize(
            TestConfiguration(environment=test_env),
            test_name=self.test_name,
        )

        self.session_manager = self.ctx._session_manager
        self.provider_name = (
            self.session_manager.provider.name
            if hasattr(self.session_manager, "provider")
            else "local"
        )
        self.driver = self.ctx.driver

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
                    "Error in teardown: %s",
                    e,
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
        provider = getattr(self, "provider_name", "local").lower()
        if provider in CLOUD_PROVIDERS:
            if not self._result_reported:
                error_msg = f"Test '{self.test_name}' failed to report result."
                self.logger.error(error_msg)
                raise RuntimeError(error_msg)

    def report_test_result(
        self, passed: bool = None, error_message: str = None, status: str = None
    ):
        """
        Report test result to the active cloud provider.

        Args:
            passed: Whether the test passed
            error_message: Optional error message for failed tests
            status: Direct status override ("passed", "failed", "error", "unknown", "skipped", "ignored")
        """
        self._result_reported = True

        provider = getattr(self, "provider_name", "local").lower()
        if self.driver and provider in CLOUD_PROVIDERS:
            try:
                final_status = status or ("passed" if passed else "failed")
                self._report_to_cloud(
                    self.session_manager,
                    self.driver,
                    self.test_name,
                    final_status,
                    error_message,
                )
                logger = get_logger("session")
                logger.info(
                    "Reported to %s: %s = %s",
                    self.provider_name,
                    self.test_name,
                    final_status.upper(),
                )
            except Exception as e:
                logger = get_logger("session")
                logger.error("Failed to report result: %s", e)

    @classmethod
    def _report_to_cloud(
        cls, session_manager, driver, test_name, status, error_message=None
    ):
        reason = error_message[:250] if error_message else None

        try:
            if session_manager:
                session_manager.metadata.test_name = test_name
                session_manager.report_result(status, reason)
                return
        except Exception:
            pass

        # Fallback to BrowserStack executor if direct reporting failed
        if driver:
            try:
                payload = {
                    "action": "setSessionStatus",
                    "arguments": {"status": status, "reason": reason or ""},
                }
                driver.execute_script(
                    "browserstack_executor: {payload}".format(
                        payload=json.dumps(payload)
                    )
                )
                driver.execute_script(
                    "browserstack_executor: {payload}".format(
                        payload=json.dumps(
                            {
                                "action": "setSessionName",
                                "arguments": {"name": test_name},
                            }
                        )
                    )
                )
            except Exception:
                pass

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
