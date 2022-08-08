from enum import Enum
import time
import sys
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from common.SeedUtils import *


class SigningPhrasePopUp(Enum):
    OK_GOT_IT_BUTTON: str = "signPhrase_Ok_Button"


class MainWalletScreen(Enum):
    ADD_ACCOUNT_BUTTON: str = "mainWallet_Add_Account"
    ACCOUNT_NAME: str = "mainWallet_Account_Name"
    SEND_BUTTON_FOOTER: str = "mainWallet_Footer_Send_Button"
    SAVED_ADDRESSES_BUTTON: str = "mainWallet_Saved_Addresses_Button"
    NETWORK_SELECTOR_BUTTON: str = "mainWallet_Network_Selector_Button"

class AssetView(Enum):
    LIST: str = "mainWallet_Assets_View_List"
    
class NetworkSelectorPopup(Enum):
    LAYER_1_REPEATER: str = "mainWallet_Network_Popup_Chain_Repeater_1"

class SavedAddressesScreen(Enum):
    ADD_BUTTON: str = "mainWallet_Saved_Addreses_Add_Buttton"
    SAVED_ADDRESSES_LIST: str = "mainWallet_Saved_Addreses_List"
    EDIT: str = "mainWallet_Saved_Addreses_More_Edit"
    DELETE: str = "mainWallet_Saved_Addreses_More_Delete"
    CONFIRM_DELETE: str = "mainWallet_Saved_Addreses_More_Confirm_Delete"
    
class AddSavedAddressPopup(Enum):
    NAME_INPUT: str = "mainWallet_Saved_Addreses_Popup_Name_Input"
    ADDRESS_INPUT: str = "mainWallet_Saved_Addreses_Popup_Address_Input"
    ADD_BUTTON: str = "mainWallet_Saved_Addreses_Popup_Address_Add_Button"

class SendPopup(Enum):
    SCROLL_BAR: str = "mainWallet_Send_Popup_Main"
    HEADER_ACCOUNTS_LIST: str = "mainWallet_Send_Popup_Header_Accounts"
    AMOUNT_INPUT: str = "mainWallet_Send_Popup_Amount_Input"
    MY_ACCOUNTS_TAB: str = "mainWallet_Send_Popup_My_Accounts_Tab"
    MY_ACCOUNTS_LIST: str = "mainWallet_Send_Popup_My_Accounts_List"
    NETWORKS_LIST: str = "mainWallet_Send_Popup_Networks_List"
    SEND_BUTTON: str = "mainWallet_Send_Popup_Send_Button"
    PASSWORD_INPUT: str = "mainWallet_Send_Popup_Password_Input"
    
class AddAccountPopup(Enum):
    SCROLL_BAR: str = "mainWallet_Add_Account_Popup_Main"
    PASSWORD_INPUT: str = "mainWallet_Add_Account_Popup_Password"
    ACCOUNT_NAME_INPUT: str = "mainWallet_Add_Account_Popup_Account_Name"
    ADVANCE_SECTION: str = "mainWallet_Add_Account_Popup_Advanced"
    TYPE_SELECTOR: str = "mainWallet_Add_Account_Popup_Type_Selector"
    TYPE_WATCH_ONLY: str = "mainWallet_Add_Account_Popup_Type_Watch_Only"
    TYPE_SEED_PHRASE: str = "mainWallet_Add_Account_Popup_Type_Seed_Phrase"
    TYPE_PRIVATE_KEY: str = "mainWallet_Add_Account_Popup_Type_Private_Key"
    ADDRESS_INPUT: str = "mainWallet_Add_Account_Popup_Watch_Only_Address"
    PRIVATE_KEY_INPUT: str = "mainWallet_Add_Account_Popup_Private_Key"
    ADD_ACCOUNT_BUTTON: str = "mainWallet_Add_Account_Popup_Footer_Add_Account"
    SEED_PHRASE_INPUT_TEMPLATE: str = "mainWindow_Add_Account_Popup_Seed_Phrase_"

