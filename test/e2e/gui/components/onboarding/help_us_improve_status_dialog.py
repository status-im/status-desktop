from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import onboarding_names


class HelpUsImproveStatusDialog(QObject):
    def __init__(self):
        super().__init__(onboarding_names.statusDialog)

        self.got_it_button = Button(onboarding_names.gotItButton)

    def close(self):
        self.got_it_button.click()
        self.wait_until_hidden()

