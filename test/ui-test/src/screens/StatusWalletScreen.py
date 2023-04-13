from ast import Tuple
from enum import Enum
import time
import os
import sys
import common.Common as common
from common.SeedUtils import *
from .StatusMainScreen import StatusMainScreen
from .StatusMainScreen import authenticate_popup_enter_password
from .SettingsScreen import SidebarComponents
from drivers.SquishDriver import type_text as type_text

NOT_APPLICABLE = "N/A"
VALUE_YES = "yes"
VALUE_NO = "no"

class Tokens(Enum):
    ETH: str = "ETH"

class SigningPhrasePopUp(Enum):
    OK_GOT_IT_BUTTON: str = "signPhrase_Ok_Button"

class MainWalletScreen(Enum):
    WALLET_LEFT_TAB: str = "mainWallet_LeftTab"
    ADD_ACCOUNT_BUTTON: str = "mainWallet_Add_Account_Button"
    ACCOUNT_NAME: str = "mainWallet_Account_Name"
    ACCOUNT_ADDRESS_PANEL: str = "mainWallet_Address_Panel"
    SEND_BUTTON_FOOTER: str = "mainWallet_Footer_Send_Button"
    SAVED_ADDRESSES_BUTTON: str = "mainWallet_Saved_Addresses_Button"
    NETWORK_SELECTOR_BUTTON: str = "mainWallet_Network_Selector_Button"
    RIGHT_SIDE_TABBAR: str = "mainWallet_Right_Side_Tab_Bar"
    WALLET_ACCOUNTS_LIST: str = "walletAccounts_StatusListView"
    WALLET_ACCOUNT_ITEM_PLACEHOLDER = "walletAccounts_WalletAccountItem_Placeholder"
    EPHEMERAL_NOTIFICATION_LIST: str = "mainWallet_Ephemeral_Notification_List"
    TOTAL_CURRENCY_BALANCE: str = "mainWallet_totalCurrencyBalance"
    
class MainWalletRightClickMenu(Enum):
    COPY_ADDRESS_ACTION_PLACEHOLDER: str = "mainWallet_RightClick_CopyAddress_MenuItem_Placeholder"
    EDIT_ACCOUNT_ACTION_PLACEHOLDER: str = "mainWallet_RightClick_EditAccount_MenuItem_Placeholder"
    DELETE_ACCOUNT_ACTION_PLACEHOLDER: str = "mainWallet_RightClick_DeleteAccount_MenuItem_Placeholder"
    ADD_NEW_ACCOUNT_ACTION_PLACEHOLDER: str = "mainWallet_RightClick_AddNewAccount_MenuItem_Placeholder"
    ADD_WATCH_ONLY_ACCOUNT_ACTION_PLACEHOLDER: str = "mainWallet_RightClick_AddWatchOnlyAccount_MenuItem_Placeholder"

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
    DELEGATE_MENU_BUTTON_OBJECT_NAME: str = "savedAddressView_Delegate_menuButton"
    DELEGATE_FAVOURITE_BUTTON_OBJECT_NAME: str = "savedAddressView_Delegate_favouriteButton"

class AddSavedAddressPopup(Enum):
    NAME_INPUT: str = "mainWallet_Saved_Addreses_Popup_Name_Input"
    ADDRESS_INPUT: str = "mainWallet_Saved_Addreses_Popup_Address_Input"
    ADDRESS_INPUT_EDIT: str = "mainWallet_Saved_Addreses_Popup_Address_Input_Edit"
    ADD_BUTTON: str = "mainWallet_Saved_Addreses_Popup_Address_Add_Button"

class SendPopup(Enum):
    SCROLL_BAR: str = "mainWallet_Send_Popup_Main"
    HEADER_ACCOUNTS_LIST: str = "mainWallet_Send_Popup_Header_Accounts"
    AMOUNT_INPUT: str = "mainWallet_Send_Popup_Amount_Input"
    MY_ACCOUNTS_TAB: str = "mainWallet_Send_Popup_My_Accounts_Tab"
    MY_ACCOUNTS_LIST: str = "mainWallet_Send_Popup_My_Accounts_List"
    NETWORKS_LIST: str = "mainWallet_Send_Popup_Networks_List"
    SEND_BUTTON: str = "mainWallet_Send_Popup_Send_Button"
    ASSET_SELECTOR: str = "mainWallet_Send_Popup_Asset_Selector"
    ASSET_LIST: str = "mainWallet_Send_Popup_Asset_List"
    HIGH_GAS_BUTTON: str = "mainWallet_Send_Popup_GasSelector_HighGas_Button"

