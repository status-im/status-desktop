from enum import Enum
import time
import sys
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


class SigningPhrasePopUp(Enum):
    OK_GOT_IT_BUTTON: str = "signPhrase_Ok_Button"


class MainWalletScreen(Enum):
    ADD_ACCOUNT_BUTTON: str = "mainWallet_Add_Account"
    ACCOUNT_NAME: str = "mainWallet_Account_Name"
    SEND_BUTTON_FOOTER: str = "mainWallet_Footer_Send_Button"
    SAVED_ADDRESSES_BUTTON: str = "mainWallet_Saved_Addresses_Button"

class SavedAddressesScreen(Enum):
    ADD_BUTTON: str = "mainWallet_Saved_Addreses_Add_Buttton"
    SAVED_ADDRESSES_LIST: str = "mainWallet_Saved_Addreses_List"
    
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
    SEED_PHRASE_INPUT_0: str = "mainWindow_Add_Account_Popup_Seed_Phrase_0"
    SEED_PHRASE_INPUT_1: str = "mainWindow_Add_Account_Popup_Seed_Phrase_1"
    SEED_PHRASE_INPUT_2: str = "mainWindow_Add_Account_Popup_Seed_Phrase_2"
    SEED_PHRASE_INPUT_3: str = "mainWindow_Add_Account_Popup_Seed_Phrase_3"
    SEED_PHRASE_INPUT_4: str = "mainWindow_Add_Account_Popup_Seed_Phrase_4"
    SEED_PHRASE_INPUT_5: str = "mainWindow_Add_Account_Popup_Seed_Phrase_5"
    SEED_PHRASE_INPUT_6: str = "mainWindow_Add_Account_Popup_Seed_Phrase_6"
    SEED_PHRASE_INPUT_7: str = "mainWindow_Add_Account_Popup_Seed_Phrase_7"
    SEED_PHRASE_INPUT_8: str = "mainWindow_Add_Account_Popup_Seed_Phrase_8"
    SEED_PHRASE_INPUT_9: str = "mainWindow_Add_Account_Popup_Seed_Phrase_9"
    SEED_PHRASE_INPUT_10: str = "mainWindow_Add_Account_Popup_Seed_Phrase_10"
    SEED_PHRASE_INPUT_11: str = "mainWindow_Add_Account_Popup_Seed_Phrase_11"


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
        time.sleep(2)

        scroll_obj_by_name(AddAccountPopup.SCROLL_BAR.value)
        time.sleep(2)

        scroll_obj_by_name(AddAccountPopup.SCROLL_BAR.value)
        time.sleep(2)

        type(AddAccountPopup.SEED_PHRASE_INPUT_0.value, words[0])
        type(AddAccountPopup.SEED_PHRASE_INPUT_1.value, words[1])
        type(AddAccountPopup.SEED_PHRASE_INPUT_2.value, words[2])
        type(AddAccountPopup.SEED_PHRASE_INPUT_3.value, words[3])
        type(AddAccountPopup.SEED_PHRASE_INPUT_4.value, words[4])
        type(AddAccountPopup.SEED_PHRASE_INPUT_5.value, words[5])
        type(AddAccountPopup.SEED_PHRASE_INPUT_6.value, words[6])
        type(AddAccountPopup.SEED_PHRASE_INPUT_7.value, words[7])
        type(AddAccountPopup.SEED_PHRASE_INPUT_8.value, words[8])
        type(AddAccountPopup.SEED_PHRASE_INPUT_9.value, words[9])
        type(AddAccountPopup.SEED_PHRASE_INPUT_10.value, words[10])
        type(AddAccountPopup.SEED_PHRASE_INPUT_11.value, words[11])
        time.sleep(2)
        
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
    
    def verify_saved_address_exists(self, name: str):
        list = get_obj(SavedAddressesScreen.SAVED_ADDRESSES_LIST.value)
        for index in range(list.count):
            if list.itemAtIndex(index).objectName == name:
                return  
    
        assert False, "no saved address found"

    def verify_transaction(self):
        print("TODO: fix notification and ensure there is one")
