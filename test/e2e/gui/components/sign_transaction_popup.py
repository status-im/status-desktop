import allure

import configs
from gui.components.authenticate_popup import AuthenticatePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class SignTransactionPopup(QObject):

    def __init__(self):
        super(SignTransactionPopup, self).__init__()
        self._sign_transaction_button = Button(names.sign_transaction_StatusButton)
        self._cancel_button = Button(names.cancel_transaction_StatusButton)
        self._fee_row = QObject(names.o_FeeRow)
        self._fee_total_row = QObject(names.feeTotalRow_FeeRow)

    @property
    @allure.step('Get fee title')
    def get_fee_title(self) -> str:
        return str(self._fee_row.object.title)

    @property
    @allure.step('Get fee total value')
    def get_fee_total_value(self) -> str:
        return str(self._fee_total_row.object.feeText)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._sign_transaction_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Wait until hidden {0}')
    def wait_until_hidden(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._sign_transaction_button.wait_until_hidden()

    @allure.step('Sign transaction')
    def sign_transaction(self, user_password):
        self._sign_transaction_button.click()
        self.wait_until_hidden()
        AuthenticatePopup().wait_until_appears().authenticate(user_password)
