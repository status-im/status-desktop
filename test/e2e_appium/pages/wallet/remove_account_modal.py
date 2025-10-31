from ..base_page import BasePage
from locators.wallet.accounts_locators import WalletAccountsLocators as Loc


class RemoveAccountConfirmationModal(BasePage):
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = Loc

    def is_displayed(self, timeout: int = 5) -> bool:
        return self.is_element_visible(self.locators.REMOVE_ACCOUNT_MODAL, timeout=timeout)

    def _checkbox_checked(self) -> bool:
        checkbox = self.find_element_safe(self.locators.REMOVE_ACCOUNT_ACK_CHECKBOX, timeout=1)
        if not checkbox:
            return False
        try:
            return str(checkbox.get_attribute("checked")).lower() == "true"
        except Exception:
            return False

    def acknowledge_derivation_path(self) -> bool:
        if self._checkbox_checked():
            return True
        self.safe_click(self.locators.REMOVE_ACCOUNT_ACK_CHECKBOX, timeout=5)
        return self._checkbox_checked()

    def confirm_removal(self, timeout: int = 15) -> bool:
        if not self.is_displayed(timeout=timeout):
            self.logger.error("Remove account confirmation modal not displayed")
            return False

        if not self.acknowledge_derivation_path():
            self.logger.error("Failed to acknowledge derivation path checkbox")
            return False

        def confirm_enabled() -> bool:
            try:
                btn = self.find_element_safe(self.locators.REMOVE_ACCOUNT_CONFIRM_BUTTON, timeout=1)
                return bool(btn and str(btn.get_attribute("enabled")).lower() == "true")
            except Exception:
                return False

        if not self.wait_for_condition(confirm_enabled, timeout=timeout):
            self.logger.error("Remove account confirm button did not become enabled")
            return False

        self.safe_click(self.locators.REMOVE_ACCOUNT_CONFIRM_BUTTON, timeout=timeout)
        return True
