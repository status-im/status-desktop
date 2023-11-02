import time
import typing

import allure

import driver
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from scripts.tools.image import Image


class CreateNewKeycardAccountSeedPhrasePopup(BasePopup):

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
        self._field_object = QObject('edit_TextEdit')
        self._keypair_item = QObject('o_KeyPairItem')
        self._keypair_tag = QObject('o_StatusListItemTag')

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
    @allure.step('Get keycard name in preview')
    def keycard_preview_name(self) -> str:
        return self._keypair_item.object.title

    @property
    @allure.step('Get account name in preview')
    def account_preview_name(self) -> str:
        return self._keypair_tag.object.title

    @property
    @allure.step('Get color in preview')
    def preview_color(self) -> str:
        return str(self._keypair_item.object.beneathTagsIconColor.name)

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

    @allure.step('Name account')
    def name_account(self, name: str):
        driver.type(self.get_text_fields[0], name)

    @allure.step('Create keycard account with seed phrase')
    def create_keycard_account_with_seed_phrase(self, keycard_name: str, account_name: str):
        time.sleep(1)
        self.click_next().reveal_seed_phrase()
        seed_phrases = self.get_seed_phrases
        self.click_next()
        self.confirm_first_word(seed_phrases).confirm_second_word(seed_phrases).confirm_third_word(seed_phrases)
        self.click_next().name_keycard(keycard_name)
        self.click_next().name_account(account_name)
        self.click_next()
