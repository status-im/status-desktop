import random

import configs.timeouts
from constants.wallet import *
from gui.screens.settings_wallet import *
from gui.components.base_popup import BasePopup
from gui.components.emoji_popup import EmojiPopup
from gui.components.authenticate_popup import AuthenticatePopup
from gui.components.wallet.back_up_your_seed_phrase_popup import BackUpYourSeedPhrasePopUp
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names

GENERATED_PAGES_LIMIT = 20


class AccountPopup(BasePopup):
    def __init__(self):
        super(AccountPopup, self).__init__()
        self._scroll = Scroll(names.o_Flickable)
        self._name_text_edit = TextEdit(names.mainWallet_AddEditAccountPopup_AccountName)
        self._emoji_button = Button(names.mainWallet_AddEditAccountPopup_AccountEmojiPopupButton)
        self._color_radiobutton = QObject(names.color_StatusColorRadioButton)
        self._popup_header_title = TextLabel(names.mainWallet_AddEditAccountPopup_HeaderTitle)
        self._emoji_id_in_title = QObject(names.mainWallet_AddEditAccountPopup_HeaderEmoji)
        # origin
        self._origin_combobox = QObject(names.mainWallet_AddEditAccountPopup_SelectedOrigin)
        self._watched_address_origin_item = QObject(names.mainWallet_AddEditAccountPopup_OriginOptionWatchOnlyAcc)
        self._new_master_key_origin_item = QObject(names.mainWallet_AddEditAccountPopup_OriginOptionNewMasterKey)
        self._existing_origin_item = QObject(names.addAccountPopup_OriginOption_StatusListItem)
        self._use_keycard_button = QObject(names.mainWallet_AddEditAccountPopup_MasterKey_GoToKeycardSettingsOption)
        # derivation
        self._address_text_edit = TextEdit(names.mainWallet_AddEditAccountPopup_AccountWatchOnlyAddress)
        self._add_save_account_confirmation_button = Button(names.mainWallet_AddEditAccountPopup_PrimaryButton)
        self._edit_derivation_path_button = Button(names.mainWallet_AddEditAccountPopup_EditDerivationPathButton)
        self._derivation_path_combobox_button = Button(
            names.mainWallet_AddEditAccountPopup_PreDefinedDerivationPathsButton)
        self._derivation_path_list_item = QObject(names.mainWallet_AddEditAccountPopup_derivationPath)
        self._reset_derivation_path_button = Button(names.mainWallet_AddEditAccountPopup_ResetDerivationPathButton)
        self._derivation_path_text_edit = TextEdit(names.mainWallet_AddEditAccountPopup_DerivationPathInput)
        self._address_combobox_button = Button(names.mainWallet_AddEditAccountPopup_GeneratedAddressComponent)
        self._non_eth_checkbox = CheckBox(names.mainWallet_AddEditAccountPopup_NonEthDerivationPathCheckBox)

    def verify_add_account_popup_present(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        driver.waitFor(lambda: self._popup_header_title.exists, timeout_msec)
        assert (getattr(self._popup_header_title.object, 'text')
                == WalletScreensHeaders.WALLET_ADD_ACCOUNT_POPUP_TITLE.value), \
            f"AccountPopup is not shown or has wrong title, \
                    current screen title is {getattr(self._popup_header_title.object, 'text')}"
        return self

    def verify_edit_account_popup_present(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        driver.waitFor(lambda: self._popup_header_title.exists, timeout_msec)
        assert (getattr(self._popup_header_title.object, 'text')
                == WalletScreensHeaders.WALLET_EDIT_ACCOUNT_POPUP_TITLE.value), \
            f"AccountPopup is not shown or has wrong title, \
                    current screen title is {getattr(self._popup_header_title.object, 'text')}"
        return self

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
        EmojiPopup().wait_until_appears(timeout_msec=10000).select(value)
        return self

    @allure.step('Get emoji id from account header')
    def get_emoji_from_account_title(self):
        return str(getattr(self._emoji_id_in_title.object, 'emojiId'))

    @allure.step('Set eth address for account added from context menu')
    def set_eth_address(self, value: str):
        self._address_text_edit.text = value
        return self

    @allure.step('Set eth address for account added from plus button')
    def set_origin_watched_address(self, value: str):
        self._origin_combobox.click()
        self._watched_address_origin_item.click()
        assert getattr(self._origin_combobox.object, 'title') == WalletOrigin.WATCHED_ADDRESS_ORIGIN.value
        self._address_text_edit.text = value
        return self

    @allure.step('Set private key for account')
    def set_origin_private_key(self, value: str):
        self._origin_combobox.click()
        self.click_new_master_key(value).import_private_key(value)
        return self

    @allure.step('Click new master key item')
    def click_new_master_key(self, value: str, attempts: int = 2):
        self._new_master_key_origin_item.click()
        try:
            AccountPopup().verify_add_account_popup_present()
            return AddNewAccountPopup()
        except AssertionError as err:
            if attempts:
                return self.click_new_master_key(value, attempts - 1)
            else:
                raise err

    @allure.step('Set new seed phrase for account')
    def set_origin_new_seed_phrase(self, value: str):
        self.open_add_new_account_popup().generate_new_master_key(value)
        return self

    @allure.step('Set seed phrase')
    def set_origin_seed_phrase(self, value: typing.List[str]):
        self.open_add_new_account_popup().import_new_seed_phrase(value)
        return self

    @allure.step('Open add new account popup')
    def open_add_new_account_popup(self):
        self._origin_combobox.click()
        self._new_master_key_origin_item.click()
        return AddNewAccountPopup().wait_until_appears()

    @allure.step('Set derivation path for account')
    def set_derivation_path(self, value: str, index: int, password: str):
        self._edit_derivation_path_button.hover().click()
        AuthenticatePopup().wait_until_appears().authenticate(password)
        if value in [_.value for _ in DerivationPath]:
            self._derivation_path_combobox_button.click()
            self._derivation_path_list_item.real_name['title'] = value
            self._derivation_path_list_item.click()
            del self._derivation_path_list_item.real_name['title']
            self._address_combobox_button.click()
            GeneratedAddressesList().wait_until_appears().select(index)
            if value != DerivationPath.ETHEREUM.value:
                self._scroll.vertical_scroll_to(self._non_eth_checkbox)
                self._non_eth_checkbox.set(True)
        else:
            self._derivation_path_text_edit.type_text(str(index))
        return self

    @allure.step('Click continue in keycard settings')
    def continue_in_keycard_settings(self):
        self._origin_combobox.click()
        self._new_master_key_origin_item.click()
        self._use_keycard_button.click()
        return self

    @allure.step('Click confirmation (add account / save changes) button')
    def save_changes(self):
        assert driver.waitFor(lambda: self.is_save_changes_button_enabled(),
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        self._add_save_account_confirmation_button.click()
        return self

    @allure.step('Get enabled state of (add account / save changes) button')
    def is_save_changes_button_enabled(self):
        return driver.waitForObjectExists(self._add_save_account_confirmation_button.real_name,
                                          configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled


class EditAccountFromSettingsPopup(BasePopup):
    def __init__(self):
        super(EditAccountFromSettingsPopup, self).__init__()
        self._change_name_button = Button(names.editWalletSettings_renameButton)
        self._account_name_input = TextEdit(names.editWalletSettings_AccountNameInput)
        self._emoji_selector = QObject(names.editWalletSettings_EmojiSelector)
        self._color_radiobutton = QObject(names.editWalletSettings_ColorSelector)
        self._emoji_item = QObject(names.editWalletSettings_EmojiItem)

    @allure.step('Click Change name button')
    def click_change_name_button(self):
        self._change_name_button.click()

    @allure.step('Type in name for account')
    def type_in_account_name(self, value: str):
        self._account_name_input.text = value
        return self

    @allure.step('Select random color for account')
    def select_random_color_for_account(self):
        if 'radioButtonColor' in self._color_radiobutton.real_name.keys():
            del self._color_radiobutton.real_name['radioButtonColor']
        colors = [str(item.radioButtonColor) for item in driver.findAllObjects(self._color_radiobutton.real_name)]
        self._color_radiobutton.real_name['radioButtonColor'] = \
            random.choice([color for color in colors if color != '#2a4af5'])  # exclude status default color
        self._color_radiobutton.click()
        return self

    @allure.step('Click emoji button')
    def select_random_emoji_for_account(self):
        self._emoji_selector.click()
        EmojiPopup().wait_until_appears()
        emojis = [str(item.objectName) for item in driver.findAllObjects(self._emoji_item.real_name)]
        value = ((random.choice(emojis)).split('_', 1))[1]
        EmojiPopup().wait_until_appears().select(value)
        return self


class AddNewAccountPopup(BasePopup):

    def __init__(self):
        super(AddNewAccountPopup, self).__init__()
        self._import_private_key_button = Button(names.mainWallet_AddEditAccountPopup_MasterKey_ImportPrivateKeyOption)
        self._private_key_text_edit = TextEdit(names.mainWallet_AddEditAccountPopup_PrivateKey)
        self._private_key_name_text_edit = TextEdit(names.mainWallet_AddEditAccountPopup_PrivateKeyName)
        self._continue_button = Button(names.mainWallet_AddEditAccountPopup_PrimaryButton)
        self._import_seed_phrase_button = Button(names.mainWallet_AddEditAccountPopup_MasterKey_ImportSeedPhraseOption)
        self._generate_master_key_button = Button(
            names.mainWallet_AddEditAccountPopup_MasterKey_GenerateSeedPhraseOption)
        self._seed_phrase_12_words_button = Button(names.mainWallet_AddEditAccountPopup_12WordsButton)
        self._seed_phrase_18_words_button = Button(names.mainWallet_AddEditAccountPopup_18WordsButton)
        self._seed_phrase_24_words_button = Button(names.mainWallet_AddEditAccountPopup_24WordsButton)
        self._seed_phrase_word_text_edit = TextEdit(names.mainWindow_statusSeedPhraseInputField_TextEdit)
        self._seed_phrase_phrase_key_name_text_edit = TextEdit(
            names.mainWallet_AddEditAccountPopup_ImportedSeedPhraseKeyName)
        self._already_added_error = QObject(names.enterSeedPhraseInvalidSeedText_StatusBaseText)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._generate_master_key_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Import private key')
    def import_private_key(self, private_key: str) -> str:
        self._import_private_key_button.click()
        self._private_key_text_edit.text = private_key
        self._private_key_name_text_edit.text = private_key[:5]
        self._continue_button.click()
        return private_key[:5]

    @allure.step('Import new seed phrase and continue')
    def import_new_seed_phrase(self, seed_phrase_words: list):
        self.enter_new_seed_phrase(seed_phrase_words)
        seed_phrase_name = ''.join([word[0] for word in seed_phrase_words[:10]])
        self._seed_phrase_phrase_key_name_text_edit.text = seed_phrase_name
        self._continue_button.click()
        return seed_phrase_name

    @allure.step('Enter new seed phrase')
    def enter_new_seed_phrase(self, seed_phrase_words: list) -> str:
        self._import_seed_phrase_button.click()
        if len(seed_phrase_words) == 12:
            self._seed_phrase_12_words_button.click()
        elif len(seed_phrase_words) == 18:
            self._seed_phrase_18_words_button.click()
        elif len(seed_phrase_words) == 24:
            self._seed_phrase_24_words_button.click()
        else:
            raise RuntimeError("Wrong amount of seed words", len(seed_phrase_words))
        for count, word in enumerate(seed_phrase_words, start=1):
            self._seed_phrase_word_text_edit.real_name['objectName'] = f'enterSeedPhraseInputField{count}'
            self._seed_phrase_word_text_edit.text = word

    @allure.step('Generate new seed phrase')
    def generate_new_master_key(self, name: str):
        self._generate_master_key_button.click()
        BackUpYourSeedPhrasePopUp().wait_until_appears().generate_seed_phrase(name)

    @allure.step('Get text of error')
    def get_already_added_error(self):
        assert self._already_added_error.is_visible
        return self._already_added_error.object.text


class GeneratedAddressesList(QObject):

    def __init__(self):
        super(GeneratedAddressesList, self).__init__(names.statusDesktop_mainWindow_overlay_popup2)
        self._address_list_item = QObject(names.addAccountPopup_GeneratedAddress)
        self._paginator_page = QObject(names.page_StatusBaseButton)

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
