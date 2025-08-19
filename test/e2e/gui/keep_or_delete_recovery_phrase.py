from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.objects_map import names


class KeepOrDeleteRecoveryPhrase(QObject):
    def __init__(self):
        super().__init__(names.keepOrDeleteRecoveryPhraseModal)

        self.remove_seed_checkbox = CheckBox(names.removeSeedCheckBox)
        self.done_button = Button(names.doneButton)