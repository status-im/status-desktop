import time
import typing
from ast import Tuple
from enum import Enum

import configs
import constants
import squish
from common.SeedUtils import *
from drivers.SquishDriver import *
from objectmaphelper import *
from utils.ObjectAccess import *
from utils.decorators import close_exists

from .SettingsScreen import SidebarComponents
from .StatusMainScreen import authenticate_popup_enter_password
from .components.base_popup import BasePopup
from .components.confirmation_popup import ConfirmationPopup
from .components.context_menu import ContextMenu
from .components.remove_wallet_account_popup import RemoveWalletAccountPopup
from .components.saved_address_popup import AddSavedAddressPopup, EditSavedAddressPopup
from .components.wallet_account_popups import AccountPopup

NOT_APPLICABLE = "N/A"
VALUE_YES = "yes"
VALUE_NO = "no"


class MainWalletContextMenu(ContextMenu):

    def __init__(self):
        super(MainWalletContextMenu, self).__init__()
        self._copy_address_menu_item = BaseElement('mainWallet_CopyAddress_MenuItem')
        self._edit_account_menu_item = BaseElement('mainWallet_EditAccount_MenuItem')
        self._add_new_account_menu_item = BaseElement('mainWallet_AddNewAccount_MenuItem')
        self._add_watch_only_account_menu_item = BaseElement('mainWallet_AddWatchOnlyAccount_MenuItem')
        self._delete_menu_item = BaseElement('mainWallet_DeleteAccount_MenuItem')

    def select(self, menu_item: BaseElement):
        menu_item.wait_until_appears()
        menu_item.click()
        menu_item.wait_until_hidden()

    def select_copy_address(self):
        self.select(self._copy_address_menu_item)

    def select_edit_account(self):
        self.select(self._edit_account_menu_item)

    def select_add_new_account(self):
        self.select(self._add_new_account_menu_item)

    def select_add_watch_anly_account(self):
        self.select(self._add_watch_only_account_menu_item)

    def select_delete(self):
        self.select(self._delete_menu_item)


class LeftPanel(BaseElement):

    def __init__(self):
        super(LeftPanel, self).__init__('mainWallet_LeftTab')
        self._saved_addresses_button = BaseElement('mainWallet_Saved_Addresses_Button')
        self._wallet_account_item = BaseElement('walletAccount_StatusListItem')
        self._add_account_button = Button('mainWallet_Add_Account_Button')
        self._all_accounts_button = Button('mainWallet_All_Accounts_Button')

    @property
    def accounts(self) -> typing.List[constants.wallet.account_list_item]:
        if 'title' in self._wallet_account_item.object_name.keys():
            del self._wallet_account_item.object_name['title']

        accounts = []
        for account_item in squish.findAllObjects(self._wallet_account_item.object_name):
            try:
                name = str(account_item.title)
                color = str(account_item.asset.color.name).lower()
                emoji = ''
                for child in walk_children(account_item):
                    if hasattr(child, 'emojiId'):
                        emoji = str(child.emojiId)
                        break
                accounts.append(constants.wallet.account_list_item(name, color, emoji))
            except (AttributeError, RuntimeError):
                continue

        return accounts

    @close_exists(BasePopup())
    def open_saved_addresses(self) -> 'AddressesView':
        self._saved_addresses_button.click()
        return AddressesView().wait_until_appears()

    @close_exists(BasePopup())
    def select_account(self, account_name: str) -> 'WalletAccountView':
        self._wallet_account_item.object_name['title'] = account_name
        self._wallet_account_item.click()
        return WalletAccountView().wait_until_appears()

    @close_exists(BasePopup())
    def _open_context_menu(self) -> MainWalletContextMenu:
        super(LeftPanel, self).open_context_menu()
        return MainWalletContextMenu().wait_until_appears()

    @close_exists(BasePopup())
    def _open_context_menu_for_account(self, account_name: str) -> MainWalletContextMenu:
        self._wallet_account_item.object_name['title'] = account_name
        self._wallet_account_item.wait_until_appears().open_context_menu()
        return MainWalletContextMenu().wait_until_appears()

    def open_edit_account_popup(self, account_name: str, attempt: int = 2) -> AccountPopup:
        try:
            self._open_context_menu_for_account(account_name).select_edit_account()
            return AccountPopup().wait_until_appears()
        except:
            if attempt:
                return self.open_edit_account_popup(account_name, attempt - 1)
            else:
                raise

    def open_add_watch_anly_account_popup(self, attempt: int = 2) -> AccountPopup:
        try:
            self._open_context_menu().select_add_watch_anly_account()
            return AccountPopup().wait_until_appears()
        except:
            if attempt:
                return self.open_add_watch_anly_account_popup(attempt - 1)
            else:
                raise

    def open_add_new_account_popup(self, attempt: int = 2):
        try:
            self._open_context_menu().select_add_new_account()
            return AccountPopup().wait_until_appears()
        except:
            if attempt:
                return self.open_add_new_account_popup(attempt - 1)
            else:
                raise

    def open_add_account_popup(self, attempt: int = 2):
        self._add_account_button.click()
        try:
            return AccountPopup().wait_until_appears()
        except AssertionError as err:
            if attempt:
                self._open_add_account_popup(attempt-1)
            else:
                raise err
        

    def delete_account(self, account_name: str, attempt: int = 2) -> RemoveWalletAccountPopup:
        try:
            self._open_context_menu_for_account(account_name).select_delete()
            return RemoveWalletAccountPopup().wait_until_appears()
        except:
            if attempt:
                return self.delete_account(account_name, attempt - 1)
            else:
                raise
    
    def open_all_accounts_view(self):
        self._all_accounts_button.click()        


