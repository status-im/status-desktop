from typing import Optional

from ..base_page import BasePage
from locators.settings.settings_locators import SettingsLocators
from .backup_seed_modal import BackupSeedModal
from .password_change_page import PasswordChangePage
from locators.wallet.saved_addresses_locators import SavedAddressesLocators
from pages.wallet.saved_addresses_page import SavedAddressesPage


class SettingsPage(BasePage):
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = SettingsLocators()

    def is_loaded(self, timeout: Optional[int] = 6) -> bool:
        return self.is_element_visible(self.locators.PROFILE_MENU_ITEM, timeout=timeout)

    def open_sign_out_and_quit(self) -> bool:
        if self.safe_click(
            self.locators.SIGN_OUT_AND_QUIT,
            fallback_locators=[self.locators.SIGN_OUT_AND_QUIT_ALT], 
        ):
            return True
        return False

    def confirm_sign_out(self) -> bool:
        return self.safe_click(
            self.locators.CONFIRM_SIGN_OUT,
            fallback_locators=[self.locators.CONFIRM_QUIT],
        )

    def open_backup_recovery_phrase(self) -> Optional[BackupSeedModal]:
        try:
            if not self.is_element_visible(
                self.locators.BACKUP_RECOVERY_MENU_ITEM, timeout=10
            ):
                return None
            clicked = self.safe_click(
                self.locators.BACKUP_RECOVERY_MENU_ITEM, timeout=5
            )
        except Exception:
            return None
        if not clicked:
            return None
        modal = BackupSeedModal(self.driver)
        return modal if modal.is_displayed(timeout=10) else None

    def open_password_settings(self) -> Optional[PasswordChangePage]:
        if not self.is_loaded(timeout=10):
            return None
        try:
            if not self.safe_click(
                self.locators.PASSWORD_MENU_ITEM,
                timeout=5,
                fallback_locators=[self.locators.PASSWORD_MENU_ITEM_TEXT],
            ):
                return None
        except Exception:
            return None

        page = PasswordChangePage(self.driver)
        return page if page.is_loaded(timeout=10) else None

    def is_backup_entry_removed(self) -> bool:
        return not self.is_element_visible(
            self.locators.BACKUP_RECOVERY_MENU_ITEM, timeout=2
        )

    def open_saved_addresses(self) -> Optional[SavedAddressesPage]:
        locators = SavedAddressesLocators()
        if not self.is_loaded(timeout=10):
            return None
        try:
            self.safe_click(locators.SETTINGS_WALLET_MENU_ITEM)
        except Exception:
            pass
        try:
            if not self.is_element_visible(locators.SAVED_ADDRESSES_ITEM, timeout=10):
                return None
            if not self.safe_click(locators.SAVED_ADDRESSES_ITEM):
                return None
        except Exception:
            return None
        page = SavedAddressesPage(self.driver)
        return page if page.is_loaded(timeout=10) else None
