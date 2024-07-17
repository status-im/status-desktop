import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class ShareUsageDataPopup(BasePopup):

    def __init__(self):
        self._not_now_button = Button(names.not_now_StatusButton )
        self._share_usage_data_button = Button(names.share_usage_data_StatusButton)
        super(ShareUsageDataPopup, self).__init__()

    @allure.step('Confirm all')
    def skip(self):
        self._not_now_button.click()
        self.wait_until_hidden()
