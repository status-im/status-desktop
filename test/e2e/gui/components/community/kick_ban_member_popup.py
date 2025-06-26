import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import communities_names


class KickBanMemberPopup(QObject):

    def __init__(self):
        super().__init__(communities_names.kickBanMemberPopup)
        self.ban_confirm_button = Button(communities_names.ban_StatusButton)
        self.kick_confirm_button = Button(communities_names.confirm_kick_StatusButton)

    @allure.step('Confirm banning member')
    def confirm_banning(self):
        self.ban_confirm_button.click()
        return self

    @allure.step('Confirm kicking member')
    def confirm_kicking(self):
        self.kick_confirm_button.click()
        return self
        