import typing

import allure

import configs
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class BackUpYourSeedPhrasePopUp(QObject):

    def __init__(self):
        super().__init__(names.backUpSeedModal)
        self._scroll = Scroll(names.generalView_StatusScrollView)
        self._i_have_a_pen_and_paper_check_box = CheckBox(names.mainWallet_AddEditAccountPopup_HavePenAndPaperCheckBox)
        self._i_know_where_i_ll_store_it_check_box = CheckBox(
            names.mainWallet_AddEditAccountPopup_StoringSeedPhraseConfirmedCheckBox)
        self._i_am_ready_to_write_down_seed_phrase_check_box = CheckBox(
            names.mainWallet_AddEditAccountPopup_SeedPhraseWrittenCheckBox)
        self._primary_button = Button(names.mainWallet_AddEditAccountPopup_PrimaryButton)
        self._reveal_seed_phrase_button = Button(names.mainWallet_AddEditAccountPopup_RevealSeedPhraseButton)
        self._seed_phrase_panel = QObject(names.confirmSeedPhrasePanel_StatusSeedPhraseInput)
        self._seed_phrase_word_component = QObject(names.mainWallet_AddEditAccountPopup_EnterSeedPhraseWordComponent)
        self._prove_word_seed_phrase_text_edit = TextEdit(names.mainWallet_AddEditAccountPopup_EnterSeedPhraseWord)
        self._acknowledge_check_box = CheckBox(names.mainWallet_AddEditAccountPopup_SeedBackupAknowledgeCheckBox)
        self._seed_phrase_name_text_edit = TextEdit(names.mainWallet_AddEditAccountPopup_GeneratedSeedPhraseKeyName)
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

    @allure.step('Click next button')
    def next(self):
        self._primary_button.click()
        return self

    @allure.step('Click reveal seed phrase button')
    def reveal_seed_phrase(self):
        self._reveal_seed_phrase_button.click()
        return self

    @allure.step('Get seed phrases list')
    def get_seed_phrases(self):
        phrases = []
        for phrase_n in range(1, 13):
            object_name = f'SeedPhraseWordAtIndex-{phrase_n}'
            self._seed_phrase_panel.real_name['objectName'] = object_name
            phrases.append(str(self._seed_phrase_panel.object.textEdit.input.edit.text))
        return phrases

    @allure.step('Confirm word in seed phrase')
    def confirm_word(self, seed_phrase: typing.List[str]):
        word_index = int(str(self._seed_phrase_word_component.object.label).split('Word #')[1])
        seed_word = seed_phrase[word_index - 1]
        self._prove_word_seed_phrase_text_edit.text = seed_word
        return self

    @allure.step('Set aknowledge checkbox')
    def set_acknowledge(self, value: bool):
        self._acknowledge_check_box.set(value)
        return self

    @allure.step('Set seed phrase name')
    def set_seed_phrase_name(self, value: str):
        self._seed_phrase_name_text_edit.text = value
        return self

    def complete_and_delete_seed_phrase(self):
        self._complete_and_delete_button.click()
        return self

    @allure.step('Wait until hidden {0}')
    def wait_until_hidden(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._seed_phrase_name_text_edit.wait_until_hidden()

    @allure.step('Generate seed phrase')
    def back_up_seed_phrase(self, name: str):
        self.set_have_pen_and_paper(True).set_ready_to_write_seed_phrase(True).set_know_where_store_it(True)
        self.next().reveal_seed_phrase()
        seed_phrases = self.get_seed_phrases()
        self.next().confirm_word(seed_phrases)
        self.next().confirm_word(seed_phrases)
        self.next().set_acknowledge(True)
        self.next().set_seed_phrase_name(name)
        self.next().wait_until_hidden()
