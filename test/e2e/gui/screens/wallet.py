import typing

import allure

import configs
import constants.user
import driver
from driver.objects_access import walk_children
from gui.components.base_popup import BasePopup
from gui.components.context_menu import ContextMenu
from gui.components.wallet.add_saved_address_popup import AddressPopup, EditSavedAddressPopup
from gui.components.wallet.confirmation_popup import ConfirmationPopup
from gui.components.wallet.remove_wallet_account_popup import RemoveWalletAccountPopup
from gui.components.wallet.send_popup import SendPopup
from gui.components.wallet.wallet_account_popups import AccountPopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names
from scripts.utils.decorators import close_exists


class WalletScreen(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_WalletLayout)
        self.left_panel: LeftPanel = LeftPanel()


class LeftPanel(QObject):

    def __init__(self):
        super(LeftPanel, self).__init__(names.mainWallet_LeftTab)
        self._saved_addresses_button = Button(names.mainWallet_Saved_Addresses_Button)
        self._wallet_account_item = QObject(names.walletAccount_StatusListItem)
        self._add_account_button = Button(names.mainWallet_Add_Account_Button)
        self._all_accounts_button = Button(names.mainWallet_All_Accounts_Button)
        self._all_accounts_balance = TextLabel(names.mainWallet_All_Accounts_Balance)

    @allure.step('Get total balance visibility state')
    def is_total_balance_visible(self) -> bool:
        return self._all_accounts_balance.is_visible

    @property
    @allure.step('Get all accounts from list')
    def accounts(self) -> typing.List[constants.user.account_list_item]:
        if 'title' in self._wallet_account_item.real_name.keys():
            del self._wallet_account_item.real_name['title']

        accounts = []
        for account_item in driver.findAllObjects(self._wallet_account_item.real_name):
            try:
                name = str(account_item.title)
                color = str(account_item.asset.color.name).lower()
                emoji = ''
                for child in walk_children(account_item):
                    if hasattr(child, 'emojiId'):
                        emoji = str(child.emojiId)
                        break
                accounts.append(constants.user.account_list_item(name, color, emoji))
            except (AttributeError, RuntimeError):
                continue

        return accounts

    @allure.step('Get total balance value from All accounts')
    def get_total_balance_value(self):
        return self._all_accounts_balance.text

    @allure.step('Choose saved addresses on left wallet panel')
    @close_exists(BasePopup())
    def open_saved_addresses(self) -> 'SavedAddressesView':
        self._saved_addresses_button.click()
        return SavedAddressesView().wait_until_appears()

    @allure.step('Select account from list')
    @close_exists(BasePopup())
    def select_account(self, account_name: str) -> 'WalletAccountView':
        self._wallet_account_item.real_name['title'] = account_name
        self._wallet_account_item.click()
        return WalletAccountView().wait_until_appears()

    @allure.step('Open context menu from left wallet panel')
    @close_exists(BasePopup())
    def _open_context_menu(self) -> ContextMenu:
        super(LeftPanel, self).open_context_menu()
        return ContextMenu().wait_until_appears()

    @allure.step('Open context menu for account')
    @close_exists(BasePopup())
    def _open_context_menu_for_account(self, account_name: str) -> ContextMenu:
        self._wallet_account_item.real_name['title'] = account_name
        self._wallet_account_item.wait_until_appears().open_context_menu()
        return ContextMenu().wait_until_appears()

    @allure.step("Select Hide/Include in total balance from context menu for account")
    def hide_include_in_total_balance_from_context_menu(self, account_name: str):
        self._open_context_menu_for_account(account_name).select_hide_include_total_balance_from_context_menu()

    @allure.step('Open account popup for editing from context menu')
    def open_edit_account_popup_from_context_menu(self, account_name: str, attempt: int = 2) -> AccountPopup:
        try:
            self._open_context_menu_for_account(account_name).select_edit_account_from_context_menu()
            return AccountPopup().wait_until_appears()
        except Exception as ex:
            if attempt:
                return self.open_edit_account_popup_from_context_menu(account_name, attempt - 1)
            else:
                raise ex

    @allure.step('Open account popup')
    def open_add_account_popup(self, attempt: int = 2):
        self._add_account_button.click()
        try:
            return AccountPopup().wait_until_appears()
        except AssertionError as err:
            if attempt:
                self.open_add_account_popup(attempt - 1)
            else:
                raise err

    @allure.step('Select add watched address from context menu')
    def select_add_watched_address_from_context_menu(self) -> AccountPopup:
        self._open_context_menu().select_add_watched_address_from_context_menu()
        return AccountPopup().wait_until_appears()

    @allure.step('Delete account from the list from context menu')
    def delete_account_from_context_menu(self, account_name: str, attempt: int = 2) -> RemoveWalletAccountPopup:
        try:
            self._open_context_menu_for_account(account_name).select_delete_account_from_context_menu()
            return RemoveWalletAccountPopup().wait_until_appears()
        except Exception as ex:
            if attempt:
                return self.delete_account_from_context_menu(account_name, attempt - 1)
            else:
                raise ex


