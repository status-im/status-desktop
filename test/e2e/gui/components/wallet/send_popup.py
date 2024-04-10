import allure
import typing

import driver
from driver.objects_access import wait_for_template
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class SendPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._tab_item_template = QObject(names.tab_Status_template)
        self._search_field = TextEdit(names.search_TextEdit)
        self._asset_list_item = QObject(names.o_TokenBalancePerChainDelegate_template)
        self._collectible_list_item = QObject(names.o_CollectibleNestedDelegate_template)
        self._amount_text_edit = TextEdit(names.amountInput_TextEdit)
        self._paste_button = Button(names.paste_StatusButton)
        self._ens_address_text_edit = TextEdit(names.ens_or_address_TextEdit)
        self._my_accounts_tab = Button(names.accountSelectionTabBar_My_Accounts_StatusTabButton)
        self._account_list_item = QObject(names.status_account_WalletAccountListItem_template)
        self._arbitrum_network = QObject(names.arbitrum_StatusListItem)
        self._mainnet_network = QObject(names.mainnet_StatusListItem)
        self._fiat_fees_label = TextLabel(names.fiatFees_StatusBaseText)
        self._send_button = Button(names.send_StatusFlatButton)

    @allure.step('Select asset or collectible by name')
    def _select_asset_or_collectible(self, name: str, tab: str):
        assets = self.get_assets_or_collectibles_list(tab)
        for index, item in enumerate(assets):
            if str(item.title) == name:
                QObject(item).click()

    @allure.step('Get assets or collectibles list')
    def get_assets_or_collectibles_list(self, tab: str) -> typing.List[str]:
        assets_or_collectibles_list = []
        if tab == 'Assets':
            for asset in driver.findAllObjects(self._asset_list_item.real_name):
                assets_or_collectibles_list.append(asset)
        elif tab == 'Collectibles':
            for asset in driver.findAllObjects(self._collectible_list_item.real_name):
                assets_or_collectibles_list.append(asset)
        return assets_or_collectibles_list

    @allure.step('Open tab')
    def _open_tab(self, name: str):
        assets_tab = wait_for_template(self._tab_item_template.real_name, name, 'text')
        driver.mouseClick(assets_tab)

    @allure.step('Send {2} {3} to {1}')
    def send(self, address: str, amount: int, name: str, tab: str):
        self._open_tab(tab)
        self._select_asset_or_collectible(name, tab)
        if tab == 'Assets':
            assert driver.waitFor(lambda: self._amount_text_edit.is_visible, timeout_msec=6000)
            self._amount_text_edit.text = str(amount)
        self._ens_address_text_edit.type_text(address)
        assert driver.waitFor(lambda: self._send_button.is_visible, timeout_msec=8000)
        self.click_send()

    @allure.step('Click send button')
    def click_send(self):
        self._send_button.click()

    @allure.step('Get arbitrum network visibility state')
    def is_arbitrum_network_identified(self) -> bool:
        return self._arbitrum_network.is_visible

    @allure.step('Get mainnet network visibility state')
    def is_mainnet_network_identified(self) -> bool:
        return self._mainnet_network.is_visible

    @allure.step('Get fiat fees')
    def get_fiat_fees(self) -> str:
        return self._fiat_fees_label.text
