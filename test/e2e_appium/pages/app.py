from typing import Optional
import time

from .base_page import BasePage
from locators.app_locators import AppLocators
from utils.screenshot import save_page_source
from utils.element_state_checker import ElementStateChecker


class App(BasePage):

    def __init__(self, driver):
        super().__init__(driver)
        self.locators = AppLocators()

    def has_left_nav(self, timeout: Optional[int] = 1) -> bool:
        return self.is_element_visible(self.locators.LEFT_NAV_ANY, timeout=timeout)

    def is_ready(self, timeout: Optional[int] = None) -> bool:
        return self.is_element_visible(
            self.locators.LEFT_NAV_ANY, timeout=timeout
        ) or self.is_element_visible(self.locators.HOME_DOCK_CONTAINER, timeout=timeout)

    def active_section(self) -> str:
        """Return current section: home, messaging, wallet, communities, market, settings, unknown."""
        if self.has_left_nav(timeout=1):
            mapping = {
                "home": self.locators.LEFT_NAV_HOME,
                "wallet": self.locators.LEFT_NAV_WALLET,
                "market": self.locators.LEFT_NAV_MARKET,
                "messaging": self.locators.LEFT_NAV_MESSAGES,
                "communities": self.locators.LEFT_NAV_COMMUNITIES,
                "settings": self.locators.LEFT_NAV_SETTINGS,
            }
            for name, locator in mapping.items():
                el = self.find_element_safe(locator, timeout=1)
                if el is not None:
                    try:
                        checked = ElementStateChecker.is_checked(el)
                        if checked:
                            return name
                    except Exception:
                        pass
            return "unknown"
        if self.is_element_visible(self.locators.HOME_DOCK_CONTAINER, timeout=1):
            return "home"
        return "unknown"

    def navigate_to(self, section: str, timeout: int = 30) -> bool:
        section = section.lower()
        if self.has_left_nav(timeout=1):
            target = {
                "home": self.locators.LEFT_NAV_HOME,
                "wallet": self.locators.LEFT_NAV_WALLET,
                "market": self.locators.LEFT_NAV_MARKET,
                "messaging": self.locators.LEFT_NAV_MESSAGES,
                "messages": self.locators.LEFT_NAV_MESSAGES,
                "communities": self.locators.LEFT_NAV_COMMUNITIES,
                "settings": self.locators.LEFT_NAV_SETTINGS,
            }.get(section)
            if not target:
                return False
            return self.safe_click(target)
        target = {
            "home": self.locators.HOME_DOCK_CONTAINER,
            "wallet": self.locators.DOCK_WALLET,
            "market": self.locators.DOCK_MARKET,
            "messaging": self.locators.DOCK_MESSAGES,
            "messages": self.locators.DOCK_MESSAGES,
            "communities": self.locators.DOCK_COMMUNITIES,
            "settings": self.locators.DOCK_SETTINGS,
        }.get(section)
        if not target:
            return False
        if section == "home":
            return self.is_element_visible(
                self.locators.HOME_DOCK_CONTAINER, timeout=timeout
            )
        return self.safe_click(target)

    # Convenience wrappers
    def click_home(self) -> bool:
        return self.navigate_to("home")

    def click_wallet(self) -> bool:
        return self.navigate_to("wallet")

    def click_messages(self) -> bool:
        return self.navigate_to("messaging")

    def click_communities(self) -> bool:
        return self.navigate_to("communities")

    def click_market(self) -> bool:
        return self.navigate_to("market")

    def click_settings(self) -> bool:
        return self.navigate_to("settings", timeout=4, max_attempts=2)

    def click_settings_left_nav(self) -> bool:
        return self.safe_click(self.locators.LEFT_NAV_SETTINGS, timeout=4, max_attempts=2)

    def is_toast_present(self, timeout: Optional[int] = 3) -> bool:
        present = self.is_element_visible(self.locators.ANY_TOAST, timeout=timeout)
        if not present:
            return False

        try:
            el = self.find_element_safe(self.locators.ANY_TOAST, timeout=1)
            if el is not None:
                text_value = ElementStateChecker.get_text_content(el)
                try:
                    desc_value = el.get_attribute("content-desc") or ""
                except Exception:
                    desc_value = ""
                if text_value or desc_value:
                    self.logger.info(
                        f"Toast detected text='{text_value}' content-desc='{desc_value}'"
                    )
        except Exception as e:
            self.logger.debug(f"Toast attribute read failed: {e}")

        try:
            _ = save_page_source(self.driver, self._screenshots_dir, "toast")
        except Exception as e:
            self.logger.debug(f"Toast page source save failed: {e}")

        return True

    def get_toast_content_desc(self, timeout: Optional[int] = 3) -> Optional[str]:
        """Return toast's content-desc, polling until non-empty or timeout."""
        try:
            el = self.find_element_safe(self.locators.ANY_TOAST, timeout=timeout)
            if el is None:
                return None

            end = time.time() + (timeout or 0)
            last_val: str = ""
            while True:
                try:
                    val = el.get_attribute("content-desc") or ""
                    if val:
                        return val
                    last_val = val
                except Exception:
                    pass
                if time.time() >= end:
                    return last_val or None
                time.sleep(0.1)
        except Exception:
            return None
