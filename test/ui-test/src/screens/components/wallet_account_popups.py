import typing

import configs
import constants
import squish
from drivers.SquishDriver import *

from .authenticate_popup import AuthenticatePopup
from .back_up_your_seed_phrase_popup import BackUpYourSeedPhrasePopUp
from .base_popup import BasePopup
from .emoji_popup import EmojiPopup

GENERATED_LPAGES_LIMIT = 20


class GeneratedAddressesList(BaseElement):

    def __init__(self):
        super(GeneratedAddressesList, self).__init__('statusDesktop_mainWindow_overlay_popup2')
        self._address_list_item = BaseElement('addAccountPopup_GeneratedAddress')
        self._paginator_page = BaseElement('page_StatusBaseButton')

    @property
    def is_paginator_load(self) -> bool:
        try:
            return str(squish.findAllObjects(self._paginator_page.object_name)[0].text) == '1'
        except IndexError:
            return False

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        if 'text' in self._paginator_page.object_name:
            del self._paginator_page.object_name['text']
        assert squish.waitFor(lambda: self.is_paginator_load, timeout_msec), 'Generated address list not load'
        return self

    def select(self, index: int):
        self._address_list_item.object_name['objectName'] = f'AddAccountPopup-GeneratedAddress-{index}'

        selected_page_number = 1
        while selected_page_number != GENERATED_LPAGES_LIMIT:
            if self._address_list_item.is_visible:
                self._address_list_item.click()
                self._paginator_page.wait_until_hidden()
                break
            else:
                selected_page_number += 1
                self._paginator_page.object_name['text'] = selected_page_number
                self._paginator_page.click()


class AddNewAccountPopup(BasePopup):

    def __init__(self):
        super(AddNewAccountPopup, self).__init__()
        self._import_private_key_button = Button('mainWallet_AddEditAccountPopup_MasterKey_ImportPrivateKeyOption')
        self._import_seed_phrase_button = Button('mainWallet_AddEditAccountPopup_MasterKey_ImportSeedPhraseOption')
        self._private_key_text_edit = TextEdit('mainWallet_AddEditAccountPopup_PrivateKey')
        self._private_key_name_text_edit = TextEdit('mainWallet_AddEditAccountPopup_PrivateKeyName')
        self._generate_master_key_button = Button('mainWallet_AddEditAccountPopup_MasterKey_GenerateSeedPhraseOption')
        self._continue_button = Button('mainWallet_AddEditAccountPopup_PrimaryButton')
        self._seed_phrase_12_words_button = Button("mainWallet_AddEditAccountPopup_12WordsButton")
        self._seed_phrase_18_words_button = Button("mainWallet_AddEditAccountPopup_18WordsButton")
        self._seed_phrase_24_words_button = Button("mainWallet_AddEditAccountPopup_24WordsButton")
        self._seed_phrase_word_text_edit = TextEdit('mainWallet_AddEditAccountPopup_SPWord')
        self._seed_phrase_phrase_key_name_text_edit = TextEdit(
            'mainWallet_AddEditAccountPopup_ImportedSeedPhraseKeyName')

    def import_private_key(self, private_key: str) -> str:
        self._import_private_key_button.click()
        self._private_key_text_edit.text = private_key
        self._private_key_name_text_edit.text = private_key[:5]
        self._continue_button.click()
        return private_key[:5]

    def import_new_seed_phrase(self, seed_phrase_words: list) -> str:
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
            self._seed_phrase_word_text_edit.object_name['objectName'] = f'statusSeedPhraseInputField{count}'
            self._seed_phrase_word_text_edit.text = word
        seed_phrase_name = ''.join([word[0] for word in seed_phrase_words[:10]])
        self._seed_phrase_phrase_key_name_text_edit.text = seed_phrase_name
        self._continue_button.click()
        return seed_phrase_name

    def generate_new_master_key(self, name: str):
        self._generate_master_key_button.click()
        BackUpYourSeedPhrasePopUp().wait_until_appears().generate_seed_phrase(name)


