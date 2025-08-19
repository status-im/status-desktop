import re
import time
import typing

import allure

from gui.components.confirm_recovery_phrase import ConfirmRecoveryPhrase
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
        self.reveal_recovery_phrase_button = Button(names.reveal_recovery_phrase_StatusButton)
        self.seed_grid_item = QObject(names.seedGridItem)
        self.i_have_backed_up_phrase_button = Button(names.iVeBackedUpPhraseButton)

    @allure.step("Click I've backed up phrase button")
    def i_have_backed_up_phrase(self):
        self.i_have_backed_up_phrase_button.click()
        return ConfirmRecoveryPhrase()

    @allure.step('Click reveal seed phrase button')
    def reveal_seed_phrase(self):
        self.reveal_recovery_phrase_button.click()
        return self

    @allure.step('Get list of words in mnemonic')
    def get_seed_words(self):
        words = []
        for word_number in range(1, 13):
            object_name = f'seedWordText_{word_number}'
            self.seed_grid_item.real_name['objectName'] = object_name
            words.append(str(self.seed_grid_item.object.text))
        return words

    @allure.step('Back up seed phrase and delete')
    def back_up_seed_phrase_and_delete(self):
        self.reveal_seed_phrase()
        words = self.get_seed_words()
        grid = self.i_have_backed_up_phrase()
        keep_or_delete = grid.fill_the_grid_and_continue(words=words)
        keep_or_delete.remove_seed_checkbox.set(True)
        keep_or_delete.done_button.click()
