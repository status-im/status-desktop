import typing

import configs
from drivers.SquishDriver import *

from .base_popup import BasePopup


class BackUpYourSeedPhrasePopUp(BasePopup):

    def __init__(self):
        super(BackUpYourSeedPhrasePopUp, self).__init__()
        self._i_have_a_pen_and_paper_check_box = CheckBox('mainWallet_AddEditAccountPopup_HavePenAndPaperCheckBox')
        self._i_know_where_i_ll_store_it_check_box = CheckBox(
            'mainWallet_AddEditAccountPopup_StoringSeedPhraseConfirmedCheckBox')
        self._i_am_ready_to_write_down_seed_phrase_check_box = CheckBox(
            'mainWallet_AddEditAccountPopup_SeedPhraseWrittenCheckBox')
        self._primary_button = Button('mainWallet_AddEditAccountPopup_PrimaryButton')
        self._reveal_seed_phrase_button = Button('mainWallet_AddEditAccountPopup_RevealSeedPhraseButton')
        self._seed_phrase_panel = BaseElement('confirmSeedPhrasePanel_StatusSeedPhraseInput')
        self._seed_phrase_word_component = BaseElement('mainWallet_AddEditAccountPopup_EnterSeedPhraseWordComponent')
        self._prove_word_seed_phrase_text_edit = TextEdit('mainWallet_AddEditAccountPopup_EnterSeedPhraseWord')
        self._acknowledge_check_box = CheckBox('mainWallet_AddEditAccountPopup_SeedBackupAknowledgeCheckBox')
        self._seed_phrase_name_text_edit = TextEdit('mainWallet_AddEditAccountPopup_GeneratedSeedPhraseKeyName')

    def set_have_pen_and_paper(self, value: bool):
        self._i_have_a_pen_and_paper_check_box.set(value)
        return self

    def set_ready_to_write_seed_phrase(self, value: bool):
        self._i_am_ready_to_write_down_seed_phrase_check_box.set(value)
        return self

    def set_know_where_store_it(self, value: bool):
        self._i_know_where_i_ll_store_it_check_box.set(value)
        return self

    def next(self):
        self._primary_button.click()
        return self

    def reveal_seed_phrase(self):
        self._reveal_seed_phrase_button.click()
        return self

    def get_seed_phrases(self):
        phrases = []
        for phrase_n in range(1, 13):
            object_name = f'SeedPhraseWordAtIndex-{phrase_n}'
            self._seed_phrase_panel.object_name['objectName'] = object_name
            phrases.append(str(self._seed_phrase_panel.object.textEdit.input.edit.text))
        return phrases

    def confirm_word(self, seed_phrase: typing.List[str]):
        word_index = int(str(self._seed_phrase_word_component.object.label).split('Word #')[1])
        seed_word = seed_phrase[word_index - 1]
        self._prove_word_seed_phrase_text_edit.text = seed_word
        return self

    def set_acknowledge(self, value: bool):
        self._acknowledge_check_box.set(value)
        return self

    def set_seed_phrase_name(self, value: str):
        self._seed_phrase_name_text_edit.text = value
        return self

    def wait_until_hidden(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        self._seed_phrase_name_text_edit.wait_until_hidden()

    def generate_seed_phrase(self, name: str):
        self.set_have_pen_and_paper(True).set_ready_to_write_seed_phrase(True).set_know_where_store_it(True)
        self.next().reveal_seed_phrase()
        seed_phrases = self.get_seed_phrases()
        self.next().confirm_word(seed_phrases)
        self.next().confirm_word(seed_phrases)
        self.next().set_acknowledge(True)
        self.next().set_seed_phrase_name(name)
        self.next().wait_until_hidden()
