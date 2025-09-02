import allure

import driver
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.keep_or_delete_recovery_phrase import KeepOrDeleteRecoveryPhrase
from gui.objects_map import names


class ConfirmRecoveryPhrase(QObject):
    def __init__(self):
        super().__init__(names.confirmRecoveryPhraseModal)

        self.seed_input = QObject(names.seedInput)
        self.continue_button = Button(names.continueButton)

    @allure.step('Fill in the grid and click continue')
    def fill_the_grid_and_continue(self, words):

        cells_to_fill = driver.findAllObjects(self.seed_input.real_name)

        for cell in cells_to_fill:
            word_to_confirm_index = int(str(cell['objectName']).split('_')[1])
            word_to_put = words[word_to_confirm_index]
            self.seed_input.real_name['objectName'] = f'seedInput_{word_to_confirm_index}'
            self.seed_input.set_text_property(word_to_put)

        assert self.continue_button.is_visible
        self.continue_button.click()
        return KeepOrDeleteRecoveryPhrase()
