from enum import Enum
import time
import sys
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


class SigningPhrasePopUp(Enum):
    OK_GOT_IT_BUTTON: str = "mainWindow_Ok_got_it_StatusBaseText"


class MainWalletScreen(Enum):
    ADD_ACCOUNT_BUTTON: str = "mainWallet_Add_Account"
    ACCOUNT_NAME: str = "mainWallet_Account_Name"

    
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
    
    def acceptSigningPhrase(self):
        click_obj_by_name(SigningPhrasePopUp.OK_GOT_IT_BUTTON.value)
        
    def addWatchOnlyAccount(self, account_name: str, address: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)
        
        type(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        click_obj_by_name(AddAccountPopup.ADVANCE_SECTION.value)
        click_obj_by_name(AddAccountPopup.TYPE_SELECTOR.value)
        time.sleep(1)
        click_obj_by_name(AddAccountPopup.TYPE_WATCH_ONLY.value)
        
        type(AddAccountPopup.ADDRESS_INPUT.value, address)
        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)

    def importPrivateKey(self, account_name: str, password: str, private_key: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)
        
        type(AddAccountPopup.PASSWORD_INPUT.value, password)
        type(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        click_obj_by_name(AddAccountPopup.ADVANCE_SECTION.value)
        click_obj_by_name(AddAccountPopup.TYPE_SELECTOR.value)
        time.sleep(1)
        click_obj_by_name(AddAccountPopup.TYPE_PRIVATE_KEY.value)
        
        type(AddAccountPopup.PRIVATE_KEY_INPUT.value, private_key)
        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)
    
    def importSeedPhrase(self, account_name: str, password: str, mnemonic: str):
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
        
    def generateNewAccount(self, account_name: str, password: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)
        
        type(AddAccountPopup.PASSWORD_INPUT.value, password)
        type(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        time.sleep(2)
        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)
         
    def verifyAccountNameIsPresent(self, account_name: str):
        verify_text_matching(MainWalletScreen.ACCOUNT_NAME.value, account_name)
        