class StatusWalletScreen:
    
    def accept_signing_phrase(self):
        click_obj_by_name(SigningPhrasePopUp.OK_GOT_IT_BUTTON.value)
        
    def add_watch_only_account(self, account_name: str, address: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)
        
        type(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        click_obj_by_name(AddAccountPopup.ADVANCE_SECTION.value)
        click_obj_by_name(AddAccountPopup.TYPE_SELECTOR.value)
        time.sleep(1)
        click_obj_by_name(AddAccountPopup.TYPE_WATCH_ONLY.value)
        
        type(AddAccountPopup.ADDRESS_INPUT.value, address)
        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)

    def import_private_key(self, account_name: str, password: str, private_key: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)
        
        type(AddAccountPopup.PASSWORD_INPUT.value, password)
        type(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        click_obj_by_name(AddAccountPopup.ADVANCE_SECTION.value)
        click_obj_by_name(AddAccountPopup.TYPE_SELECTOR.value)
        time.sleep(1)
        click_obj_by_name(AddAccountPopup.TYPE_PRIVATE_KEY.value)
        
        type(AddAccountPopup.PRIVATE_KEY_INPUT.value, private_key)
        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)
    
    def import_seed_phrase(self, account_name: str, password: str, mnemonic: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)
        
        type(AddAccountPopup.PASSWORD_INPUT.value, password)
        type(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)
        
        click_obj_by_name(AddAccountPopup.ADVANCE_SECTION.value)
        click_obj_by_name(AddAccountPopup.TYPE_SELECTOR.value)
        time.sleep(1)
        click_obj_by_name(AddAccountPopup.TYPE_SEED_PHRASE.value)
        
        words = mnemonic.split()
        scroll_obj_by_name(AddAccountPopup.SCROLL_BAR.value)
        time.sleep(1)

        scroll_obj_by_name(AddAccountPopup.SCROLL_BAR.value)
        time.sleep(1)

        scroll_obj_by_name(AddAccountPopup.SCROLL_BAR.value)
        time.sleep(1)

        input_seed_phrase(AddAccountPopup.SEED_PHRASE_INPUT_TEMPLATE.value, words)
        time.sleep(1)
        
        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)
        
    def generate_new_account(self, account_name: str, password: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)
        
        type(AddAccountPopup.PASSWORD_INPUT.value, password)
        type(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        time.sleep(2)
        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)
         
    def verify_account_name_is_present(self, account_name: str):
        verify_text_matching(MainWalletScreen.ACCOUNT_NAME.value, account_name)
        
    def send_transaction(self, account_name, amount, token, chain_name, password):
        click_obj_by_name(MainWalletScreen.SEND_BUTTON_FOOTER.value)
        
        self._click_repeater(SendPopup.HEADER_ACCOUNTS_LIST.value, account_name)
        time.sleep(1)
        type(SendPopup.AMOUNT_INPUT.value, amount)
        
        if token != "ETH":
            print("TODO: switch token")
        
        click_obj_by_name(SendPopup.MY_ACCOUNTS_TAB.value)
        
        accounts = get_obj(SendPopup.MY_ACCOUNTS_LIST.value)
        for index in range(accounts.count):
            if(accounts.itemAtIndex(index).objectName == account_name):
                click_obj(accounts.itemAtIndex(index))
                break

        scroll_obj_by_name(SendPopup.SCROLL_BAR.value)
        time.sleep(2)
        scroll_obj_by_name(SendPopup.SCROLL_BAR.value)
        time.sleep(2)
        scroll_obj_by_name(SendPopup.SCROLL_BAR.value)
        time.sleep(2)
        
        self._click_repeater(SendPopup.NETWORKS_LIST.value, chain_name)
        
        click_obj_by_name(SendPopup.SEND_BUTTON.value)
        
        type(SendPopup.PASSWORD_INPUT.value, password)
        click_obj_by_name(SendPopup.SEND_BUTTON.value)
    
    def _click_repeater(self, repeater_object_name: str, object_name: str):
        repeater = get_obj(repeater_object_name)
        for index in range(repeater.count):
            if(repeater.itemAt(index).objectName == object_name):
                click_obj(repeater.itemAt(index))
                break
    
    def add_saved_address(self, name: str, address: str):
        click_obj_by_name(MainWalletScreen.SAVED_ADDRESSES_BUTTON.value)
        click_obj_by_name(SavedAddressesScreen.ADD_BUTTON.value)
        type(AddSavedAddressPopup.NAME_INPUT.value, name)
        type(AddSavedAddressPopup.ADDRESS_INPUT.value, address)
        click_obj_by_name(AddSavedAddressPopup.ADD_BUTTON.value)
        
    def edit_saved_address(self, name: str, new_name: str):
        list = get_obj(SavedAddressesScreen.SAVED_ADDRESSES_LIST.value)
        found = -1
        for index in range(list.count):
            if list.itemAtIndex(index).objectName == name:
                found = index
        
        assert found != -1, "saved address not found"
        
        # More icon is at index 2
        time.sleep(1)
        click_obj(list.itemAtIndex(found).components.at(2))
        
        click_obj_by_name(SavedAddressesScreen.EDIT.value)
        type(AddSavedAddressPopup.NAME_INPUT.value, new_name)
        click_obj_by_name(AddSavedAddressPopup.ADD_BUTTON.value)
    
    def delete_saved_address(self, name: str):
        list = get_obj(SavedAddressesScreen.SAVED_ADDRESSES_LIST.value)
        found = -1
        for index in range(list.count):
            if list.itemAtIndex(index).objectName == name:
                found = index
        
        assert found != -1, "saved address not found"
        
        # More icon is at index 2
        time.sleep(1)
        click_obj(list.itemAtIndex(found).components.at(2))
        
        click_obj_by_name(SavedAddressesScreen.DELETE.value)
        click_obj_by_name(SavedAddressesScreen.CONFIRM_DELETE.value)
    
    def toggle_network(self, network_name: str):
        click_obj_by_name(MainWalletScreen.NETWORK_SELECTOR_BUTTON.value)

        list = get_obj(NetworkSelectorPopup.LAYER_1_REPEATER.value)
        for index in range(list.count):
            if list.itemAt(index).objectName == network_name:
                click_obj(list.itemAt(index))
                click_obj_by_name(MainWalletScreen.ACCOUNT_NAME.value)
                time.sleep(2)
                return
        
        assert False, "network name not found"

        
    def verify_positive_balance(self, symbol: str):
        list = get_obj(AssetView.LIST.value)
        for index in range(list.count):
            if list.itemAtIndex(index).objectName == symbol:
                balance = list.itemAtIndex(index).children.at(2).text
                assert balance != f"0 {symbol}", "balance is not positive"
                return
            
        assert False, "symbol not found"
        
    def verify_saved_address_exists(self, name: str):
        list = get_obj(SavedAddressesScreen.SAVED_ADDRESSES_LIST.value)
        for index in range(list.count):
            if list.itemAtIndex(index).objectName == name:
                return  
    
        assert False, "no saved address found"
        
    def verify_saved_address_doesnt_exist(self, name: str):
        list = get_obj(SavedAddressesScreen.SAVED_ADDRESSES_LIST.value)
        for index in range(list.count):
            if list.itemAtIndex(index).objectName == name:
                assert False, "saved address found"  

    def verify_transaction(self):
        print("TODO: fix notification and ensure there is one")
