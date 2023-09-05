import allure

import driver
from gui.components.base_popup import BasePopup
from gui.components.emoji_popup import EmojiPopup
from gui.elements.qt.button import Button
from gui.elements.qt.check_box import CheckBox
from gui.elements.qt.text_edit import TextEdit
from gui.elements.qt.scroll import Scroll
from gui.elements.qt.object import QObject


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

    @allure.step('Save added account')
    def save(self):
        self._add_account_button.wait_until_appears().click()
        return self