class AddEditAccountPopup(Enum):
    CONTENT = "mainWallet_AddEditAccountPopup_Content"
    ACCOUNT_NAME = "mainWallet_AddEditAccountPopup_AccountName"
    ACCOUNT_COLOR_SELECTOR = "mainWallet_AddEditAccountPopup_AccountColorSelector"
    SELECTED_ORIGIN = "mainWallet_AddEditAccountPopup_SelectedOrigin"
    EMOJI_PUPUP_BUTTON = "mainWallet_AddEditAccountPopup_AccountEmojiPopupButton"
    EMOJI_PUPUP_SEARCH = "mainWallet_AddEditAccountPopup_AccountEmojiSearchBox"
    EMOJI_PUPUP_EMOJI = "mainWallet_AddEditAccountPopup_AccountEmoji"
    ORIGIN_OPTION_PLACEHOLDER = "mainWallet_AddEditAccountPopup_OriginOption_Placeholder"
    ORIGIN_OPTION_NEW_MASTER_KEY = "mainWallet_AddEditAccountPopup_OriginOptionNewMasterKey"
    ORIGIN_OPTION_WATCH_ONLY_ACC = "mainWallet_AddEditAccountPopup_OriginOptionWatchOnlyAcc"
    WATCH_ONLY_ADDRESS = "mainWallet_AddEditAccountPopup_AccountWatchOnlyAddress"
    PRIMARY_BUTTON = "mainWallet_AddEditAccountPopup_PrimaryButton"
    BACK_BUTTON = "mainWallet_AddEditAccountPopup_BackButton"
    EDIT_DERIVATION_PATH_BUTTON = "mainWallet_AddEditAccountPopup_EditDerivationPathButton"
    RESET_DERIVATION_PATH_BUTTON = "mainWallet_AddEditAccountPopup_ResetDerivationPathButton"
    DERIVATION_PATH = "mainWallet_AddEditAccountPopup_DerivationPathInput"
    PREDEFINED_DERIVATION_PATHS_BUTTON = "mainWallet_AddEditAccountPopup_PreDefinedDerivationPathsButton"
    PREDEFINED_TESTNET_ROPSTEN_PATH = "mainWallet_AddEditAccountPopup_PreDefinedPathsOptionTestnetRopsten"
    SELECTED_GENERATED_ADDRESS = "mainWallet_AddEditAccountPopup_GeneratedAddressComponent"
    GENERATED_ADDDRESS_99 = "mainWallet_AddEditAccountPopup_GeneratedAddress_99"
    GENERATED_ADDRESSES_PAGE_20 = "mainWallet_AddEditAccountPopup_PageIndicatorPage_20"
    NON_ETH_DERIVATION_PATH = "mainWallet_AddEditAccountPopup_NonEthDerivationPathCheckBox"
    MASTER_KEY_IMPORT_PRIVATE_KEY_OPTION = "mainWallet_AddEditAccountPopup_MasterKey_ImportPrivateKeyOption"
    MASTER_KEY_IMPORT_SEED_PHRASE_OPTION = "mainWallet_AddEditAccountPopup_MasterKey_ImportSeedPhraseOption"
    MASTER_KEY_GENERATE_SEED_PHRASE_OPTION = "mainWallet_AddEditAccountPopup_MasterKey_GenerateSeedPhraseOption"
    MASTER_KEY_GO_TO_KEYCARD_SETTINGS_OPTION = "mainWallet_AddEditAccountPopup_MasterKey_GoToKeycardSettingsOption"
    PRIVATE_KEY = "mainWallet_AddEditAccountPopup_PrivateKey"
    PRIVATE_KEY_KEY_NAME = "mainWallet_AddEditAccountPopup_PrivateKeyName"
    IMPORTED_SEED_PHRASE_KEY_NAME = "mainWallet_AddEditAccountPopup_ImportedSeedPhraseKeyName"
    GENERATED_SEED_PHRASE_KEY_NAME = "mainWallet_AddEditAccountPopup_GeneratedSeedPhraseKeyName"
    SEED_PHRASE_12_WORDS: str = "mainWallet_AddEditAccountPopup_12WordsButton"
    SEED_PHRASE_18_WORDS: str = "mainWallet_AddEditAccountPopup_18WordsButton"
    SEED_PHRASE_24_WORDS: str = "mainWallet_AddEditAccountPopup_24WordsButton"
    SEED_PHRASE_WORD_PATTERN: str = "mainWallet_AddEditAccountPopup_SPWord_"
    HAVE_PEN_AND_PAPER = "mainWallet_AddEditAccountPopup_HavePenAndPaperCheckBox"
    SEED_PHRASE_WRITTEN = "mainWallet_AddEditAccountPopup_SeedPhraseWrittenCheckBox"
    STORING_SEED_PHRASE_CONFIRMED = "mainWallet_AddEditAccountPopup_StoringSeedPhraseConfirmedCheckBox"
    SEED_BACKUP_ACKNOWLEDGE = "mainWallet_AddEditAccountPopup_SeedBackupAknowledgeCheckBox"
    REVEAL_SEED_PHRASE_BUTTON = "mainWallet_AddEditAccountPopup_RevealSeedPhraseButton"
    SEED_PHRASE_WORD_AT_INDEX_PLACEHOLDER = "mainWallet_AddEditAccountPopup_SeedPhraseWordAtIndex_Placeholder"
    ENTER_SEED_PHRASE_WORD_COMPONENT = "mainWallet_AddEditAccountPopup_EnterSeedPhraseWordComponent"
    ENTER_SEED_PHRASE_WORD = "mainWallet_AddEditAccountPopup_EnterSeedPhraseWord"