class AccountPopup(BasePopup):
    def __init__(self):
        super(AccountPopup, self).__init__()
        self._scroll = Scroll('scrollView_StatusScrollView')
        self._name_text_edit = TextEdit('mainWallet_AddEditAccountPopup_AccountName')
        self._emoji_button = Button('mainWallet_AddEditAccountPopup_AccountEmojiPopupButton')
        self._color_radiobutton = BaseElement('color_StatusColorRadioButton')
        # origin
        self._origin_combobox = BaseElement('mainWallet_AddEditAccountPopup_SelectedOrigin')
        self._watch_only_account_origin_item = BaseElement("mainWallet_AddEditAccountPopup_OriginOptionWatchOnlyAcc")
        self._new_master_key_origin_item = BaseElement('mainWallet_AddEditAccountPopup_OriginOptionNewMasterKey')
        self._existing_origin_item = BaseElement('addAccountPopup_OriginOption_StatusListItem')
        # derivation
        self._address_text_edit = TextEdit('mainWallet_AddEditAccountPopup_AccountWatchOnlyAddress')
        self._add_account_button = Button('mainWallet_AddEditAccountPopup_PrimaryButton')
        self._edit_derivation_path_button = Button('mainWallet_AddEditAccountPopup_EditDerivationPathButton')
        self._derivation_path_combobox_button = Button('mainWallet_AddEditAccountPopup_PreDefinedDerivationPathsButton')
        self._derivation_path_list_item = BaseElement('mainWallet_AddEditAccountPopup_derivationPath')
        self._reset_derivation_path_button = Button('mainWallet_AddEditAccountPopup_ResetDerivationPathButton')
        self._derivation_path_text_edit = TextEdit('mainWallet_AddEditAccountPopup_DerivationPathInput')
        self._address_combobox_button = Button('mainWallet_AddEditAccountPopup_GeneratedAddressComponent')
        self._non_eth_checkbox = CheckBox('mainWallet_AddEditAccountPopup_NonEthDerivationPathCheckBox')

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        assert squish.waitFor(lambda: self._name_text_edit.is_visible, timeout_msec), f'Object {self} is not visible'
        return self

    def wait_until_hidden(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        assert squish.waitFor(lambda: not self._name_text_edit.is_visible, timeout_msec), f'Object {self} is visible'


    def set_name(self, value: str):
        self._name_text_edit.text = value
        return self

    def set_color(self, value: str):
        if 'radioButtonColor' in self._color_radiobutton.object_name.keys():
            del self._color_radiobutton.object_name['radioButtonColor']
        colors = [str(item.radioButtonColor) for item in squish.findAllObjects(self._color_radiobutton.object_name)]
        assert value in colors, f'Color {value} not found in {colors}'
        self._color_radiobutton.object_name['radioButtonColor'] = value
        self._color_radiobutton.click()
        return self

    def set_emoji(self, value: str):
        self._emoji_button.click()
        EmojiPopup().wait_until_appears().select(value)
        return self

    def set_origin_eth_address(self, value: str):
        self._origin_combobox.click()
        self._watch_only_account_origin_item.click()
        self._address_text_edit.text = value
        return self

    def set_origin_keypair(self, value: str):
        self._origin_combobox.click()
        self._existing_origin_item.object_name['objectName'] = f'AddAccountPopup-OriginOption-{value}'
        self._existing_origin_item.click()
        return self

    def set_origin_seed_phrase(self, value: typing.List[str]):
        self._origin_combobox.click()
        self._new_master_key_origin_item.click()
        AddNewAccountPopup().wait_until_appears().import_new_seed_phrase(value)
        return self

    def set_origin_new_seed_phrase(self, value: str):
        self._origin_combobox.click()
        self._new_master_key_origin_item.click()
        AddNewAccountPopup().wait_until_appears().generate_new_master_key(value)
        return self

    def set_origin_private_key(self, value: str):
        self._origin_combobox.click()
        self._new_master_key_origin_item.click()
        AddNewAccountPopup().wait_until_appears().import_private_key(value)
        return self

    def set_derivation_path(self, value: str, index: int):
        self._edit_derivation_path_button.hover().click()
        AuthenticatePopup().wait_until_appears().authenticate()
        if value in [_.value for _ in constants.wallet.DerivationPath]:
            self._derivation_path_combobox_button.click()
            self._derivation_path_list_item.object_name['title'] = value
            self._derivation_path_list_item.click()
            del self._derivation_path_list_item.object_name['title']
            self._address_combobox_button.click()
            GeneratedAddressesList().wait_until_appears().select(index)
            if value != constants.wallet.DerivationPath.ETHEREUM.value:
                self._scroll.vertical_down_to(self._non_eth_checkbox)
                self._non_eth_checkbox.set(True)
        else:
            self._derivation_path_text_edit.type_text(str(index))
        return self

    def save(self):
        self._add_account_button.click()
        return self
