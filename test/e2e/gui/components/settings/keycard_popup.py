import time
import typing

import allure

import configs
import driver
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from scripts.tools.image import Image


class KeycardPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._keycard_image = QObject('image_KeycardImage')
        self._keycard_popup_header = TextLabel('headerTitle')
        self._keycard_instruction_text = TextLabel('keycard_reader_instruction_text')
        self._next_button = Button('nextStatusButton')
        self._reveal_seed_phrase_button = Button('revealSeedPhraseButton')
        self._seed_phrase_panel = QObject('seedPhraseWordAtIndex_Placeholder')
        self._seed_phrase_first_word_component = QObject('word0_StatusInput')
        self._seed_phrase_second_word_component = QObject('word1_StatusInput')
        self._seed_phrase_third_word_component = QObject('word2_StatusInput')
        self._seed_phrase_word_text_edit = TextEdit('statusSeedPhraseInputField_TextEdit')
        self._seed_phrase_12_words_button = Button('switchTabBar_12_words_StatusSwitchTabButton')
        self._seed_phrase_18_words_button = Button('switchTabBar_18_words_StatusSwitchTabButton')
        self._seed_phrase_24_words_button = Button('switchTabBar_24_words_StatusSwitchTabButton')
        self._field_object = QObject('edit_TextEdit')
        self._keypair_item = QObject('o_KeyPairItem')
        self._keypair_tag = QObject('o_StatusListItemTag')
        self._selection_box = QObject('radioButton_StatusRadioButton')
        self._keycard_init = QObject('o_KeycardInit')

    @property
    @allure.step('Get keycard image')
    def keycard_image(self) -> Image:
        return self._keycard_image.image

    @property
    @allure.step('Get keycard popup header')
    def keycard_header(self) -> str:
        return self._keycard_popup_header.text

    @property
    @allure.step('Get keycard instructions')
    def keycard_instructions(self) -> typing.List[str]:
        return [str(getattr(instruction, 'text', '')) for instruction in
                driver.findAllObjects(self._keycard_instruction_text.real_name)]

    @property
    @allure.step('Get all text fields')
    def get_text_fields(self) -> typing.List[str]:
        return driver.findAllObjects(self._field_object.real_name)

    @property
    @allure.step('Get seed phrases list')
    def get_seed_phrases(self) -> typing.List[str]:
        phrases = []
        for phrase_n in range(1, 13):
            object_name = f'SeedPhraseWordAtIndex-{phrase_n}'
            self._seed_phrase_panel.real_name['objectName'] = object_name
            phrases.append(str(self._seed_phrase_panel.object.textEdit.input.edit.text))
        return phrases

    @property
    @allure.step('Get keycard name in keypair')
    def keypair_name(self) -> str:
        return self._keypair_item.object.title

    @property
    @allure.step('Get info title in keypair')
    def keypair_info_title(self) -> str:
        return self._keypair_item.object.beneathTagsTitle

    @property
    @allure.step('Get account name in keypair')
    def keypair_account_name(self) -> str:
        return self._keypair_tag.object.title

    @property
    @allure.step('Get account color in keypair')
    def keypair_account_color(self) -> str:
        return str(self._keypair_tag.object.bgColor.name)

    @property
    @allure.step('Get keycard init state')
    def keycard_init_state(self) -> str:
        return self._keycard_init.object.state

    @property
    @allure.step('Get selection box "checked" state')
    def is_keypair_selection_box_checked(self) -> bool:
        return self._selection_box.object.checked

    @property
    @allure.step('Get next button "enabled" state')
    def is_next_button_enabled(self) -> bool:
        return driver.waitForObjectExists(self._next_button.real_name, configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled

    @allure.step('Click selection box on profile keypair')
    def click_selection_box_on_keypair(self):
        self._selection_box.click()
        return self

    @allure.step('Set pin')
    def input_pin(self, pin):
        driver.nativeType(pin)

    @allure.step('Click Next button')
    def click_next(self):
        self._next_button.click()
        time.sleep(1)
        return self

    @allure.step('Click reveal seed phrase button')
    def reveal_seed_phrase(self):
        self._reveal_seed_phrase_button.click()
        return self

    @allure.step('Confirm first word in seed phrase')
    def confirm_first_word(self, seed_phrase: typing.List[str]):
        word_index = int(str(self._seed_phrase_first_word_component.object.label).split('Word #')[1])
        seed_word = seed_phrase[word_index - 1]
        driver.type(self.get_text_fields[0], seed_word)
        return self

    @allure.step('Confirm second word in seed phrase')
    def confirm_second_word(self, seed_phrase: typing.List[str]):
        word_index = int(str(self._seed_phrase_second_word_component.object.label).split('Word #')[1])
        seed_word = seed_phrase[word_index - 1]
        driver.type(self.get_text_fields[1], seed_word)
        return self

    @allure.step('Confirm third word in seed phrase')
    def confirm_third_word(self, seed_phrase: typing.List[str]):
        word_index = int(str(self._seed_phrase_third_word_component.object.label).split('Word #')[1])
        seed_word = seed_phrase[word_index - 1]
        driver.type(self.get_text_fields[2], seed_word)
        return self

    @allure.step('Name keycard')
    def name_keycard(self, name: str):
        driver.type(self.get_text_fields[0], name)
        return self

    @allure.step('Name account')
    def name_account(self, name: str):
        driver.type(self.get_text_fields[0], name)
        return self

    @allure.step('Create keycard account with seed phrase')
    def create_keycard_account_with_seed_phrase(self, keycard_name: str, account_name: str):
        self.reveal_seed_phrase_and_confirm_words()
        self.name_keycard_and_account(keycard_name, account_name)

    @allure.step('Reveal seed phrase and confirm words')
    def reveal_seed_phrase_and_confirm_words(self):
        time.sleep(1)
        self.click_next().reveal_seed_phrase()
        seed_phrases = self.get_seed_phrases
        self.click_next()
        self.confirm_first_word(seed_phrases).confirm_second_word(seed_phrases).confirm_third_word(seed_phrases)
        self.click_next()

    @allure.step('Name keycard and account')
    def name_keycard_and_account(self, keycard_name, account_name):
        self.name_keycard(keycard_name).click_next()
        self.name_account(account_name).click_next()

    @allure.step('Import keycard via seed phrase')
    def import_keycard_via_seed_phrase(self, seed_phrase_words: list, pin: str, keycard_name: str, account_name: str):
        self.input_seed_phrase(seed_phrase_words)
        self.name_keycard_and_account(keycard_name, account_name)
        self.input_pin(pin)
        self.input_pin(pin)
        self.click_next()

    def input_seed_phrase(self, seed_phrase_words: list):
        self.click_next()
        if len(seed_phrase_words) == 12:
            self._seed_phrase_12_words_button.click()
        elif len(seed_phrase_words) == 18:
            self._seed_phrase_18_words_button.click()
        elif len(seed_phrase_words) == 24:
            self._seed_phrase_24_words_button.click()
        else:
            raise RuntimeError("Wrong amount of seed words", len(seed_phrase_words))
        for count, word in enumerate(seed_phrase_words, start=1):
            self._seed_phrase_word_text_edit.real_name['objectName'] = f'statusSeedPhraseInputField{count}'
            self._seed_phrase_word_text_edit.text = word
        self.click_next()
