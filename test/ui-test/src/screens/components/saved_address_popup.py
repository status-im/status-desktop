from drivers.SquishDriver import *

from .base_popup import BasePopup


class SavedAddressPopup(BasePopup):
    def __init__(self):
        super(SavedAddressPopup, self).__init__()
        self._name_text_edit = TextEdit('mainWallet_Saved_Addreses_Popup_Name_Input')
        self._save_add_address_button = Button('mainWallet_Saved_Addreses_Popup_Address_Add_Button')
        self._add_networks_selector = BaseElement('mainWallet_Saved_Addreses_Popup_Add_Network_Selector_Tag')
        self._add_networks_button = Button('mainWallet_Saved_Addreses_Popup_Add_Network_Button')
        self._ethereum_mainnet_checkbox = CheckBox('mainWallet_Saved_Addresses_Popup_Add_Network_Selector_Mainnet_checkbox')
        self._optimism_mainnet_checkbox = CheckBox('mainWallet_Saved_Addresses_Popup_Add_Network_Selector_Optimism_checkbox')
        self._arbitrum_mainnet_checkbox = CheckBox('mainWallet_Saved_Addresses_Popup_Add_Network_Selector_Arbitrum_checkbox')
        self._ethereum_mainnet_network_tag = BaseElement('mainWallet_Saved_Addresses_Popup_Network_Selector_Mainnet_network_tag')
        self._optimism_mainnet_network_tag = BaseElement('mainWallet_Saved_Addresses_Popup_Network_Selector_Optimism_network_tag')
        self._arbitrum_mainnet_network_tag = BaseElement('mainWallet_Saved_Addresses_Popup_Network_Selector_Arbitrum_network_tag')

    def set_ethereum_mainnet_network(self, value: bool):
        self._ethereum_mainnet_checkbox.set(value)
        return self
    
    def set_optimism_mainnet_network(self, value: bool):
        self._optimism_mainnet_checkbox.set(value)
        return self
    
    def set_arbitrum_mainnet_network(self, value: bool):
        self._arbitrum_mainnet_checkbox.set(value)
        return self
    
    def verify_network_selector_enabled(self):
        assert self._add_networks_selector.is_visible, f'Network selector is not enabled'

    def verify_ethereum_mainnet_network_tag_present(self):
        assert self._ethereum_mainnet_network_tag.is_visible, f'Ethereum Mainnet network tag is not present'

    def verify_otimism_mainnet_network_tag_present(self):
        assert self._optimism_mainnet_network_tag.is_visible, f'Optimism Mainnet network tag is not present' 

    def verify_arbitrum_mainnet_network_tag_present(self):
        assert self._arbitrum_mainnet_network_tag.is_visible, f'Arbitrum Mainnet network tag is not present'



class AddSavedAddressPopup(SavedAddressPopup):
    def __init__(self):
        super(AddSavedAddressPopup, self).__init__()
        self._address_text_edit = TextEdit('mainWallet_Saved_Addreses_Popup_Address_Input_Edit')
    
    def add_saved_address(self, name: str, address: str):
        self._name_text_edit.text = name
        self._address_text_edit.clear(verify=False)
        self._address_text_edit.type_text(address)
        if address.startswith("0x"):
            self.verify_network_selector_enabled()
            self._add_networks_selector.click(1, 1)
            self.set_ethereum_mainnet_network(True)
            self.set_optimism_mainnet_network(True)
            self.set_arbitrum_mainnet_network(True)
            self._save_add_address_button.click() # i click it twice to close the network selector pop up
            self.verify_ethereum_mainnet_network_tag_present() 
            self.verify_otimism_mainnet_network_tag_present()
            self.verify_arbitrum_mainnet_network_tag_present(), 
        self._save_add_address_button.click()
        self.wait_until_hidden()


class EditSavedAddressPopup(SavedAddressPopup):

    def __init__(self):
        super(EditSavedAddressPopup, self).__init__()
        self._address_text_label = TextLabel('mainWallet_Saved_Addreses_Popup_Address_Input_Edit')

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
