import time

import allure

import configs
import driver
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class AddSavedAddressPopup(BasePopup):
    def __init__(self):
        super(AddSavedAddressPopup, self).__init__()
        self._name_text_edit = TextEdit(names.mainWallet_Saved_Addreses_Popup_Name_Input)
        self._save_add_address_button = Button(names.mainWallet_Saved_Addreses_Popup_Address_Add_Button)
        self._add_networks_selector = QObject(names.mainWallet_Saved_Addreses_Popup_Add_Network_Selector_Tag)
        self._add_networks_button = Button(names.mainWallet_Saved_Addreses_Popup_Add_Network_Button)
        self._ethereum_mainnet_checkbox = CheckBox(
            names.networkSelectionCheckbox_Ethereum_Mainnet_StatusCheckBox)
        self._optimism_mainnet_checkbox = CheckBox(
            names.networkSelectionCheckbox_Optimism_StatusCheckBox)
        self._arbitrum_mainnet_checkbox = CheckBox(
            names.networkSelectionCheckbox_Arbitrum_StatusCheckBox)
        self._ethereum_mainnet_network_tag = QObject(
            names.mainWallet_Saved_Addresses_Popup_Network_Selector_Mainnet_network_tag)
        self._optimism_mainnet_network_tag = QObject(
            names.mainWallet_Saved_Addresses_Popup_Network_Selector_Optimism_network_tag)
        self._arbitrum_mainnet_network_tag = QObject(
            names.mainWallet_Saved_Addresses_Popup_Network_Selector_Arbitrum_network_tag)

    @allure.step('Set ethereum mainnet network checkbox')
    def set_ethereum_mainnet_network(self, value: bool):
        assert driver.waitFor(lambda: self._ethereum_mainnet_checkbox.exists, configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        self._ethereum_mainnet_checkbox.set(value)
        return self

    @allure.step('Set optimism mainnet network checkbox')
    def set_optimism_mainnet_network(self, value: bool):
        assert self._optimism_mainnet_checkbox.exists
        self._optimism_mainnet_checkbox.set(value)
        return self

    @allure.step('Set arbitrum mainnet network checkbox')
    def set_arbitrum_mainnet_network(self, value: bool):
        assert self._arbitrum_mainnet_checkbox.exists
        self._arbitrum_mainnet_checkbox.set(value)
        return self

    @allure.step('Verify that network selector enabled')
    def verify_network_selector_enabled(self):
        assert self._add_networks_selector.is_visible, f'Network selector is not enabled'

    @allure.step('Verify that etherium mainnet network present')
    def verify_ethereum_mainnet_network_tag_present(self):
        assert self._ethereum_mainnet_network_tag.is_visible, f'Ethereum Mainnet network tag is not present'

    @allure.step('Verify that etherium mainnet network present')
    def verify_otimism_mainnet_network_tag_present(self):
        assert self._optimism_mainnet_network_tag.is_visible, f'Optimism Mainnet network tag is not present'

    @allure.step('Verify that arbitrum mainnet network present')
    def verify_arbitrum_mainnet_network_tag_present(self):
        assert self._arbitrum_mainnet_network_tag.is_visible, f'Arbitrum Mainnet network tag is not present'


class AddressPopup(AddSavedAddressPopup):
    def __init__(self):
        super(AddressPopup, self).__init__()
        self._address_text_edit = TextEdit(names.mainWallet_Saved_Addreses_Popup_Address_Input_Edit)

    @allure.step('Add saved address')
    def add_saved_address(self, name: str, address: str):
        self._name_text_edit.text = name
        self._address_text_edit.clear(verify=False)
        self._address_text_edit.type_text(address)
        if address.startswith("0x"):
            self.verify_network_selector_enabled()
            self._add_networks_selector.click()
            time.sleep(0.1)
            self.set_ethereum_mainnet_network(True)
            self.set_optimism_mainnet_network(True)
            self.set_arbitrum_mainnet_network(True)
            self._name_text_edit.click()  # click the text field to close the network selector pop up
            self.verify_ethereum_mainnet_network_tag_present()
            self.verify_otimism_mainnet_network_tag_present()
            self.verify_arbitrum_mainnet_network_tag_present(),
        self._save_add_address_button.click()


class EditSavedAddressPopup(AddSavedAddressPopup):

    def __init__(self):
        super(EditSavedAddressPopup, self).__init__()
        self._address_text_label = TextLabel(names.mainWallet_Saved_Addreses_Popup_Address_Input_Edit)

    @allure.step('Edit saved address')
    def edit_saved_address(self, new_name: str, address: str):
        self._name_text_edit.text = new_name
        if address.startswith("0x"):
            self._add_networks_button.click()
            self.set_ethereum_mainnet_network(False)
            self.set_optimism_mainnet_network(False)
            self.set_arbitrum_mainnet_network(False)
            self._save_add_address_button.click()
        self._save_add_address_button.click()
        self.wait_until_hidden()
