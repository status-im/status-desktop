from ast import Tuple
from enum import Enum
import time
import os
import sys
from common.SeedUtils import *
from .StatusMainScreen import StatusMainScreen
from .StatusMainScreen import authenticatePopupEnterPassword
from drivers.SquishDriver import type_text as type_text

class Tokens(Enum):
    ETH: str = "ETH"

class SigningPhrasePopUp(Enum):
    OK_GOT_IT_BUTTON: str = "signPhrase_Ok_Button"

class MainWalletScreen(Enum):
    ADD_ACCOUNT_BUTTON: str = "mainWallet_Add_Account_Button"
    ACCOUNT_NAME: str = "mainWallet_Account_Name"
    ACCOUNT_ADDRESS_PANEL: str = "mainWallet_Address_Panel"
    SEND_BUTTON_FOOTER: str = "mainWallet_Footer_Send_Button"
    SAVED_ADDRESSES_BUTTON: str = "mainWallet_Saved_Addresses_Button"
    NETWORK_SELECTOR_BUTTON: str = "mainWallet_Network_Selector_Button"
    RIGHT_SIDE_TABBAR: str = "mainWallet_Right_Side_Tab_Bar"
    FIRST_ACCOUNT_ITEM: str = "firstWalletAccount_Item"
    EPHEMERAL_NOTIFICATION_LIST: str = "mainWallet_Ephemeral_Notification_List"
    TOTAL_CURRENCY_BALANCE: str = "mainWallet_totalCurrencyBalance"

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
    ADDRESS_INPUT_PLACEHOLDER: str = "mainWallet_Add_Account_Popup_Watch_Only_Address_Placeholder"
    PRIVATE_KEY_INPUT: str = "mainWallet_Add_Account_Popup_Private_Key"
    ADD_ACCOUNT_BUTTON: str = "mainWallet_Add_Account_Popup_Footer_Add_Account"
    SEED_PHRASE_INPUT_TEMPLATE: str = "mainWindow_Add_Account_Popup_Seed_Phrase_"
    SEED_PHRASE_INPUT_LAST: str = "mainWindow_Add_Account_Popup_Seed_Phrase_12"
    FULLY_CUSTOM_PATH_CHECKBOX: str = "mainWallet_Add_Account_Popup_Advanced_Accept_Responsibility_Checkbox"
    ADD_ACCOUNT_POPUP_ROOT: str = "mainWallet_Add_Account_Popup_Root"

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

    def add_watch_only_account(self, account_name: str, address: str, password: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)

        type_text(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        click_obj_by_name(AddAccountPopup.ADVANCE_SECTION.value, 2000)

        # Found that all the involved controls are switching availability states very quickly based on the model data
        # which makes it almost impossible to do a reliable check for different states, hence the retry for 10 seconds
        # workaround.
        # TODO remove workaround to retry after add account modal refactoring
        max_expected_step_duration_ms = 10000
        def scroll_and_type_fn():
            try:
                click_obj_by_name(AddAccountPopup.TYPE_SELECTOR.value)
                click_obj_by_name(AddAccountPopup.TYPE_WATCH_ONLY.value)

                scroll_item_until_item_is_visible(AddAccountPopup.SCROLL_BAR.value, AddAccountPopup.ADDRESS_INPUT_PLACEHOLDER.value, 2000)
                wait_for_object_and_type(AddAccountPopup.ADDRESS_INPUT_PLACEHOLDER.value, address)
            except Exception as e:
                log(f"Expected fail, ignore it for {max_expected_step_duration_ms/1000} seconds; exception {str(e)}")

        do_until_validation_with_timeout(
            scroll_and_type_fn,
            lambda: is_loaded_visible_and_enabled(AddAccountPopup.ADDRESS_INPUT.value, 500)[0],
            timeout_ms=max_expected_step_duration_ms,
            message="Fill watch only account address")

        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value, 2000)

    def import_private_key(self, account_name: str, password: str, private_key: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)

        type_text(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        click_obj_by_name(AddAccountPopup.ADVANCE_SECTION.value)
        click_obj_by_name(AddAccountPopup.TYPE_SELECTOR.value)
        click_obj_by_name(AddAccountPopup.TYPE_PRIVATE_KEY.value)

        scroll_item_until_item_is_visible(AddAccountPopup.SCROLL_BAR.value, AddAccountPopup.PRIVATE_KEY_INPUT.value)
        type_text(AddAccountPopup.PRIVATE_KEY_INPUT.value, private_key)

        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)

        authenticatePopupEnterPassword(password)

    def import_seed_phrase(self, account_name: str, password: str, mnemonic: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)

        type_text(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        click_obj_by_name(AddAccountPopup.ADVANCE_SECTION.value)
        click_obj_by_name(AddAccountPopup.TYPE_SELECTOR.value)
        click_obj_by_name(AddAccountPopup.TYPE_SEED_PHRASE.value)

        is_loaded_visible_and_enabled(AddAccountPopup.SCROLL_BAR.value, 1000)
        scroll_item_until_item_is_visible(AddAccountPopup.SCROLL_BAR.value, AddAccountPopup.SEED_PHRASE_INPUT_LAST.value)

        words = mnemonic.split()
        input_seed_phrase(AddAccountPopup.SEED_PHRASE_INPUT_TEMPLATE.value, words)

        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)

        authenticatePopupEnterPassword(password)

    def generate_new_account(self, account_name: str, password: str):
        click_obj_by_name(MainWalletScreen.ADD_ACCOUNT_BUTTON.value)

        type_text(AddAccountPopup.ACCOUNT_NAME_INPUT.value, account_name)

        click_obj_by_name(AddAccountPopup.ADD_ACCOUNT_BUTTON.value)

        authenticatePopupEnterPassword(password)

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

        authenticatePopupEnterPassword(password)

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
        type_text(AddSavedAddressPopup.ADDRESS_INPUT.value, address)
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
        obj = get_child_item_with_object_name(item, SavedAddressesScreen.DELEGATE_MENU_BUTTON_OBJECT_NAME.value)
        click_obj(obj)

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
        favouriteButton = get_child_item_with_object_name(item, SavedAddressesScreen.DELEGATE_FAVOURITE_BUTTON_OBJECT_NAME.value)
        click_obj(favouriteButton)

    def check_favourite_status_for_saved_address(self, name: str, favourite: bool):
        # Find the saved address
        item = self._get_saved_address_delegate_item(name)
        favouriteButton = get_child_item_with_object_name(item, SavedAddressesScreen.DELEGATE_FAVOURITE_BUTTON_OBJECT_NAME.value)

        # if favourite is true, check that the favourite shows "unfavourite" icon and vice versa
        wait_for_prop_value(favouriteButton, "icon.name", ("unfavourite" if favourite else "favourite"))
        wait_for_prop_value(item, "titleTextIcon", ("star-icon" if favourite else ""))

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

    def click_first_account(self):
        click_obj_by_name(MainWalletScreen.FIRST_ACCOUNT_ITEM.value)


    #####################################
    ### Verifications region:
    #####################################

    def verify_account_name_is_present(self, account_name: str):
        # Wait 2 second for UI text to update
        test.verify(wait_for_text_matching(MainWalletScreen.ACCOUNT_NAME.value, account_name, 2000), "Account name was updated and matches expected")

    def verify_account_balance_is_positive(self, list, symbol: str) -> Tuple(bool, ):
        if list is None:
            return (False, )

        for index in range(list.count):
            tokenListItem = list.itemAtIndex(index)
            if tokenListItem != None and tokenListItem.objectName == "AssetView_TokenListItem_" + symbol and tokenListItem.balance != "0":
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

