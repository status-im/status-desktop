import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class LeaveGroupPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._leave_button = Button(names.leave_StatusButton)

    @allure.step("Confirm leaving group")
    def confirm_leaving(self):
        self._leave_button.click()
        self.wait_until_hidden()
