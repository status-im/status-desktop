import time

import allure
import typing

import configs.timeouts
import driver
from driver.objects_access import walk_children
from gui.components.base_popup import BasePopup
from gui.components.wallet.sign_send_popup import SignSendModalPopup
from gui.components.wallet.token_selector_popup import TokenSelectorPopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class SendPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self.send_modal_header = QObject(names.sendModalHeader)
        self.send_modal_recipient_panel = QObject(names.sendModalRecipientPanel)
        self.send_modal_token_selector = Button(names.sendModalTokenSelector)
        self.send_modal_network_filter = QObject(names.sendModalNetworkFilter)
        self.send_modal_network_item = QObject(names.sendModalNetworkSelectorItem)
        self.send_modal_amount_field = TextEdit(names.sendModalAmountField)
        self.send_modal_recipient_field = TextEdit(names.sendModalRecipientField)
        self.send_modal_sign_txn_fees = QObject(names.sendModalSendTransactionFees)
        self.send_modal_review_send_button = Button(names.sendModalReviewSendButton)
        self.send_button = Button(names.send_StatusFlatButton)
        self.tokens_list = QObject(names.statusListView)
        self.asset_list_item = QObject(names.o_TokenBalancePerChainDelegate_template)
        self.ens_address_text_edit = TextEdit(names.ens_or_address_TextEdit)


    @allure.step('Get assets or collectibles list')
    def get_assets_or_collectibles_list(self, tab: str) -> typing.List[str]:
        assets_or_collectibles_list = []
        if tab == 'Assets':
            for asset in driver.findAllObjects(self.asset_list_item.real_name):
                assets_or_collectibles_list.append(asset)
        elif tab == 'Collectibles':
            for asset in walk_children(self.tokens_list.object):
                assets_or_collectibles_list.append(asset)
        return assets_or_collectibles_list

    @allure.step('Open token selector')
    def open_token_selector(self):
        self.send_modal_token_selector.click()
        return TokenSelectorPopup().wait_until_appears()

    @allure.step('Select network in network selector')
    def select_network(self, network_name):
        self.send_modal_network_filter.click()
        network_options = driver.findAllObjects(self.send_modal_network_item.real_name)
        assert network_options, f'Network options are not displayed'
        for item in network_options:
            if str(getattr(item, 'objectName', '')).endswith(network_name):
                QObject(item).click()
                time.sleep(0.2)  # allow network selector component to hide
                break
        return self

    @allure.step('Open sign and send modal')
    def open_sign_send_modal(self):
        self.send_modal_review_send_button.click()
        return SignSendModalPopup().wait_until_appears()

    @allure.step('Send {2} {3} to {1}')
    def sign_and_send(self, address: str, amount: str, asset: str):
        token_selector = self.open_token_selector()

        if asset:
            token_selector.select_asset_from_list(asset_name=asset)
            self.send_modal_amount_field.text = amount
            self.send_modal_recipient_field.type_text(address)

        else:
            search_view = token_selector.open_collectibles_search_view()
            search_view.select_random_collectible()
            self.ens_address_text_edit.wait_until_appears(timeout_msec=configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            self.ens_address_text_edit.type_text(address)

        assert self.send_modal_sign_txn_fees.wait_until_appears(timeout_msec=configs.timeouts.FEES_TIMEOUT_MSEC), \
            f'Fees panel is not displayed within 10s'
        assert self.send_modal_review_send_button.wait_until_appears(timeout_msec=configs.timeouts.FEES_TIMEOUT_MSEC), \
            f'Fees are not displayed within 10s'

        self.open_sign_send_modal().sign_send_modal_reject_button.click()
        sign_send_modal = self.open_sign_send_modal()
        sign_send_modal.sign_send_modal_sign_button.click()