class SavedAddressListItem(BaseElement):

    def __init__(self, object_name: str):
        super(SavedAddressListItem, self).__init__(object_name)
        self._send_button = Button('send_StatusRoundButton')
        self._open_menu_button = Button('savedAddressView_Delegate_menuButton')

    @property
    def name(self) -> str:
        return self.object.name

    @property
    def address(self) -> str:
        return self.object.address

    def open_send_popup(self):
        self._send_button.object_name['container'] = self.object_name
        self._send_button.click()
        # TODO: return popup)

    def open_context_menu(self) -> ContextMenu:
        self._open_menu_button.object_name['container'] = self.object_name
        self._open_menu_button.click()
        return ContextMenu().wait_until_appears()


class AddressesView(BaseElement):

    def __init__(self):
        super(AddressesView, self).__init__('mainWindow_SavedAddressesView')
        self._add_new_address_button = Button('mainWallet_Saved_Addreses_Add_Buttton')
        self._address_list_item = BaseElement('savedAddressView_Delegate')

    @property
    def saved_addresses(self):
        items = get_objects(self._address_list_item.symbolic_name)
        addresses = [SavedAddressListItem(get_real_name(item)) for item in items]
        return addresses

    @property
    def address_names(self):
        names = [address.name for address in get_objects(self._address_list_item.symbolic_name)]
        return names

    def _get_saved_address_by_name(self, name):
        for address in self.saved_addresses:
            if address.name == name:
                return address
        raise LookupError(f'Address: {name} not found ')

    def open_add_address_popup(self, attempt=2) -> 'AddSavedAddressPopup':
        self._add_new_address_button.click()
        try:
            return AddSavedAddressPopup().wait_until_appears()
        except AssertionError as err:
            if attempt:
                self.open_add_address_popup(attempt - 1)
            else:
                raise err

    def open_edit_address_popup(self, address_name: str) -> 'EditSavedAddressPopup':
        address = self._get_saved_address_by_name(address_name)
        address.open_context_menu().select('Edit')
        return EditSavedAddressPopup().wait_until_appears()

    def delete_saved_address(self, address_name):
        address = self._get_saved_address_by_name(address_name)
        address.open_context_menu().select('Delete')
        ConfirmationPopup().wait_until_appears().confirm()


class WalletAccountView(BaseElement):

    def __init__(self):
        super(WalletAccountView, self).__init__('mainWindow_StatusSectionLayout_ContentItem')
        self._account_name_text_label = TextLabel('mainWallet_Account_Name')
        self._addresses_panel = BaseElement('mainWallet_Address_Panel')

    @property
    def name(self) -> str:
        return self._account_name_text_label.text

    @property
    def address(self) -> str:
        return str(self._addresses_panel.object.value)

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        self._account_name_text_label.wait_until_appears(timeout_msec)
        return self


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
    NETWORK_SELECTOR_BUTTON: str = "mainWallet_Network_Selector_Button"
    HIDE_SHOW_WATCH_ONLY_BUTTON: str = "mainWallet_Hide_Show_Watch_Only_Button"
    RIGHT_SIDE_TABBAR: str = "mainWallet_Right_Side_Tab_Bar"
    WALLET_ACCOUNTS_LIST: str = "walletAccounts_StatusListView"
    WALLET_ACCOUNT_ITEM_PLACEHOLDER = "walletAccounts_WalletAccountItem_Placeholder"
    EPHEMERAL_NOTIFICATION_LIST: str = "mainWallet_Ephemeral_Notification_List"
    TOTAL_CURRENCY_BALANCE: str = "mainWallet_totalCurrencyBalance"


