import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.objects_map import names


class RemoveWalletAccountPopup(BasePopup):

    def __init__(self):
        super(RemoveWalletAccountPopup, self).__init__()
        self._confirm_button = Button(names.mainWallet_Remove_Account_Popup_ConfirmButton)
        self._cancel_button = Button(names.mainWallet_Remove_Account_Popup_CancelButton)
        self._have_pen_paper_checkbox = CheckBox(names.mainWallet_Remove_Account_Popup_HavePenPaperCheckBox)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._cancel_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Confirm removing account')
    def confirm(self):
        # TODO https://github.com/status-im/status-desktop/issues/15345
        self._confirm_button.click()
        self._confirm_button.wait_until_hidden()

    @allure.step('Agree and confirm removing account')
    def agree_and_confirm(self):
        self._have_pen_paper_checkbox.set(True)
        self.confirm()
