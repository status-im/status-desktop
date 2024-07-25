import allure

import configs.timeouts
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class ReceivePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._eth_icon = QObject(names.networkTagRectangle_eth_Rectangle)
        self._oeth_icon = QObject(names.networkTagRectangle_oeth_Rectangle)
        self._arb_icon = QObject(names.networkTagRectangle_arb1_Rectangle)
        self._multichain_tab_button = Button(names.tabBar_Multichain_StatusSwitchTabButton)
        self._account_selector = QObject(names.accountSelector_AccountSelectorHeader)
        self._account_selector_text = QObject(names.textContent_StatusBaseText)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._multichain_tab_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Click account selector combobox')
    def click_account_selector(self):
        self._account_selector.click()
        return self

    @allure.step('Get current text in account selector')
    def get_text_from_account_selector(self) -> str:
        return str(self._account_selector_text.object.text)
