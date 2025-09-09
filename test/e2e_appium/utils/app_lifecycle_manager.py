"""
App lifecycle management utilities.

Handles app restart, termination, and data clearing operations.
Extracted from BasePage to follow Single Responsibility Principle.
"""

import os
import subprocess

from config.logging_config import get_logger


class AppLifecycleManager:

    def __init__(self, driver):
        self.driver = driver
        self.logger = get_logger("app_lifecycle")

    def restart_app(self, app_package: str = "im.status.tablet") -> bool:
        """
        Restart the app within the current session.

        Useful for testing session persistence, returning user scenarios,
        or app state recovery after restart.

        Args:
            app_package: App package name (defaults to Status tablet)

        Returns:
            bool: True if restart was successful
        """
        try:
            self.logger.info(f"🔄 Restarting app: {app_package}")

            self.driver.terminate_app(app_package)
            self.logger.debug("✓ App terminated")

            self.driver.activate_app(app_package)
            self.logger.debug("✓ App reactivated")

            self.logger.info("✅ App restart completed successfully")
            return True

        except Exception as e:
            self.logger.error(f"❌ App restart failed: {e}")
            return False

    def restart_app_with_data_cleared(
        self, app_package: str = "im.status.tablet"
    ) -> bool:
        """
        Restart the app with all app data cleared (fresh app state).

        This completely removes app data and cache, then relaunches the app.
        Useful for testing fresh onboarding flows.

        Args:
            app_package: The app package identifier

        Returns:
            bool: True if restart successful, False otherwise
        """
        try:
            self.logger.info("🔄 Restarting app with data cleared...")

            # Cloud environments typically disallow ADB; skip and advise new session
            env_name = os.getenv("CURRENT_TEST_ENVIRONMENT", "lambdatest").lower()
            if env_name in ("lt", "lambdatest"):
                self.logger.warning(
                    "Cloud run detected; skipping ADB data clear. Use a new session with noReset=false/fullReset."
                )
                return False

            self.driver.terminate_app(app_package)
            self.logger.debug("✓ App terminated")

            clear_data_result = subprocess.run(
                ["adb", "shell", "pm", "clear", app_package],
                capture_output=True,
                text=True,
            )

            if clear_data_result.returncode != 0:
                self.logger.warning(
                    f"⚠️ Clear app data failed: {clear_data_result.stderr}"
                )
            else:
                self.logger.debug("✓ App data cleared")

            self.driver.activate_app(app_package)
            self.logger.debug("✓ App reactivated with fresh state")

            # Optional activation tap
            try:
                from utils.gestures import Gestures

                gestures = Gestures(self.driver)
                gestures.tap(500, 300)
            except Exception:
                pass

            self.logger.info("✅ App restart with cleared data completed successfully")
            return True

        except Exception as e:
            self.logger.error(f"❌ App restart with data cleared failed: {e}")
            return False

    def terminate_app(self, app_package: str = "im.status.tablet") -> bool:
        """Terminate the specified app."""
        try:
            self.driver.terminate_app(app_package)
            self.logger.debug(f"✓ App terminated: {app_package}")
            return True
        except Exception as e:
            self.logger.error(f"❌ Failed to terminate app: {e}")
            return False

    def activate_app(self, app_package: str = "im.status.tablet") -> bool:
        """Activate the specified app."""
        try:
            self.driver.activate_app(app_package)
            self.logger.debug(f"✓ App activated: {app_package}")
            return True
        except Exception as e:
            self.logger.error(f"❌ Failed to activate app: {e}")
            return False
