from config.logging_config import get_logger
from utils.gestures import Gestures


class KeyboardManager:

    def __init__(self, driver):
        self.driver = driver
        self.gestures = Gestures(driver)
        self.logger = get_logger("keyboard_manager")

    def hide_keyboard(self) -> bool:
        try:
            try:
                self.driver.hide_keyboard()
                self.logger.info("Keyboard hidden successfully using hide_keyboard()")
                return True
            except Exception as e:
                self.logger.debug(f"hide_keyboard() failed: {e}")

            try:
                self.driver.back()
                self.logger.info("Keyboard hidden using back button")
                return True
            except Exception as e:
                self.logger.debug(f"Back button failed: {e}")

            try:
                size = self.driver.get_window_size()
                center_x = size["width"] // 2
                top = size["height"] // 3
                height = size["height"] // 3

                self.gestures.swipe_down(max(0, center_x - 10), top, 20, height, 0.8)
                self.logger.info("Keyboard hidden using swipe gesture")
                return True
            except Exception as e:
                self.logger.debug(f"Swipe gesture failed: {e}")

            self.logger.warning("All keyboard hiding strategies failed")
            return False

        except Exception as e:
            self.logger.error(f"Error hiding keyboard: {e}")
            return False

    def ensure_element_visible(
        self, locator, is_element_visible_func, timeout=10
    ) -> bool:
        try:
            if is_element_visible_func(locator, timeout=2):
                return True

            self.logger.info("Element not visible, attempting to hide keyboard")
            if self.hide_keyboard():
                return is_element_visible_func(locator, timeout=timeout)

            return False

        except Exception as e:
            self.logger.error(f"Error ensuring element visibility: {e}")
            return False

    def dismiss_keyboard_in_modal(
        self, modal_root_locator, find_element_safe_func
    ) -> bool:
        """Dismiss keyboard by tapping within modal header area (avoids Back navigation)."""
        try:
            root = find_element_safe_func(modal_root_locator, timeout=1)
            if not root:
                try:
                    size = self.driver.get_window_size()
                    self.gestures.swipe_down(
                        int(size["width"] * 0.5) - 10,
                        int(size["height"] * 0.3),
                        20,
                        int(size["height"] * 0.2),
                        0.6,
                    )
                    return True
                except Exception:
                    return False

            rect = root.rect
            x = int(rect.get("x", 0)) + int(rect.get("width", 800)) // 2
            y = int(rect.get("y", 0)) + 24

            try:
                self.gestures.tap(x, y)
                return True
            except Exception:
                return False

        except Exception:
            return False
