from gui.components.onboarding.help_us_improve_status_dialog import HelpUsImproveStatusDialog
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names, onboarding_names


class HelpUsImproveStatusView(QObject):
    def __init__(self):
        super().__init__(onboarding_names.helpUsImproveStatusPage)
        self.share_usage_data_button = Button(onboarding_names.shareUsageDataButton)
        self.not_now_button = Button(onboarding_names.notNowButton)
        self.info_button = Button(onboarding_names.infoButton)

    def open_info_popup(self):
        self.info_button.click()
        return HelpUsImproveStatusDialog().wait_until_appears()
