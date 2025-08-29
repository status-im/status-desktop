import time
import os
import logging
from datetime import datetime
from typing import Optional, List

from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from config import log_element_action
from core import EnvironmentSwitcher


class BasePage:
    def __init__(self, driver):
        self.driver = driver
        env_name = os.getenv("CURRENT_TEST_ENVIRONMENT", "lambdatest")

        try:
            switcher = EnvironmentSwitcher()
            env_config = switcher.switch_to(env_name)
            self.timeouts = env_config.timeouts
            element_wait_timeout = self.timeouts["element_wait"]
        except Exception:
            # Use default timeouts if config unavailable
            self.timeouts = {
                "element_wait": 30,
                "element_click": 5,
                "element_find": 10,
                "default": 30,
            }
            element_wait_timeout = self.timeouts["element_wait"]

        self.wait = WebDriverWait(driver, element_wait_timeout)

        self.logger = logging.getLogger(
            self.__class__.__module__ + "." + self.__class__.__name__
        )

    def _create_wait(self, timeout: Optional[int], config_key: str) -> WebDriverWait:
        """Create WebDriverWait with timeout from parameter or YAML config."""
        effective_timeout = timeout or self.timeouts.get(config_key, 30)
        return WebDriverWait(self.driver, effective_timeout)

    def is_screen_displayed(self, timeout: Optional[int] = None):
        return self.is_element_visible(self.IDENTITY_LOCATOR, timeout=timeout)

    def find_element(self, locator, timeout: Optional[int] = None):
        """Find element with configurable timeout.

        Args:
            locator: Element locator tuple
            timeout: Override timeout (uses YAML element_wait config if None)

        Returns:
            WebElement instance

        Raises:
            TimeoutException: If element not found within timeout
        """
        start_time = datetime.now()
        locator_str = f"{locator[0]}: {locator[1]}"

        try:
            wait = self._create_wait(timeout, "element_wait")
            element = wait.until(EC.presence_of_element_located(locator))
            duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
            log_element_action("find_element", locator_str, True, duration_ms)
            return element
        except Exception:
            duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
            log_element_action("find_element", locator_str, False, duration_ms)
            raise

    def click_element(self, locator, timeout: Optional[int] = None):
        """Click element with configurable timeout.

        Args:
            locator: Element locator tuple
            timeout: Override timeout (uses YAML element_click config if None)

        Returns:
            bool: True if click successful, False otherwise
        """
        start_time = datetime.now()
        locator_str = f"{locator[0]}: {locator[1]}"

        try:
            wait = self._create_wait(timeout, "element_click")
            element = wait.until(EC.element_to_be_clickable(locator))
            element.click()
            duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
            log_element_action("click_element", locator_str, True, duration_ms)
            return True
        except Exception:
            duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
            log_element_action("click_element", locator_str, False, duration_ms)
            return False

    def is_element_visible(
        self,
        locator,
        fallback_locators: Optional[List[tuple]] = None,
        timeout: Optional[int] = None,
    ) -> bool:
        """Check visibility for a locator, optionally trying fallbacks in order."""
        locators_to_try: List[tuple] = [locator]
        if fallback_locators:
            locators_to_try.extend(fallback_locators)

        if timeout is None:
            timeout = self.timeouts.get("element_find", 15)

        for loc in locators_to_try:
            try:
                wait = self._create_wait(timeout, "element_wait")
                wait.until(EC.visibility_of_element_located(loc))
                return True
            except Exception:
                continue
        return False

    def safe_click(
        self,
        locator,
        timeout: Optional[int] = None,
        fallback_locators: Optional[List[tuple]] = None,
        max_attempts: int = 3,
    ) -> bool:
        """Click an element with retries and optional fallback locators.

        Raises:
            RuntimeError: if click fails after retries and fallbacks.
        """
        locators_to_try: List[tuple] = [locator]
        if fallback_locators:
            locators_to_try.extend(fallback_locators)

        for loc in locators_to_try:
            attempts = 0
            while attempts < max_attempts:
                attempts += 1
                try:
                    wait = self._create_wait(timeout, "element_click")
                    element = wait.until(EC.element_to_be_clickable(loc))
                    element.click()
                    log_element_action("click_element", f"{loc[0]}: {loc[1]}", True, 0)
                    return True
                except Exception as e:
                    self.logger.debug(f"Click attempt {attempts} failed for {loc}: {e}")
                    if attempts >= max_attempts:
                        break
        message = (
            f"Failed to click element after trying {len(locators_to_try)} locator(s) "
            f"with {max_attempts} attempt(s) each. Last locator: {locators_to_try[-1]}"
        )
        self.logger.error(message)
        raise RuntimeError(message)

    def safe_input(self, locator, text: str, timeout: Optional[int] = None) -> bool:
        """Qt-safe input by delegating to qt_safe_input with retries."""
        try:
            return self.qt_safe_input(locator, text, timeout)
        except Exception as e:
            self.logger.error(
                f"Failed to input text '{text}' to element {locator}: {e}"
            )
            return False

    def wait_for_element(self, locator, timeout: Optional[int] = None):
        """Wait for element presence with configurable timeout.

        Args:
            locator: Element locator tuple
            timeout: Override timeout (uses YAML element_wait config if None)
        """
        wait = self._create_wait(timeout, "element_wait")

        try:
            return wait.until(EC.presence_of_element_located(locator))
        except Exception as e:
            self.logger.error(f"Element not found within timeout: {locator}: {e}")
            return None

    def find_element_safe(self, locator, timeout: Optional[int] = None):
        """Find element and return None instead of raising on failure."""
        try:
            wait = self._create_wait(timeout, "element_find")
            return wait.until(EC.presence_of_element_located(locator))
        except Exception:
            return None

    def hide_keyboard(self) -> bool:
        """Hide the virtual keyboard using multiple strategies"""
        try:
            # Strategy 1: Use Appium's built-in hide_keyboard method
            try:
                self.driver.hide_keyboard()
                self.logger.info("Keyboard hidden successfully using hide_keyboard()")
                return True
            except Exception as e:
                self.logger.debug(f"hide_keyboard() failed: {e}")

            # Strategy 2: Press back button (Android)
            try:
                self.driver.back()
                self.logger.info("Keyboard hidden using back button")
                return True
            except Exception as e:
                self.logger.debug(f"Back button failed: {e}")

            # Strategy 3: Swipe down gesture
            try:
                size = self.driver.get_window_size()
                # Swipe from middle-top to middle-bottom
                start_x = size["width"] // 2
                start_y = size["height"] // 3
                end_y = size["height"] * 2 // 3

                self.driver.swipe(start_x, start_y, start_x, end_y, 500)
                self.logger.info("Keyboard hidden using swipe gesture")
                return True
            except Exception as e:
                self.logger.debug(f"Swipe gesture failed: {e}")

            self.logger.warning("All keyboard hiding strategies failed")
            return False

        except Exception as e:
            self.logger.error(f"Error hiding keyboard: {e}")
            return False

    def ensure_element_visible(self, locator, timeout=10) -> bool:
        """Ensure element is visible, hide keyboard if it's blocking"""
        try:
            # First check if element is already visible
            if self.is_element_visible(locator, timeout=2):
                return True

            # Try hiding keyboard and check again
            self.logger.info("Element not visible, attempting to hide keyboard")
            if self.hide_keyboard():
                time.sleep(1)  # Wait for keyboard animation
                return self.is_element_visible(locator, timeout=timeout)

            return False

        except Exception as e:
            self.logger.error(f"Error ensuring element visibility: {e}")
            return False

    def qt_safe_input(
        self, locator, text: str, timeout: Optional[int] = None, max_retries: int = 3
    ) -> bool:
        """Qt/QML-safe text input with proper waiting and retry logic"""

        for attempt in range(max_retries):
            try:
                # Wait for element to be clickable (present and enabled)
                wait = self._create_wait(timeout, "element_click")
                element = wait.until(EC.element_to_be_clickable(locator))

                # Click to focus
                element.click()

                # Wait for Qt field to become ready (with timeout)
                self._wait_for_qt_field_ready(element)

                # Clear and input using ActionChains
                element.clear()

                # Brief wait for clear to complete (Qt/QML requirement)
                self._wait_for_clear_completion(element)

                actions = ActionChains(self.driver)
                actions.send_keys(text).perform()

                # Verify input was successful
                if self._verify_input_success(element, text):
                    self.logger.info(f"Qt input successful (attempt {attempt + 1})")
                    return True

            except Exception as e:
                self.logger.warning(f"Qt input attempt {attempt + 1} failed: {e}")
                if attempt < max_retries - 1:
                    time.sleep(1)  # Brief pause before retry

        self.logger.error(f"Qt input failed after {max_retries} attempts")
        return False

    def _wait_for_qt_field_ready(self, element, timeout: int = 5) -> bool:
        """Wait for Qt field to be ready for input using polling"""

        def field_is_ready(driver):
            try:
                # Check if element is enabled and displayed
                return element.is_enabled() and element.is_displayed()
            except Exception:
                return False

        try:
            wait = WebDriverWait(
                self.driver, timeout
            )  # Keep direct usage for custom condition
            wait.until(field_is_ready)
            return True
        except Exception:
            self.logger.warning("Qt field readiness timeout")
            return False

    def _verify_input_success(self, element, expected_text: str) -> bool:
        """Verify that text input was successful"""
        try:
            # Check if this is a password field by resource-id or content-desc
            resource_id = element.get_attribute("resource-id") or ""
            content_desc = element.get_attribute("content-desc") or ""

            is_password = (
                "password" in resource_id.lower()
                or content_desc.lower() == "type password"
            )

            if is_password:
                # Password fields hide content for security - assume success if no exception
                self.logger.debug("Password field detected - assuming input success")
                return True

            # For non-password fields, verify text content
            actual_text = element.get_attribute(
                "text"
            )  # Android UIAutomator2 uses 'text' not 'value'
            if actual_text is None:
                # Secure input or unreadable field - assume success
                return True
            return len(actual_text) > 0
        except Exception:
            # If we can't verify, assume success if we got this far
            return True

    def _wait_for_clear_completion(self, element, max_wait: float = 1.0) -> bool:
        """Wait for element clear operation to complete"""

        start_time = time.time()
        while time.time() - start_time < max_wait:
            try:
                # For password fields, we can't check text, so use a minimal delay
                # This is still better than a hardcoded sleep
                if hasattr(element, "get_attribute"):
                    text = element.get_attribute(
                        "text"
                    )  # Android UIAutomator2 uses 'text' not 'value'
                    if text == "" or text is None:
                        return True

                # Small incremental wait
                time.sleep(0.1)
            except Exception:
                # If we can't check, assume it's ready after minimal wait
                time.sleep(0.2)
                return True

        return True  # Always return True to not block the flow

    def long_press_element(self, element, duration: int = 800) -> bool:
        """Perform long-press gesture on element to trigger context menu.

        Args:
            element: WebElement to long-press
            duration: Long-press duration in milliseconds

        Returns:
            bool: True if long-press successful, False otherwise
        """
        try:
            self.driver.execute_script(
                "mobile: longClickGesture",
                {"elementId": element.id, "duration": duration},
            )
            self.logger.debug(f"Long-press performed (duration: {duration}ms)")
            return True
        except Exception as e:
            self.logger.debug(f"Long-press gesture failed: {e}")
            return False

    def tap_coordinate_relative(self, element, x_offset: int, y_offset: int) -> bool:
        """Tap at coordinates relative to element position.

        Args:
            element: Reference element for coordinate calculation
            x_offset: X offset from element's left edge (can be negative)
            y_offset: Y offset from element's top edge (can be negative)

        Returns:
            bool: True if tap successful, False otherwise
        """
        try:
            rect = element.rect
            x = int(rect["x"] + x_offset)
            y = int(max(0, rect["y"] + y_offset))

            self.driver.execute_script("mobile: clickGesture", {"x": x, "y": y})
            self.logger.debug(f"Coordinate tap at ({x}, {y}) relative to element")
            return True
        except Exception as e:
            self.logger.debug(f"Coordinate tap failed: {e}")
            return False
