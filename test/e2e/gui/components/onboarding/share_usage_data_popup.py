from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names, onboarding_names


# this is old modal shown on relogin
class ShareUsageDataPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self.not_now_button = Button(names.not_now_StatusButton)
        self.share_usage_data_button = Button(names.share_usage_data_StatusButton)


# this is new modal shown for initial onboarding
class HelpUsImproveStatusView(QObject):
    def __init__(self):
        super().__init__(onboarding_names.helpUsImproveStatusPage)
        self.share_usage_data_button = Button(onboarding_names.shareUsageDataButton)
        self.not_now_button = Button(onboarding_names.notNowButton)
