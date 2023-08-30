import allure

import driver

from gui.components.base_popup import BasePopup
from gui.components.wallet.add_saved_address_popup import AddressPopup, EditSavedAddressPopup
from gui.components.wallet.confirmation_popup import ConfirmationPopup
from gui.components.context_menu import ContextMenu
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
from scripts.utils.decorators import close_exists


class WalletScreen(QObject):

    def __init__(self):
        super().__init__('mainWindow_WalletLayout')
        self.left_panel = LeftPanel()

class LeftPanel(QObject):

    def __init__(self):
        super(LeftPanel, self).__init__('mainWallet_LeftTab')
        self._saved_addresses_button = Button('mainWallet_Saved_Addresses_Button')
        self._wallet_account_item = QObject('walletAccount_StatusListItem')
        self._add_account_button = Button('mainWallet_Add_Account_Button')
        self._all_accounts_button = Button('mainWallet_All_Accounts_Button')

    @allure.step('Choose saved addresses on left wallet panel')
    @close_exists(BasePopup())
    def open_saved_addresses(self) -> 'SavedAddressesView':
        self._saved_addresses_button.click()
        return SavedAdressesView().wait_until_appears()


class SavedAdressesView(QObject):

    def __init__(self):
        super(SavedAdressesView, self).__init__('mainWindow_SavedAddressesView')
        self._add_new_address_button = Button('mainWallet_Saved_Addreses_Add_Buttton')
        self._address_list_item = QObject('savedAddressView_Delegate')
        self._send_button = Button('send_StatusRoundButton')
        self._open_menu_button = Button('savedAddressView_Delegate_menuButton')

    @property
    @allure.step('Get saved addresses names')
    def address_names(self):
        names = [str(address.name) for address in driver.findAllObjects(self._address_list_item.real_name)]
        return names

    @allure.step('Open add new address popup')
    def open_add_address_popup(self, attempt=2) -> 'AddressPopup':
        self._add_new_address_button.click()
        try:
            return AddressPopup().wait_until_appears()
        except AssertionError as err:
            if attempt:
                self.open_add_address_popup(attempt - 1)
            else:
                raise err

    @allure.step('Open edit address popup for saved address')
    def open_edit_address_popup(self, name: str) -> 'EditSavedAddressPopup':
        self.open_context_menu(name).select('Edit')
        return EditSavedAddressPopup().wait_until_appears()

    @allure.step('Delete saved address from the list')
    def delete_saved_address(self, address_name):
        self.open_context_menu(address_name).select('Delete')
        ConfirmationPopup().wait_until_appears().confirm()

    @allure.step('Open context menu in saved address')
    def open_context_menu(self, name) -> ContextMenu:
        self._open_menu_button.real_name['objectName'] = 'savedAddressView_Delegate_menuButton' + '_' + name
        self._open_menu_button.click()
        return ContextMenu().wait_until_appears()