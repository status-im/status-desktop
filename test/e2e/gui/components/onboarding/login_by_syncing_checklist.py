import time

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import onboarding_names
from gui.elements.check_box import CheckBox


class LogInBySyncingChecklist(QObject):
    def __init__(self):
        super().__init__(onboarding_names.statusDialog)
        self.connect_both_devices_option = CheckBox(onboarding_names.connectBothDevicesOption)
        self.make_sure_you_are_logged_option = CheckBox(onboarding_names.makeSureYouAreLoggedOption)
        self.disable_the_firewall_option = CheckBox(onboarding_names.disableTheFirewallOption)
        self.cancel_button = Button(onboarding_names.cancelButton)
        self.continue_button = Button(onboarding_names.continueButton)

    def complete(self):
        self.connect_both_devices_option.set(True)
        self.make_sure_you_are_logged_option.set(True)
        self.disable_the_firewall_option.set(True)
        assert self.continue_button.is_enabled
        self.continue_button.click()
