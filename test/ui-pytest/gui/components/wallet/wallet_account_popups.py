import allure

import configs
import constants.wallet
import driver
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from gui.components.base_popup import BasePopup
from gui.components.emoji_popup import EmojiPopup
from gui.elements.qt.button import Button
from gui.elements.qt.check_box import CheckBox
from gui.elements.qt.text_edit import TextEdit
from gui.elements.qt.scroll import Scroll
from gui.elements.qt.object import QObject

GENERATED_PAGES_LIMIT = 20

class AccountPopup(BasePopup):
    def __init__(self):
        super(AccountPopup, self).__init__()
        self._scroll = Scroll('scrollView_StatusScrollView')
        self._name_text_edit = TextEdit('mainWallet_AddEditAccountPopup_AccountName')
        self._emoji_button = Button('mainWallet_AddEditAccountPopup_AccountEmojiPopupButton')
        self._color_radiobutton = QObject('color_StatusColorRadioButton')
        # origin
        self._origin_combobox = QObject('mainWallet_AddEditAccountPopup_SelectedOrigin')
        self._watch_only_account_origin_item = QObject("mainWallet_AddEditAccountPopup_OriginOptionWatchOnlyAcc")
        self._new_master_key_origin_item = QObject('mainWallet_AddEditAccountPopup_OriginOptionNewMasterKey')
        self._existing_origin_item = QObject('addAccountPopup_OriginOption_StatusListItem')
        # derivation
        self._address_text_edit = TextEdit('mainWallet_AddEditAccountPopup_AccountWatchOnlyAddress')
        self._add_account_button = Button('mainWallet_AddEditAccountPopup_PrimaryButton')
        self._edit_derivation_path_button = Button('mainWallet_AddEditAccountPopup_EditDerivationPathButton')
        self._derivation_path_combobox_button = Button('mainWallet_AddEditAccountPopup_PreDefinedDerivationPathsButton')
        self._derivation_path_list_item = QObject('mainWallet_AddEditAccountPopup_derivationPath')
        self._reset_derivation_path_button = Button('mainWallet_AddEditAccountPopup_ResetDerivationPathButton')
        self._derivation_path_text_edit = TextEdit('mainWallet_AddEditAccountPopup_DerivationPathInput')
        self._address_combobox_button = Button('mainWallet_AddEditAccountPopup_GeneratedAddressComponent')
        self._non_eth_checkbox = CheckBox('mainWallet_AddEditAccountPopup_NonEthDerivationPathCheckBox')

    @allure.step('Set name for account')
    def set_name(self, value: str):
        self._name_text_edit.text = value
        return self

    @allure.step('Set color for account')
    def set_color(self, value: str):
        if 'radioButtonColor' in self._color_radiobutton.real_name.keys():
            del self._color_radiobutton.real_name['radioButtonColor']
        colors = [str(item.radioButtonColor) for item in driver.findAllObjects(self._color_radiobutton.real_name)]
        assert value in colors, f'Color {value} not found in {colors}'
        self._color_radiobutton.real_name['radioButtonColor'] = value
        self._color_radiobutton.click()
        return self

    @allure.step('Set emoji for account')
    def set_emoji(self, value: str):
        self._emoji_button.click()
        EmojiPopup().wait_until_appears().select(value)
        return self

    @allure.step('Set eth address for account added from context menu')
    def set_eth_address(self, value: str):
        self._address_text_edit.text = value
        return self

    @allure.step('Set eth address for account added from plus button')
    def set_origin_eth_address(self, value: str):
        self._origin_combobox.click()
        self._watch_only_account_origin_item.click()
        self._address_text_edit.text = value
        return self

    @allure.step('Set private key for account')
    def set_origin_private_key(self, value: str):
        self._origin_combobox.click()
        self._new_master_key_origin_item.click()
        AddNewAccountPopup().wait_until_appears().import_private_key(value)
        return self

    @allure.step('Set derivation path for account')
    def set_derivation_path(self, value: str, index: int, password: str):
        self._edit_derivation_path_button.hover().click()
        AuthenticatePopup().wait_until_appears().authenticate(password)
        if value in [_.value for _ in constants.wallet.DerivationPath]:
            self._derivation_path_combobox_button.click()
            self._derivation_path_list_item.real_name['title'] = value
            self._derivation_path_list_item.click()
            del self._derivation_path_list_item.real_name['title']
            self._address_combobox_button.click()
            GeneratedAddressesList().wait_until_appears().select(index)
            if value != constants.wallet.DerivationPath.ETHEREUM.value:
                self._scroll.vertical_down_to(self._non_eth_checkbox)
                self._non_eth_checkbox.set(True)
        else:
            self._derivation_path_text_edit.type_text(str(index))
        return self

    @allure.step('Save added account')
    def save(self):
        self._add_account_button.wait_until_appears().click()
        return self


class AddNewAccountPopup(BasePopup):

    def __init__(self):
        super(AddNewAccountPopup, self).__init__()
        self._import_private_key_button = Button('mainWallet_AddEditAccountPopup_MasterKey_ImportPrivateKeyOption')
        self._private_key_text_edit = TextEdit('mainWallet_AddEditAccountPopup_PrivateKey')
        self._private_key_name_text_edit = TextEdit('mainWallet_AddEditAccountPopup_PrivateKeyName')
        self._continue_button = Button('mainWallet_AddEditAccountPopup_PrimaryButton')

    @allure.step('Import private key')
    def import_private_key(self, private_key: str) -> str:
        self._import_private_key_button.click()
        self._private_key_text_edit.text = private_key
        self._private_key_name_text_edit.text = private_key[:5]
        self._continue_button.click()
        return private_key[:5]


class GeneratedAddressesList(QObject):

    def __init__(self):
        super(GeneratedAddressesList, self).__init__('statusDesktop_mainWindow_overlay_popup2')
        self._address_list_item = QObject('addAccountPopup_GeneratedAddress')
        self._paginator_page = QObject('page_StatusBaseButton')

    @property
    @allure.step('Load generated addresses list')
    def is_paginator_load(self) -> bool:
        try:
            return str(driver.findAllObjects(self._paginator_page.real_name)[0].text) == '1'
        except IndexError:
            return False

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        if 'text' in self._paginator_page.real_name:
            del self._paginator_page.real_name['text']
        assert driver.waitFor(lambda: self.is_paginator_load, timeout_msec), 'Generated address list not load'
        return self

    @allure.step('Select address in list')
    def select(self, index: int):
        self._address_list_item.real_name['objectName'] = f'AddAccountPopup-GeneratedAddress-{index}'

        selected_page_number = 1
        while selected_page_number != GENERATED_PAGES_LIMIT:
            if self._address_list_item.is_visible:
                self._address_list_item.click()
                self._paginator_page.wait_until_hidden()
                break
            else:
                selected_page_number += 1
                self._paginator_page.real_name['text'] = selected_page_number
                self._paginator_page.click()