import time

import allure
import typing

import configs.timeouts
import driver
from driver.objects_access import wait_for_template, walk_children
from gui.components.base_popup import BasePopup
from gui.components.wallet.token_selector_popup import TokenSelectorPopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class SendPopup(BasePopup):

    def __init__(self):
        super().__init__()
        # new single chain send modal
        self.send_modal_header = QObject(names.sendModalHeader)
        self.send_modal_recipient_panel = QObject(names.sendModalRecipientPanel)

        # old send modal
        self._tokens_list = QObject(names.statusListView)
        self._tab_item_template = QObject(names.tab_Status_template)
        self._search_field = TextEdit(names.search_TextEdit)
        self._asset_list_item = QObject(names.o_TokenBalancePerChainDelegate_template)
        self._collectible_list_item = QObject(names.o_CollectibleNestedDelegate_template)
        self._amount_to_send_text_edit = TextEdit(names.amountInput_TextEdit)
        self._paste_button = Button(names.paste_StatusButton)
        self._ens_address_text_edit = TextEdit(names.ens_or_address_TextEdit)
        self._my_accounts_tab = Button(names.accountSelectionTabBar_My_Accounts_StatusTabButton)
        self._account_list_item = QObject(names.status_account_WalletAccountListItem_template)
        self._arbitrum_network = QObject(names.arbitrum_StatusListItem)
        self._mainnet_network = QObject(names.mainnet_StatusListItem)
        self._fiat_fees_label = TextLabel(names.fiatFees_StatusBaseText)
        self._send_button = Button(names.send_StatusFlatButton)
        self._account_selector = QObject(names.accountSelector_AccountSelectorHeader)
        self._holding_selector = Button(names.tokenSelectorButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self.send_modal_header.wait_until_appears()
        return self

    @allure.step('Get current text in account selector')
    def get_text_from_account_selector(self) -> str:
        return str(self._account_selector.object.currentText)

    @allure.step('Select asset or collectible by name')
    def _select_asset_or_collectible(self, name: str, tab: str, attempts: int = 2):
        if tab == 'Assets':
            self._asset_list_item.wait_until_appears(timeout_msec=10000)
            assets = self.get_assets_or_collectibles_list(tab)
            for index, item in enumerate(assets):
                if getattr(item, 'title', '') == name:
                    QObject(item).click()
                    break
            assert driver.waitFor(lambda: self._amount_to_send_text_edit.is_visible, timeout_msec=6000)

        elif tab == 'Collectibles':
            self._collectible_list_item.wait_until_appears(timeout_msec=15000)
            self._search_field.type_text(name)
            time.sleep(3)
            assets = self.get_assets_or_collectibles_list(tab)
            for index, item in enumerate(assets):
                if getattr(item, 'title', '') == name:
                    QObject(item).click()
                    break
            try:
                return self._ens_address_text_edit.wait_until_appears(
                    timeout_msec=configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            except AssertionError as err:
                if attempts:
                    self._select_asset_or_collectible(attempts - 1)
                else:
                    raise err

    @allure.step('Get assets or collectibles list')
    def get_assets_or_collectibles_list(self, tab: str) -> typing.List[str]:
        assets_or_collectibles_list = []
        if tab == 'Assets':
            for asset in driver.findAllObjects(self._asset_list_item.real_name):
                assets_or_collectibles_list.append(asset)
        elif tab == 'Collectibles':
            for asset in walk_children(self._tokens_list.object):
                assets_or_collectibles_list.append(asset)
        return assets_or_collectibles_list

    def open_token_selector(self):
        self._holding_selector.click()
        return TokenSelectorPopup().wait_until_appears()

    @allure.step('Send {2} {3} to {1}')
    def send(self, address: str, amount: int, asset: str):
        token_selector = self.open_token_selector()
        if asset:
            token_selector.select_asset_from_list(asset_name=asset)
            self._amount_to_send_text_edit.text = str(amount)
            self._ens_address_text_edit.wait_until_appears(timeout_msec=configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            self._ens_address_text_edit.type_text(address)
        else:
            search_view = token_selector.open_collectibles_search_view()
            search_view.select_random_collectible()
            self._ens_address_text_edit.wait_until_appears(timeout_msec=configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            self._ens_address_text_edit.type_text(address)

        assert driver.waitFor(lambda: self._send_button.is_visible, timeout_msec=8000)
        self._send_button.click()