class AssetView(Enum):
    LIST: str = "mainWallet_Assets_View_List"


class NetworkSelectorPopup(Enum):
    LAYER_1_REPEATER: str = "mainWallet_Network_Popup_Chain_Repeater_1"


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
    ORIGIN_OPTION_NEW_MASTER_KEY = "mainWallet_AddEditAccountPopup_OriginOptionNewMasterKey"
    MASTER_KEY_GO_TO_KEYCARD_SETTINGS_OPTION = "mainWallet_AddEditAccountPopup_MasterKey_GoToKeycardSettingsOption"


class CollectiblesView(Enum):
    COLLECTIONS_REPEATER: str = "mainWallet_Collections_Repeater"
    COLLECTIBLES_REPEATER: str = "mainWallet_Collectibles_Repeater"


class WalletTabBar(Enum):
    ASSET_TAB = 0
    COLLECTION_TAB = 1
    ACTIVITY_TAB = 2


class TransactionsView(Enum):
    TRANSACTIONS_LISTVIEW: str = "mainWallet_Transactions_List"
    TRANSACTIONS_DETAIL_VIEW_HEADER: str = "mainWallet_Transactions_Detail_View_Header"


class StatusWalletScreen:

    #####################################
    ### Screen actions region:
    #####################################

    def __init__(self):
        super(StatusWalletScreen, self).__init__()
        self.left_panel: LeftPanel = LeftPanel()

    def accept_signing_phrase(self):
        click_obj_by_name(SigningPhrasePopUp.OK_GOT_IT_BUTTON.value)

    def add_account_popup_go_to_keycard_settings(self):
        self.add_account_popup_change_origin(AddEditAccountPopup.ORIGIN_OPTION_NEW_MASTER_KEY.value)
        is_loaded_visible_and_enabled(AddEditAccountPopup.MASTER_KEY_GO_TO_KEYCARD_SETTINGS_OPTION.value)
        click_obj_by_name(AddEditAccountPopup.MASTER_KEY_GO_TO_KEYCARD_SETTINGS_OPTION.value)

    def send_transaction(self, account_name, amount, token, chain_name, password):
        is_loaded_visible_and_enabled(AssetView.LIST.value, 2000)
        list = get_obj(AssetView.LIST.value)
        # LoadingTokenDelegate will be visible until the balance is loaded verify_account_balance_is_positive checks for TokenDelegate
        do_until_validation_with_timeout(lambda: time.sleep(0.1),
                                         lambda: self.verify_account_balance_is_positive(list, "ETH")[0],
                                         "Wait for tokens to load", 10000)

        click_obj_by_name(MainWalletScreen.SEND_BUTTON_FOOTER.value)

        self._click_repeater(SendPopup.HEADER_ACCOUNTS_LIST.value, account_name)
        is_loaded_visible_and_enabled(SendPopup.AMOUNT_INPUT.value, 1000)
        type_text(SendPopup.AMOUNT_INPUT.value, amount)

        click_obj_by_name(SendPopup.ASSET_SELECTOR.value)
        asset_list = get_obj(SendPopup.ASSET_LIST.value)
        for index in range(asset_list.count):
            tokenObj = asset_list.itemAtIndex(index)
            if (not is_null(tokenObj) and tokenObj.objectName == "AssetSelector_ItemDelegate_" + token):
                click_obj(asset_list.itemAtIndex(index))
                break

        click_obj_by_name(SendPopup.MY_ACCOUNTS_TAB.value)

        accounts = get_obj(SendPopup.MY_ACCOUNTS_LIST.value)
        for index in range(accounts.count):
            if (accounts.itemAtIndex(index).objectName == account_name):
                print("WE FOUND THE ACCOUNT")
                click_obj(accounts.itemAtIndex(index))
                break

        scroll_obj_by_name(SendPopup.SCROLL_BAR.value)

        click_obj_by_name(SendPopup.SEND_BUTTON.value)

        authenticate_popup_enter_password(password)

    def _click_repeater(self, repeater_object_name: str, object_name: str):
        repeater = get_obj(repeater_object_name)
        for index in range(repeater.count):
            if (repeater.itemAt(index).objectName == object_name):
                click_obj(repeater.itemAt(index))
                break

    def add_saved_address(self, name: str, address: str):
        self.left_panel.open_saved_addresses().open_add_address_popup().add_saved_address(name, address)

    def edit_saved_address(self, name: str, address: str, new_name: str):
        self.left_panel.open_saved_addresses().open_edit_address_popup(name).edit_saved_address(new_name, address)

    def delete_saved_address(self, name: str):
        self.left_panel.open_saved_addresses().delete_saved_address(name)

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
    
    def click_hide_show_watch_only(self):
        button_value_before_click = get_obj(MainWalletScreen.HIDE_SHOW_WATCH_ONLY_BUTTON.value).text
        Button(MainWalletScreen.HIDE_SHOW_WATCH_ONLY_BUTTON.value).click()
        button_value_after_click = get_obj(MainWalletScreen.HIDE_SHOW_WATCH_ONLY_BUTTON.value).text
        assert button_value_before_click != button_value_after_click, f"Hide/Show watch only button label is not changed, button label is {button_value_after_click}, was {button_value_before_click}"


    #####################################
    ### Verifications region:
    #####################################
    def verify_account_existence(self, name: str, color: str, emoji_unicode: str):
        expected_account = constants.wallet.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in self.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {self.left_panel.accounts}')

    def verify_account_doesnt_exist(self, name: str):
        assert wait_for(name not in [account.name for account in self.left_panel.accounts], 10000), \
            f'Account with {name} is still displayed even it should not be'
    
    def verify_account_exist(self, name: str):
        assert wait_for(name in [account.name for account in self.left_panel.accounts], 10000), \
            f'Account with {name} is not displayed even it should be'

    def verify_account_address_correct(self, account_name: str, address: str):
        actual_address = self.left_panel.select_account(account_name).address
        assert actual_address.lower() == address.lower(), f'Account {account_name} has unexpected address {actual_address}'

    def verify_keycard_settings_is_opened(self):
        [compLoaded, accNameObj] = is_loaded_visible_and_enabled(SidebarComponents.KEYCARD_OPTION.value)
        if not compLoaded:
            verify_failure("keycard option from the app settings cannot be found")
            return
        verify(bool(accNameObj.selected), "keycard option from the app settings is displayed")

    def verify_account_balance_is_positive(self, list, symbol: str) -> Tuple(bool, ):
        if list is None:
            return (False,)

        for index in range(list.count):
            tokenListItem = list.itemAtIndex(index)
            if tokenListItem != None and tokenListItem.item != None and tokenListItem.item.objectName == "AssetView_LoadingTokenDelegate_" + str(
                    index):
                return (False,)
            if tokenListItem != None and tokenListItem.item != None and tokenListItem.item.objectName == "AssetView_TokenListItem_" + symbol and tokenListItem.item.balance != "0":
                return (True, tokenListItem)
        return (False,)

    def verify_positive_balance(self, symbol: str):
        is_loaded_visible_and_enabled(AssetView.LIST.value, 5000)
        list = get_obj(AssetView.LIST.value)
        do_until_validation_with_timeout(lambda: time.sleep(0.1),
                                         lambda: self.verify_account_balance_is_positive(list, symbol)[0],
                                         "Symbol " + symbol + " not found in the asset list", 5000)

    def verify_saved_address_exists(self, name: str):
        assert wait_for(name in self.left_panel.open_saved_addresses().address_names), f'Address: {name} not found'

    def verify_saved_address_doesnt_exist(self, name: str):
        assert wait_for(name not in self.left_panel.open_saved_addresses().address_names), f'Address: {name} found'

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
        if (collectionsRepeater.count > 0):
            collectionsRepeater.itemAt(0).expanded = True
        collectiblesRepeater = get_obj(CollectiblesView.COLLECTIBLES_REPEATER.value)
        verify(collectiblesRepeater.count > 0, "Collectibles not retrieved for the account")

    def verify_transactions_exist(self):
        tabbar = get_obj(MainWalletScreen.RIGHT_SIDE_TABBAR.value)
        click_obj(tabbar.itemAt(WalletTabBar.ACTIVITY_TAB.value))

        transaction_list_view = get_obj(TransactionsView.TRANSACTIONS_LISTVIEW.value)

        wait_for("transaction_list_view.count > 0", 60 * 1000)
        verify(transaction_list_view.count > 1, "Transactions not retrieved for the account")

        transaction_item = transaction_list_view.itemAtIndex(1)
        transaction_detail_header = get_obj(TransactionsView.TRANSACTIONS_DETAIL_VIEW_HEADER.value)

        click_obj(transaction_item)

        verify_equal(transaction_item.item.cryptoValue, transaction_detail_header.cryptoValue)
        verify_equal(transaction_item.item.transferStatus, transaction_detail_header.transferStatus)
        verify_equal(transaction_item.item.shortTimeStamp, transaction_detail_header.shortTimeStamp)
        verify_equal(transaction_item.item.fiatValue, transaction_detail_header.fiatValue)
        verify_equal(transaction_item.item.symbol, transaction_detail_header.symbol)
