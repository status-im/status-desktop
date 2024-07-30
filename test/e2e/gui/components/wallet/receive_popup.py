import allure
import pyperclip

import configs.timeouts
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.objects_map import names


class ReceivePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self.eth_icon = QObject(names.networkTagRectangle_eth_Rectangle)
        self.oeth_icon = QObject(names.networkTagRectangle_oeth_Rectangle)
        self.arb_icon = QObject(names.networkTagRectangle_arb1_Rectangle)
        self.multichain_tab_button = Button(names.tabBar_Multichain_StatusSwitchTabButton)
        self.legacy_tab_button = Button(names.tabBar_Legacy_StatusSwitchTabButton)
        self._account_selector = QObject(names.accountSelector_AccountSelectorHeader)
        self._account_selector_text = QObject(names.textContent_StatusBaseText)
        self._copy_button = Button(names.greenCircleAroundIcon_Rectangle)
        self._edit_button = Button(names.edit_pencil_icon_StatusIcon)
        self.qr_code = QObject(names.qrCodeImage_Image)
        self.mainnet_network_checkbox = CheckBox(names.networkSelectorDelegate_Mainnet_NetworkSelectItemDelegate)
        self.optimism_network_checkbox = CheckBox(names.networkSelectorDelegate_Optimism_NetworkSelectItemDelegate)
        self.arbitrum_network_checkbox = CheckBox(names.networkSelectorDelegate_Arbitrum_NetworkSelectItemDelegate)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self.multichain_tab_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Click account selector combobox')
    def click_account_selector(self):
        self._account_selector.click()
        return self

    @allure.step('Get current text in account selector')
    def get_text_from_account_selector(self) -> str:
        return str(self._account_selector_text.object.text)

    @allure.step('Copy address')
    def copy_address(self) -> str:
        self._copy_button.click()
        return str(pyperclip.paste())

    @allure.step('Click edit button')
    def edit_networks(self):
        self._edit_button.click()
        self.mainnet_network_checkbox.wait_until_appears()
        return self
