from drivers.SquishDriver import *

from .authenticate_popup import AuthenticatePopup
from .base_popup import BasePopup


class RemoveWalletAccountPopup(BasePopup):

    def __init__(self):
        super(RemoveWalletAccountPopup, self).__init__()
        self._confirm_button = Button('mainWallet_Remove_Account_Popup_ConfirmButton')
        self._cancel_button = Button('mainWallet_Remove_Account_Popup_CancelButton')
        self._have_pen_paper_checkbox = CheckBox('mainWallet_Remove_Account_Popup_HavePenPaperCheckBox')

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        self._cancel_button.wait_until_appears(timeout_msec)
        return self

    def confirm(self):
        self._confirm_button.click()
        self._confirm_button.wait_until_hidden()

    def cancel(self):
        self._cancel_button.click()
        self._cancel_button.wait_until_hidden()

    def agree_and_confirm(self) -> AuthenticatePopup:
        self._have_pen_paper_checkbox.wait_until_appears().set(True)
        self.confirm()
        return AuthenticatePopup().wait_until_appears()
