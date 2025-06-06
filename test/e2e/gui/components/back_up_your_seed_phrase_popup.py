import re
import time
import typing

import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class BackUpYourSeedPhrasePopUp(QObject):

    def __init__(self):
        super().__init__(names.backUpSeedModal)
        self.back_up_seed_modal = QObject(names.backUpSeedModal)
        self._scroll = Scroll(names.generalView_StatusScrollView)
        self._i_have_a_pen_and_paper_check_box = CheckBox(names.i_have_a_pen_and_paper_StatusCheckBox)
        self._i_know_where_i_ll_store_it_check_box = CheckBox(names.i_know_where_I_ll_store_it_StatusCheckBox)
        self._i_am_ready_to_write_down_seed_phrase_check_box = CheckBox(names.i_am_ready_to_write_down_StatusCheckBox)
        self._not_now_button = Button(names.not_Now_StatusButton)
        self._confirm_seed_phrase_button = Button(names.confirm_Seed_Phrase_StatusButton)
        self._reveal_seed_phrase_button = Button(names.reveal_seed_phrase_StatusButton)
        self._continue_button = Button(names.continue_StatusButton)
        self._seed_phrase_panel = QObject(names.backup_seed_phrase_popup_StatusSeedPhraseInput_placeholder)
        self._seed_phrase_first_word_component = QObject(names.confirmFirstWord)
        self._prove_first_word_seed_phrase_text_edit = TextEdit(names.confirmFirstWord_inputText)
        self._seed_phrase_second_word_component = QObject(names.confirmSecondWord)
        self._prove_second_word_seed_phrase_text_edit = TextEdit(names.confirmSecondWord_inputText)
        self._acknowledge_check_box = CheckBox(names.i_acknowledge_StatusCheckBox)
        self._complete_and_delete_button = Button(names.completeAndDeleteSeedPhraseButton)

    @allure.step('Set have pen and paper checkbox')
    def set_have_pen_and_paper(self, value: bool):
        self._i_have_a_pen_and_paper_check_box.set(value)
        return self

    @allure.step('Set ready to write checkbox')
    def set_ready_to_write_seed_phrase(self, value: bool):
        self._i_am_ready_to_write_down_seed_phrase_check_box.set(value)
        return self

    @allure.step('Set know where will store it checkbox')
    def set_know_where_store_it(self, value: bool):
        self._scroll.vertical_scroll_down(self._i_know_where_i_ll_store_it_check_box)
        self._i_know_where_i_ll_store_it_check_box.set(value)
        return self

    @allure.step('Click confirm seed phrase button')
    def confirm_seed_phrase(self):
        self._confirm_seed_phrase_button.click()
        return self

    @allure.step('Click continue seed phrase button')
    def continue_seed_phrase(self):
        self._continue_button.click()
        return self

    @allure.step('Click reveal seed phrase button')
    def reveal_seed_phrase(self):
        time.sleep(1)
        self._reveal_seed_phrase_button.click()
        return self

    @allure.step('Get seed phrases list')
    def get_seed_phrases(self):
        phrases = []
        for phrase_n in range(1, 13):
            object_name = f'ConfirmSeedPhrasePanel_StatusSeedPhraseInput_{phrase_n}'
            self._seed_phrase_panel.real_name['objectName'] = object_name
            phrases.append(str(self._seed_phrase_panel.object.textEdit.input.edit.text))
        return phrases

    @allure.step('Confirm first word in seed phrase')
    def confirm_first_word(self, seed_phrase: typing.List[str]):
        word_index = int(re.findall(r'\d+', str(self._seed_phrase_first_word_component.object.titleText))[0])
        seed_word = seed_phrase[word_index - 1]
        self._prove_first_word_seed_phrase_text_edit.text = seed_word
        return self

    @allure.step('Confirm second word in seed phrase')
    def confirm_second_word(self, seed_phrase: typing.List[str]):
        word_index = int(re.findall(r'\d+', str(self._seed_phrase_second_word_component.object.titleText))[0])
        seed_word = seed_phrase[word_index - 1]
        self._prove_second_word_seed_phrase_text_edit.text = seed_word
        return self

    @allure.step('Set aknowledge checkbox')
    def set_acknowledge(self, value: bool):
        time.sleep(1)
        self._acknowledge_check_box.set(value)
        return self

    @allure.step('Complete and delete seed phrase')
    def complete_and_delete_seed_phrase(self):
        self._complete_and_delete_button.click()
        return self

    @allure.step('Back up seed phrase')
    def back_up_seed_phrase(self):
        self.set_have_pen_and_paper(True).set_ready_to_write_seed_phrase(True).set_know_where_store_it(True)
        self.confirm_seed_phrase()
        self.reveal_seed_phrase()
        seed_phrases = self.get_seed_phrases()
        self.confirm_seed_phrase()
        self.confirm_first_word(seed_phrases)
        self.continue_seed_phrase()
        self.confirm_second_word(seed_phrases)
        self.continue_seed_phrase()
        self.set_acknowledge(True)
        self.complete_and_delete_seed_phrase().wait_until_hidden()
