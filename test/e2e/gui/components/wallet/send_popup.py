import time

import allure

import configs
import constants
import driver
from driver.objects_access import wait_for_template
from gui.components.base_popup import BasePopup
from gui.components.community.authenticate_popup import AuthenticatePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel


class SendPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._tab_item_template = QObject('tab_Status_template')
        self._search_field = TextEdit('search_TextEdit')
        self._asset_list_item = QObject('o_TokenBalancePerChainDelegate_template')
        self._amount_text_edit = TextEdit('amountInput_TextEdit')
        self._paste_button = Button('paste_StatusButton')
        self._ens_address_text_edit = TextEdit('ens_or_address_TextEdit')
        self._my_accounts_tab = Button('accountSelectionTabBar_My_Accounts_StatusTabButton')
        self._account_list_item = QObject('status_account_WalletAccountListItem_template')
        self._arbitrum_network = QObject('arbitrum_StatusListItem')
        self._mainnet_network = QObject('mainnet_StatusListItem')
        self._fiat_fees_label = TextLabel('fiatFees_StatusBaseText')
        self._send_button = Button('send_StatusFlatButton')

    def _select_asset(self, asset: str):
        for item in driver.findAllObjects(self._asset_list_item.real_name):
            if str(getattr(item, 'title', '')) == asset:
                driver.mouseClick(item)
            else:
                raise LookupError(f"Chosen asset didn't appear")

    def _open_tab(self, name: str):
        assets_tab = wait_for_template(self._tab_item_template.real_name, name, 'text')
        driver.mouseClick(assets_tab)

    @allure.step('Send {2} {3} to {1}')
    def send(self, address: str, amount: int, asset: str):
        self._open_tab('Assets')
        self._search_field.type_text(asset)
        self._select_asset(asset)
        assert driver.waitFor(lambda: self._amount_text_edit.is_visible, timeout_msec=6000)
        self._amount_text_edit.text = str(amount)
        self._ens_address_text_edit.type_text(address)
        assert driver.waitFor(lambda: self._send_button.is_visible, timeout_msec=6000)
        self.click_send()

    @allure.step('Click send button')
    def click_send(self):
        self._send_button.click()

    def is_arbitrum_network_identified(self) -> bool:
        return self._arbitrum_network.is_visible

    def is_mainnet_network_identified(self) -> bool:
        return self._mainnet_network.is_visible

    def get_fiat_fees(self) -> str:
        return self._fiat_fees_label.text