class RemoveAccountPopup(Enum):
    ACCOUNT_NOTIFICATION = "mainWallet_Remove_Account_Popup_Account_Notification"
    ACCOUNT_PATH = "mainWallet_Remove_Account_Popup_Account_Path"
    HAVE_PEN_PAPER = "mainWallet_Remove_Account_Popup_HavePenPaperCheckBox"
    CONFIRM_BUTTON = "mainWallet_Remove_Account_Popup_ConfirmButton"
    CANCEL_BUTTON = "mainWallet_Remove_Account_Popup_CancelButton"

class CollectiblesView(Enum):
    COLLECTIONS_REPEATER: str =  "mainWallet_Collections_Repeater"
    COLLECTIBLES_REPEATER: str =  "mainWallet_Collectibles_Repeater"

class WalletTabBar(Enum):
    ASSET_TAB =  0
    COLLECTION_TAB =  1
    ACTIVITY_TAB = 2

class TransactionsView(Enum):
    TRANSACTIONS_LISTVIEW: str =  "mainWallet_Transactions_List"
    TRANSACTIONS_DETAIL_VIEW_HEADER: str =  "mainWallet_Transactions_Detail_View_Header"

class StatusWalletScreen:

    #####################################
    ### Screen actions region:
    #####################################

    def accept_signing_phrase(self):
        click_obj_by_name(SigningPhrasePopUp.OK_GOT_IT_BUTTON.value)
        
    def open_add_account_popup(self):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)
        
    def add_account_popup_do_primary_action(self, password: str = NOT_APPLICABLE):
        click_obj_by_name(AddEditAccountPopup.PRIMARY_BUTTON.value)
        if password != NOT_APPLICABLE:
            authenticate_popup_enter_password(password)
            
    def add_account_popup_open_edit_derivation_path_section(self, password: str):
        click_obj_by_name(AddEditAccountPopup.EDIT_DERIVATION_PATH_BUTTON.value)
        authenticate_popup_enter_password(password)
        
    def add_account_popup_change_account_name(self, name: str):
        is_loaded_visible_and_enabled(AddEditAccountPopup.ACCOUNT_NAME.value, 1000)
        setText(AddEditAccountPopup.ACCOUNT_NAME.value, name)
        
    def add_account_popup_change_account_color(self, color: str):
        colorList = get_obj(AddEditAccountPopup.ACCOUNT_COLOR_SELECTOR.value)
        for index in range(colorList.count):
            c = colorList.itemAt(index)
            if(c.radioButtonColor == color):
                click_obj(colorList.itemAt(index))
                
    def add_account_popup_change_origin(self, origin_object_name: str):
        click_obj_by_name(AddEditAccountPopup.SELECTED_ORIGIN.value)
        click_obj_by_name(origin_object_name)
        
    def add_account_popup_change_origin_by_keypair_name(self, keypair_name):
        click_obj_by_name(AddEditAccountPopup.SELECTED_ORIGIN.value)
        originObj = wait_by_wildcards(AddEditAccountPopup.ORIGIN_OPTION_PLACEHOLDER.value, "%NAME%", keypair_name)
        click_obj(originObj)

    def add_account_popup_change_derivation_path(self, index: str, order: str, is_ethereum_root: str):
        # initially we set derivation path to other than default eth path, in order to test reset button functionality 
        click_obj_by_name(AddEditAccountPopup.PREDEFINED_DERIVATION_PATHS_BUTTON.value)
        hover_and_click_object_by_name(AddEditAccountPopup.PREDEFINED_TESTNET_ROPSTEN_PATH.value)
        if is_ethereum_root == VALUE_YES:
            click_obj_by_name(AddEditAccountPopup.RESET_DERIVATION_PATH_BUTTON.value)
        else:
            scroll_item_until_item_is_visible(AddEditAccountPopup.CONTENT.value, AddEditAccountPopup.NON_ETH_DERIVATION_PATH.value)
            click_obj_by_name(AddEditAccountPopup.NON_ETH_DERIVATION_PATH.value)

        [compLoaded, selectedAccount] = is_loaded(AddEditAccountPopup.SELECTED_GENERATED_ADDRESS.value)
        if not compLoaded:
            verify_failure("cannot find selected address")
            return 

        if index != NOT_APPLICABLE or order != NOT_APPLICABLE:
            click_obj_by_name(AddEditAccountPopup.DERIVATION_PATH.value)
            common.clear_input_text(AddEditAccountPopup.DERIVATION_PATH.value)
            if index != NOT_APPLICABLE:
                type_text(AddEditAccountPopup.DERIVATION_PATH.value, index)
            elif order != NOT_APPLICABLE:
                do_until_validation_with_timeout(
                    lambda: time.sleep(0.5), 
                    lambda: not selectedAccount.loading, 
                    "generating addresses to offer after path is cleared", 
                    5000)
                click_obj(selectedAccount)
                is_loaded_visible_and_enabled(AddEditAccountPopup.GENERATED_ADDRESSES_PAGE_20.value)
                click_obj_by_name(AddEditAccountPopup.GENERATED_ADDRESSES_PAGE_20.value)
                is_loaded_visible_and_enabled(AddEditAccountPopup.GENERATED_ADDDRESS_99.value)
                click_obj_by_name(AddEditAccountPopup.GENERATED_ADDDRESS_99.value)

        do_until_validation_with_timeout(
          lambda: time.sleep(0.5), 
          lambda: not selectedAccount.loading, 
          "resolving an address after path is finally chosen", 
          5000)
        
    def add_account_popup_change_account_emoji(self, emoji: str):
        click_obj_by_name(AddEditAccountPopup.EMOJI_PUPUP_BUTTON.value)
        wait_for_object_and_type(AddEditAccountPopup.EMOJI_PUPUP_SEARCH.value, emoji)
        click_obj(wait_by_wildcards(AddEditAccountPopup.EMOJI_PUPUP_EMOJI.value, "%NAME%", "*"))
    
    def add_account_popup_set_watch_only_account_as_selected_origin(self, address: str):
        self.add_account_popup_change_origin(AddEditAccountPopup.ORIGIN_OPTION_WATCH_ONLY_ACC.value)
        wait_for_object_and_type(AddEditAccountPopup.WATCH_ONLY_ADDRESS.value, address)
        
    def add_account_popup_set_new_private_key_as_selected_origin(self, private_key: str, keypair_name: str):
        self.add_account_popup_change_origin(AddEditAccountPopup.ORIGIN_OPTION_NEW_MASTER_KEY.value)
        is_loaded_visible_and_enabled(AddEditAccountPopup.MASTER_KEY_IMPORT_PRIVATE_KEY_OPTION.value)
        click_obj_by_name(AddEditAccountPopup.MASTER_KEY_IMPORT_PRIVATE_KEY_OPTION.value)
        type_text(AddEditAccountPopup.PRIVATE_KEY.value, private_key)
        wait_for_object_and_type(AddEditAccountPopup.PRIVATE_KEY_KEY_NAME.value, keypair_name)
        self.add_account_popup_do_primary_action()
        
    def add_account_popup_set_new_seed_phrase_as_selected_origin(self, seed_phrase: str, keypair_name: str):
        self.add_account_popup_change_origin(AddEditAccountPopup.ORIGIN_OPTION_NEW_MASTER_KEY.value)
        is_loaded_visible_and_enabled(AddEditAccountPopup.MASTER_KEY_IMPORT_SEED_PHRASE_OPTION.value)
        click_obj_by_name(AddEditAccountPopup.MASTER_KEY_IMPORT_SEED_PHRASE_OPTION.value)
        sp_words = seed_phrase.split()
        if len(sp_words) == 12:
            click_obj_by_name(AddEditAccountPopup.SEED_PHRASE_12_WORDS.value)
        elif len(sp_words) == 18:
            click_obj_by_name(AddEditAccountPopup.SEED_PHRASE_18_WORDS.value)
        elif len(sp_words) == 24:
            click_obj_by_name(AddEditAccountPopup.SEED_PHRASE_24_WORDS.value)
        else:
            test.fail("Wrong amount of seed words", len(words))
        input_seed_phrase(AddEditAccountPopup.SEED_PHRASE_WORD_PATTERN.value, sp_words)
        wait_for_object_and_type(AddEditAccountPopup.IMPORTED_SEED_PHRASE_KEY_NAME.value, keypair_name)
        self.add_account_popup_do_primary_action()
        
    def add_account_popup_set_generated_seed_phrase_as_selected_origin(self, keypair_name: str):
        self.add_account_popup_change_origin(AddEditAccountPopup.ORIGIN_OPTION_NEW_MASTER_KEY.value)
        is_loaded_visible_and_enabled(AddEditAccountPopup.MASTER_KEY_IMPORT_SEED_PHRASE_OPTION.value)
        click_obj_by_name(AddEditAccountPopup.MASTER_KEY_GENERATE_SEED_PHRASE_OPTION.value)
        
        click_obj_by_name(AddEditAccountPopup.HAVE_PEN_AND_PAPER.value)
        click_obj_by_name(AddEditAccountPopup.SEED_PHRASE_WRITTEN.value)
        click_obj_by_name(AddEditAccountPopup.STORING_SEED_PHRASE_CONFIRMED.value)
        self.add_account_popup_do_primary_action()
        
        click_obj_by_name(AddEditAccountPopup.REVEAL_SEED_PHRASE_BUTTON.value)
        seed_phrase = [wait_by_wildcards(AddEditAccountPopup.SEED_PHRASE_WORD_AT_INDEX_PLACEHOLDER.value, "%WORD-INDEX%", str(i + 1)).textEdit.input.edit.text for i in range(12)]
        self.add_account_popup_do_primary_action()
        
        enterWordObj = wait_and_get_obj(AddEditAccountPopup.ENTER_SEED_PHRASE_WORD_COMPONENT.value)
        label = str(enterWordObj.label)
        index = int(label[len("Word #"):len(label)]) - 1
        wordToEnter = str(seed_phrase[index])
        wait_for_object_and_type(AddEditAccountPopup.ENTER_SEED_PHRASE_WORD.value, wordToEnter)
        self.add_account_popup_do_primary_action()
        
        enterWordObj = wait_and_get_obj(AddEditAccountPopup.ENTER_SEED_PHRASE_WORD_COMPONENT.value)
        label = str(enterWordObj.label)
        index = int(label[len("Word #"):len(label)]) - 1
        wordToEnter = str(seed_phrase[index])
        wait_for_object_and_type(AddEditAccountPopup.ENTER_SEED_PHRASE_WORD.value, wordToEnter)
        self.add_account_popup_do_primary_action()
        
        click_obj_by_name(AddEditAccountPopup.SEED_BACKUP_ACKNOWLEDGE.value)
        self.add_account_popup_do_primary_action()
                          
        wait_for_object_and_type(AddEditAccountPopup.GENERATED_SEED_PHRASE_KEY_NAME.value, keypair_name)
        self.add_account_popup_do_primary_action()
        
    def add_account_popup_go_to_keycard_settings(self):
        self.add_account_popup_change_origin(AddEditAccountPopup.ORIGIN_OPTION_NEW_MASTER_KEY.value)
        is_loaded_visible_and_enabled(AddEditAccountPopup.MASTER_KEY_GO_TO_KEYCARD_SETTINGS_OPTION.value)
        click_obj_by_name(AddEditAccountPopup.MASTER_KEY_GO_TO_KEYCARD_SETTINGS_OPTION.value)
        
    def remove_account_popup_do_cancel_action(self):
        click_obj_by_name(RemoveAccountPopup.CANCEL_BUTTON.value)
        
    def remove_account_popup_do_remove_action(self, confirmHavingPenAndPaper, password: str):
        if confirmHavingPenAndPaper:
            click_obj_by_name(RemoveAccountPopup.HAVE_PEN_PAPER.value)
        click_obj_by_name(RemoveAccountPopup.CONFIRM_BUTTON.value)
        if password != NOT_APPLICABLE:
            authenticate_popup_enter_password(password)        
        
    def click_option_from_left_part_right_click_menu(self, option: str):
        right_click_obj_by_name(MainWalletScreen.WALLET_LEFT_TAB.value)
        optionObj = wait_by_wildcards(option, "%NAME%", "wallet-background")
        hover_obj(optionObj)
        click_obj(optionObj)
        
    def click_option_from_right_click_menu_of_account_with_name(self, option: str, name: str):
        time.sleep(2)
        ##########################################
        # Sometimes this function fails to open right click menu on form the wallet account item, 
        # or because of missed option from the right click menu
        #
        # NEEDS SOME INSPECTION WHAT'S REALLY HAPPENING
        #
        ##########################################
         
        # OPTION-1
        # accounts = wait_and_get_obj(MainWalletScreen.WALLET_ACCOUNTS_LIST.value)
        # for index in range(accounts.count):
        #     accountObj = accounts.itemAtIndex(index)
        #     if(accountObj.objectName == "walletAccount-" + name):
        #         right_click_obj(accountObj)
        #         do_until_validation_with_timeout(
        #             lambda: time.sleep(1), 
        #             lambda: accountObj.itemLoaded,
        #             "loading address", 
        #             5000)
        #         optionObj = wait_by_wildcards(option, "%NAME%", name)
        #         hover_obj(optionObj)
        #         click_obj(optionObj)
        #         return
        
        # OPTION-2
        accountObj = wait_by_wildcards(MainWalletScreen.WALLET_ACCOUNT_ITEM_PLACEHOLDER.value, "%NAME%", name)
        if accountObj is None:
            objName = copy.deepcopy(getattr(names, MainWalletScreen.WALLET_ACCOUNT_ITEM_PLACEHOLDER.value))
            realObjName = objName["objectName"].replace("%NAME%", name)
            [compLoaded, accountObj] = is_loaded_visible_and_enabled(realObjName)
            if not compLoaded:
                verify_failure("cannot find wallet account component with objectName = " + realObjName)
                return
        if accountObj is None:
            verify_failure("cannot find wallet account component with name = " + name)
            return
        do_until_validation_with_timeout(
            lambda: time.sleep(0.5), 
            lambda: false if accountObj is None else accountObj.itemLoaded,
            "loading address", 
            5000)
        right_click_obj(accountObj)
        time.sleep(1)
        optionObj = wait_by_wildcards(option, "%NAME%", name)
        if optionObj is None:
            verify_failure("cannot find option in wallet account right click menu with name = " + name)
            return
        hover_obj(optionObj)
        click_obj(optionObj)
    
    def send_transaction(self, account_name, amount, token, chain_name, password):
        is_loaded_visible_and_enabled(AssetView.LIST.value, 2000)
        list = get_obj(AssetView.LIST.value)
        # LoadingTokenDelegate will be visible until the balance is loaded verify_account_balance_is_positive checks for TokenDelegate
        do_until_validation_with_timeout(lambda: time.sleep(0.1), lambda: self.verify_account_balance_is_positive(list, "ETH")[0], "Wait for tokens to load", 10000)

        click_obj_by_name(MainWalletScreen.SEND_BUTTON_FOOTER.value)

        self._click_repeater(SendPopup.HEADER_ACCOUNTS_LIST.value, account_name)
        is_loaded_visible_and_enabled(SendPopup.AMOUNT_INPUT.value, 1000)
        type_text(SendPopup.AMOUNT_INPUT.value, amount)

        click_obj_by_name(SendPopup.ASSET_SELECTOR.value)
        asset_list = get_obj(SendPopup.ASSET_LIST.value)
        for index in range(asset_list.count):
            tokenObj = asset_list.itemAtIndex(index)
            if(not is_null(tokenObj) and tokenObj.objectName == "AssetSelector_ItemDelegate_" + token):
                click_obj(asset_list.itemAtIndex(index))
                break

        click_obj_by_name(SendPopup.MY_ACCOUNTS_TAB.value)

        accounts = get_obj(SendPopup.MY_ACCOUNTS_LIST.value)
        for index in range(accounts.count):
            if(accounts.itemAtIndex(index).objectName == account_name):
                print("WE FOUND THE ACCOUNT")
                click_obj(accounts.itemAtIndex(index))
                break

        scroll_obj_by_name(SendPopup.SCROLL_BAR.value)

        click_obj_by_name(SendPopup.SEND_BUTTON.value)

        authenticate_popup_enter_password(password)

    def _click_repeater(self, repeater_object_name: str, object_name: str):
        repeater = get_obj(repeater_object_name)
        for index in range(repeater.count):
            if(repeater.itemAt(index).objectName == object_name):
                click_obj(repeater.itemAt(index))
                break

    def add_saved_address(self, name: str, address: str):
        click_obj_by_name(MainWalletScreen.SAVED_ADDRESSES_BUTTON.value)
        click_obj_by_name(SavedAddressesScreen.ADD_BUTTON.value)
        type_text(AddSavedAddressPopup.NAME_INPUT.value, name)

        type_text(AddSavedAddressPopup.ADDRESS_INPUT_EDIT.value, address)
        addressInput = get_obj(AddSavedAddressPopup.ADDRESS_INPUT.value)
        verify_equal(addressInput.plainText, address)
        is_loaded_visible_and_enabled(AddSavedAddressPopup.ADD_BUTTON.value)
        click_obj_by_name(AddSavedAddressPopup.ADD_BUTTON.value)

    def _get_saved_address_delegate_item(self, name: str):
        list = wait_and_get_obj(SavedAddressesScreen.SAVED_ADDRESSES_LIST.value)
        found = -1
        for index in range(list.count):
            if list.itemAtIndex(index).objectName == f"savedAddressView_Delegate_{name}":
                found = index

        assert found != -1, "saved address not found"
        return list.itemAtIndex(found)

    def _find_saved_address_and_open_menu(self, name: str):
        item = self._get_saved_address_delegate_item(name)
        menuButton = get_child_item_with_object_name(item, f"{SavedAddressesScreen.DELEGATE_MENU_BUTTON_OBJECT_NAME.value}_{name}")
        is_object_loaded_visible_and_enabled(menuButton)
        click_obj(menuButton)

    def edit_saved_address(self, name: str, new_name: str):
        self._find_saved_address_and_open_menu(name)

        click_obj_by_name(SavedAddressesScreen.EDIT.value)
        type_text(AddSavedAddressPopup.NAME_INPUT.value, new_name)
        click_obj_by_name(AddSavedAddressPopup.ADD_BUTTON.value)

    def delete_saved_address(self, name: str):
        self._find_saved_address_and_open_menu(name)

        click_obj_by_name(SavedAddressesScreen.DELETE.value)
        click_obj_by_name(SavedAddressesScreen.CONFIRM_DELETE.value)

    def toggle_favourite_for_saved_address(self, name: str):
        # Find the saved address and click favourite to toggle
        item = self._get_saved_address_delegate_item(name)
        favouriteButton = item.statusListItemIcon
        is_object_loaded_visible_and_enabled(favouriteButton)
        click_obj(favouriteButton)

    def check_favourite_status_for_saved_address(self, name: str, favourite: bool):
        # Find the saved address
        item = self._get_saved_address_delegate_item(name)
        favouriteButton = item.statusListItemIcon
        wait_for_prop_value(favouriteButton, "asset.name", ("star-icon" if favourite else "favourite"))

    def toggle_network(self, network_name: str):
        is_loaded_visible_and_enabled(MainWalletScreen.NETWORK_SELECTOR_BUTTON.value, 2000)
        click_obj_by_name(MainWalletScreen.NETWORK_SELECTOR_BUTTON.value)

        is_loaded_visible_and_enabled(NetworkSelectorPopup.LAYER_1_REPEATER.value, 2000)
        list = wait_and_get_obj(NetworkSelectorPopup.LAYER_1_REPEATER.value)
        for index in range(list.count):
            item = list.itemAt(index)
            if item.objectName == network_name:
                click_obj(item)
                click_obj_by_name(MainWalletScreen.ACCOUNT_NAME.value)
                return

        assert False, "network name not found"
    
    def click_default_wallet_account(self):
        accounts = get_obj(MainWalletScreen.WALLET_ACCOUNTS_LIST.value)
        click_obj(accounts.itemAtIndex(0))
        
    def click_wallet_account(self, account_name: str):
        accounts = get_obj(MainWalletScreen.WALLET_ACCOUNTS_LIST.value)
        for index in range(accounts.count):
            if(accounts.itemAtIndex(index).objectName == "walletAccount-" + account_name):
                click_obj(accounts.itemAtIndex(index))
                return
    
    
    #####################################
    ### Verifications region:
    #####################################
    def remove_account_popup_verify_account_account_to_be_removed(self, name: str, path: str):
        objNotification = wait_and_get_obj(RemoveAccountPopup.ACCOUNT_NOTIFICATION.value)
        displayedNotification = str(objNotification.text)
        if name not in displayedNotification: 
            verify_failure("Remove account popup doesn't refer to an account with name: " + name)
        if path != NOT_APPLICABLE:
            objPath = get_obj(RemoveAccountPopup.ACCOUNT_PATH.value)
            if path != objPath.text:
                verify_failure("Remove account popup doesn't refer to an account with path: " + path)
        
    def verify_account_existence(self, name: str, color: str, emoji_unicode: str):
        [compLoaded, accNameObj] = is_loaded_visible_and_enabled(MainWalletScreen.ACCOUNT_NAME.value)
        if not compLoaded:
            verify_failure("cannot find account name on the right, most likely the account we're searching for is not selected")
            return
        do_until_validation_with_timeout(
          lambda: time.sleep(0.5), 
          lambda: accNameObj.text == name, 
          "selected account match", 
          5000)

        is_loaded_visible_and_enabled(MainWalletScreen.WALLET_ACCOUNTS_LIST.value)
        accounts = get_obj(MainWalletScreen.WALLET_ACCOUNTS_LIST.value)
        for index in range(accounts.count):
            acc = accounts.itemAtIndex(index)
            if(acc.objectName == "walletAccount-" + name):
                verify_equal(str(acc.title), name, "Account displays the expected name")
                verify_equal(str(acc.asset.color.name), str(color.lower()), "Account displays the expected color")
                verify_equal((True if emoji_unicode in str(acc.asset.emoji) else False), True, "Account displays the expected emoji")
                return
    
    def verify_account_doesnt_exist(self, name: str):
        is_loaded_visible_and_enabled(MainWalletScreen.WALLET_ACCOUNTS_LIST.value)
        accounts = get_obj(MainWalletScreen.WALLET_ACCOUNTS_LIST.value)
        for index in range(accounts.count):
            acc = accounts.itemAtIndex(index)
            if(acc.objectName == "walletAccount-" + name):
                verify_failure("Account with " + name + " is still displayed even it should not be")
    
    def verify_keycard_settings_is_opened(self):
        [compLoaded, accNameObj] = is_loaded_visible_and_enabled(SidebarComponents.KEYCARD_OPTION.value)
        if not compLoaded:
            verify_failure("keycard option from the app settings cannot be found")
            return
        verify(bool(accNameObj.selected), "keycard option from the app settings is displayed")
        
    def verify_account_balance_is_positive(self, list, symbol: str) -> Tuple(bool, ):
        if list is None:
            return (False, )

        for index in range(list.count):
            tokenListItem = list.itemAtIndex(index)
            if tokenListItem != None and tokenListItem.item != None and tokenListItem.item.objectName == "AssetView_LoadingTokenDelegate_"+str(index):
                return (False, )
            if tokenListItem != None and tokenListItem.item != None and tokenListItem.item.objectName == "AssetView_TokenListItem_" + symbol and tokenListItem.item.balance != "0":
                return (True, tokenListItem)
        return (False, )

    def verify_positive_balance(self, symbol: str):
        is_loaded_visible_and_enabled(AssetView.LIST.value, 5000)
        list = get_obj(AssetView.LIST.value)
        do_until_validation_with_timeout(lambda: time.sleep(0.1), lambda: self.verify_account_balance_is_positive(list, symbol)[0], "Symbol " + symbol + " not found in the asset list", 5000)

    def verify_saved_address_exists(self, name: str):
        list = wait_and_get_obj(SavedAddressesScreen.SAVED_ADDRESSES_LIST.value)
        for index in range(list.count):
            if list.itemAtIndex(index).objectName == f"savedAddressView_Delegate_{name}":
                return

        verify_failure(f'FAIL: saved address {name} not found"')

    def verify_saved_address_doesnt_exist(self, name: str):
        # The list should be hidden when there are no saved addresses
        try:
            list = wait_and_get_obj(SavedAddressesScreen.SAVED_ADDRESSES_LIST.value, 250)
        except LookupError:
            return

        list = wait_and_get_obj(SavedAddressesScreen.SAVED_ADDRESSES_LIST.value)
        for index in range(list.count):
            if list.itemAtIndex(index).objectName == f"savedAddressView_Delegate_{name}":
                verify_failure(f'FAIL: saved address {name} exists')

    def verify_transaction(self):
        pass
        # TODO: figure out why it doesn t work in CI
        # ephemeral_notification_list = get_obj(MainWalletScreen.EPHEMERAL_NOTIFICATION_LIST.value)
        # print(ephemeral_notification_list.itemAtIndex(0).objectName)
        # verify(str(ephemeral_notification_list.itemAtIndex(0).primaryText ) == "Transaction pending...", "Tx was not sent!")

    def verify_collectibles_exist(self, account_name: str):
        tabbar = get_obj(MainWalletScreen.RIGHT_SIDE_TABBAR.value)
        click_obj(tabbar.itemAt(WalletTabBar.COLLECTION_TAB.value))
        collectionsRepeater = get_obj(CollectiblesView.COLLECTIONS_REPEATER.value)
        if(collectionsRepeater.count > 0):
            collectionsRepeater.itemAt(0).expanded = True
        collectiblesRepeater = get_obj(CollectiblesView.COLLECTIBLES_REPEATER.value)
        verify(collectiblesRepeater.count > 0, "Collectibles not retrieved for the account")

    def verify_transactions_exist(self):
        tabbar = get_obj(MainWalletScreen.RIGHT_SIDE_TABBAR.value)
        click_obj(tabbar.itemAt(WalletTabBar.ACTIVITY_TAB.value))

        transaction_list_view = get_obj(TransactionsView.TRANSACTIONS_LISTVIEW.value)

        wait_for("transaction_list_view.count > 0", 60*1000)
        verify(transaction_list_view.count > 1, "Transactions not retrieved for the account")

        transaction_item = transaction_list_view.itemAtIndex(1)
        transaction_detail_header = get_obj(TransactionsView.TRANSACTIONS_DETAIL_VIEW_HEADER.value)

        click_obj(transaction_item)

        verify_equal(transaction_item.item.cryptoValue, transaction_detail_header.cryptoValue)
        verify_equal(transaction_item.item.transferStatus, transaction_detail_header.transferStatus)
        verify_equal(transaction_item.item.shortTimeStamp, transaction_detail_header.shortTimeStamp)
        verify_equal(transaction_item.item.fiatValue, transaction_detail_header.fiatValue)
        verify_equal(transaction_item.item.symbol, transaction_detail_header.symbol)

