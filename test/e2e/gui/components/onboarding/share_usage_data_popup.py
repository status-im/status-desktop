from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names, onboarding_names


class HelpUsImproveStatusView(QObject):
    def __init__(self):
        super().__init__(onboarding_names.helpUsImproveStatusPage)
        self.share_usage_data_button = Button(onboarding_names.shareUsageDataButton)
        self.not_now_button = Button(onboarding_names.notNowButton)
