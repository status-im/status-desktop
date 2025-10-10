from typing import Optional

from ..base_page import BasePage
from locators.settings.password_change_locators import PasswordChangeLocators
from .change_password_modal import ChangePasswordModal


class PasswordChangePage(BasePage):
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = PasswordChangeLocators()

    def is_loaded(self, timeout: Optional[int] = 10) -> bool:
        if not self.is_element_visible(
            self.locators.CURRENT_PASSWORD_CONTAINER, timeout=timeout
        ):
            return False
        return self.is_element_visible(
            self.locators.CURRENT_PASSWORD_INPUT, timeout=timeout
        )

    def change_password(
        self, current_password: str, new_password: str
    ) -> Optional[ChangePasswordModal]:
        if not self.is_loaded(timeout=10):
            return None

        if not self.qt_safe_input(
            self.locators.CURRENT_PASSWORD_INPUT,
            current_password,
            verify=False,
        ):
            return None

        if not self.qt_safe_input(
            self.locators.NEW_PASSWORD_INPUT,
            new_password,
            verify=False,
        ):
            return None

        if not self.qt_safe_input(
            self.locators.CONFIRM_PASSWORD_INPUT,
            new_password,
            verify=False,
        ):
            return None

        if not self.safe_click(self.locators.CHANGE_PASSWORD_BUTTON):
            return None

        modal = ChangePasswordModal(self.driver)
        return modal if modal.is_displayed(timeout=20) else None
