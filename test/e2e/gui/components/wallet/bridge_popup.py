import allure

import configs.timeouts
from gui.components.base_popup import BasePopup
from gui.elements.object import QObject
from gui.objects_map import names


class BridgePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._select_token_combobox = QObject(names.holdingSelector_TokenSelectorNew)
        self._bridge_header = QObject(names.modalHeader_HeaderTitleText)
        self._account_selector = QObject(names.accountSelector_AccountSelectorHeader)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._select_token_combobox.wait_until_appears(timeout_msec)
        return self

    @allure.step('Click account selector combobox')
    def click_account_selector(self):
        self._account_selector.click()
        return self

    @allure.step('Get current text from header')
    def get_text_from_bridge_header(self) -> str:
        return str(self._bridge_header.object.text)

    @allure.step('Get current text in account selector')
    def get_text_from_account_selector(self) -> str:
        return str(self._account_selector.object.currentText)
