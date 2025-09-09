from typing import Optional

from ..base_page import BasePage
from locators.settings.settings_locators import SettingsLocators
from .backup_seed_modal import BackupSeedModal


class SettingsPage(BasePage):
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = SettingsLocators()

    def is_loaded(self, timeout: Optional[int] = 6) -> bool:
        return self.is_element_visible(self.locators.PROFILE_MENU_ITEM, timeout=timeout)

    def open_sign_out_and_quit(self) -> bool:
        # Try exact then heuristic
        if self.safe_click(
            self.locators.SIGN_OUT_AND_QUIT,
            fallback_locators=[self.locators.SIGN_OUT_AND_QUIT_ALT], 
        ):
            return True
        return False

    def confirm_sign_out(self) -> bool:
        #TODO: Remove fallback locators
        return self.safe_click(
            self.locators.CONFIRM_SIGN_OUT,
            fallback_locators=[self.locators.CONFIRM_QUIT],
        )

    def open_backup_recovery_phrase(self) -> Optional[BackupSeedModal]:
        # Click explicit TID menu item only
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

    def is_backup_entry_removed(self) -> bool:
        return not self.is_element_visible(
            self.locators.BACKUP_RECOVERY_MENU_ITEM, timeout=2
        )
