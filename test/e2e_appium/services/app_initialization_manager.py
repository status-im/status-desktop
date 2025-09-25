import time

from config.logging_config import get_logger
from utils.gestures import Gestures


class AppInitializationManager:

    def __init__(self, driver):
        self.driver = driver
        self.gestures = Gestures(driver)
        self.logger = get_logger("app_initialization")

    def perform_initial_activation(
        self, timeout: float = 15.0, interval: float = 2.0
    ) -> bool:
        """Perform initial app activation until UI appears or timeout is reached.

        Raises:
            RuntimeError: If the UI never surfaces before the timeout expires.
        """
        self.logger.debug("🚀 Starting app initialization sequence")

        self._wait_for_session_ready()

        deadline = time.time() + timeout

        while time.time() < deadline:
            if not self._should_perform_activation_tap():
                self.logger.debug("↷ UI already present - skipping activation")
                return True

            if self._perform_activation_tap():
                if self._wait_for_ui_response(timeout=interval):
                    self.logger.info("✓ App UI surfaced after activation")
                    return True
                
        self.logger.error("⚠ App activation timeout - UI never surfaced")
        raise RuntimeError("App activation timed out before UI became available")

    def _wait_for_session_ready(
        self, timeout: float = 2.0, poll_interval: float = 0.2
    ) -> None:
        deadline = time.time() + timeout
        while time.time() < deadline:
            try:
                _ = self.driver.get_window_size()
                try:
                    _ = self.driver.page_source
                except Exception:
                    pass
                break
            except Exception:
                time.sleep(poll_interval)

    def _should_perform_activation_tap(self) -> bool:
        ui_checks = [
            self._is_home_container_visible,
            self._is_welcome_back_visible,
            self._is_welcome_visible,
            self._is_ui_content_present,
        ]

        for check in ui_checks:
            try:
                if check():
                    return False
            except Exception:
                continue

        return True

    def _is_home_container_visible(self) -> bool:
        try:
            from pages.onboarding import HomePage

            main_app = HomePage(self.driver)
            return main_app.is_element_visible(
                main_app.locators.HOME_CONTAINER, timeout=1
            )
        except Exception:
            return False

    def _is_welcome_back_visible(self) -> bool:
        try:
            from pages.onboarding import WelcomeBackPage

            welcome_back = WelcomeBackPage(self.driver)
            return welcome_back.is_welcome_back_screen_displayed(timeout=1)
        except Exception:
            return False

    def _is_welcome_visible(self) -> bool:
        try:
            from pages.onboarding import WelcomePage

            welcome = WelcomePage(self.driver)
            return welcome.is_screen_displayed(timeout=1)
        except Exception:
            return False

    def _is_ui_content_present(self) -> bool:
        try:
            src = self.driver.page_source
            ui_markers = [
                "startupOnboardingLayout",
                "homeContainer.homeDock",
                "Welcome to Status",
            ]
            return any(marker in src for marker in ui_markers)
        except Exception:
            return False

    def _perform_activation_tap(self) -> bool:
        try:
            coords = self._get_safe_tap_coordinates()
            if self.gestures.double_tap(coords[0], coords[1]):
                self.logger.debug("✓ Activation double-tap performed")
                return True
            elif self.gestures.tap(coords[0], coords[1]):
                self.logger.debug("✓ Activation tap performed")
                return True
            else:
                self.logger.debug("⚠ Activation tap failed")
                return False
        except Exception as e:
            self.logger.debug(f"⚠ Activation tap error: {e}")
            return False

    def _get_safe_tap_coordinates(self) -> tuple:
        try:
            size = self.driver.get_window_size()
            return (size["width"] // 2, size["height"] // 2)
        except Exception:
            self.logger.warning("⚠ Could not get window size; using fallback coords")
            return (500, 300)

    def _wait_for_ui_response(
        self, timeout: int = 5, poll_interval: float = 0.5
    ) -> bool:
        deadline = time.time() + timeout

        while time.time() < deadline:
            if not self._should_perform_activation_tap():
                return True
            time.sleep(poll_interval)

        return False