class SavedAddressesView(QObject):

    def __init__(self):
        super(SavedAddressesView, self).__init__(names.mainWindow_SavedAddressesView)
        self._add_new_address_button = Button(names.mainWallet_Saved_Addresses_Add_Buttton)
        self._address_list_item = QObject(names.savedAddressView_Delegate)
        self._addresses_area = QObject(names.savedAddresses_area)
        self._addresses_list_view = QObject(names.mainWallet_Saved_Addresses_List)
        self._send_button = Button(names.send_StatusRoundButton)
        self._open_menu_button = Button(names.savedAddressView_Delegate_menuButton)
        self._saved_address_item = QObject(names.savedAddressView_Delegate)

    @property
    @allure.step('Get saved addresses names')
    def address_names(self):
        address_names = []
        for child in walk_children(self._addresses_list_view.object):
            if getattr(child, 'id', '') == 'savedAddressDelegate':
                address_names.append(str(child.name))
        return address_names

    @allure.step('Get saved addresses list')
    def get_saved_addresses_list(self):
        addresses = [str(address.name) for address in driver.findAllObjects(self._saved_address_item.real_name)]
        return addresses

    @allure.step('Open add new address popup')
    def open_add_saved_address_popup(self, attempt=2) -> 'AddressPopup':
        self._add_new_address_button.click()
        try:
            return AddressPopup().wait_until_appears()
        except AssertionError as err:
            if attempt:
                self.open_add_saved_address_popup(attempt - 1)
            else:
                raise err

    @allure.step('Open edit address popup for saved address')
    def open_edit_address_popup(self, name: str) -> 'EditSavedAddressPopup':
        self.open_context_menu(name).select_edit_saved_address()
        return EditSavedAddressPopup()

    @allure.step('Delete saved address from the list')
    def delete_saved_address(self, address_name):
        self.open_context_menu(address_name).select_delete_saved_address()
        assert ConfirmationPopup().get_confirmation_text().startswith('Are you sure you want to remove')
        ConfirmationPopup().confirm()

    @allure.step('Open context menu in saved address')
    def open_context_menu(self, name) -> ContextMenu:
        self._open_menu_button.real_name['objectName'] = 'savedAddressView_Delegate_menuButton' + '_' + name
        self._address_list_item.real_name['objectName'] = 'savedAddressView_Delegate' + '_' + name
        self._address_list_item.hover()
        self._open_menu_button.click()
        return ContextMenu().wait_until_appears()


class WalletAccountView(QObject):

    def __init__(self):
        super(WalletAccountView, self).__init__(names.mainWindow_StatusSectionLayout_ContentItem)
        self._account_name_text_label = TextLabel(names.mainWallet_Account_Name)
        self._addresses_panel = QObject(names.mainWallet_Address_Panel)
        self._send_button = Button(names.mainWindow_Send_Button)

    @property
    @allure.step('Get name of account')
    def name(self) -> str:
        return self._account_name_text_label.text

    @property
    @allure.step('Get address of account')
    def address(self) -> str:
        return str(self._addresses_panel.object.value)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._account_name_text_label.wait_until_appears(timeout_msec)
        return self

    @allure.step('Open send popup')
    def open_send_popup(self) -> SendPopup:
        self._send_button.click()
        return SendPopup().wait_until_appears()
