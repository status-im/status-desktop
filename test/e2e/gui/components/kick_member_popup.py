import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class KickMemberPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._kick_confirm_button = Button(names.confirm_kick_StatusButton)

    @allure.step('Confirm kicking member')
    def confirm_kicking(self):
        self._kick_confirm_button.click()
