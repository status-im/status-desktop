import allure
import pyperclip

import configs
import driver
from gui.components.base_popup import BasePopup
from gui.components.profile_popup import ProfilePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class OnlineIdentifier(BasePopup):

    def __init__(self):
        super(OnlineIdentifier, self).__init__()
        self.always_active_button = Button(names.userContextmenu_AlwaysActiveButton)
        self.inactive_button = Button(names.userContextmenu_InActiveButton)
        self.automatic_button = Button(names.userContextmenu_AutomaticButton)
        self.view_my_profile_button = Button(names.userContextMenu_ViewMyProfileAction)
        self.copy_link_to_profile_button = QObject(names.userContextMenu_CopyLinkToProfile)
        self.user_name_text_label = TextLabel(names.userLabel_StyledText)
        self.identicon_ring = QObject(names.o_StatusIdenticonRing)

    @property
    @allure.step('Get user name')
    def get_user_name(self) -> str:
        return self.user_name_text_label.text

    @allure.step('Set user state online')
    def set_user_state_online(self):
        self.always_active_button.click()
        self.wait_until_hidden()

    @allure.step('Set user state offline')
    def set_user_state_offline(self):
        self.inactive_button.click()
        self.wait_until_hidden()

    @allure.step('Open Profile popup from online identifier')
    def open_profile_popup_from_online_identifier(self) -> ProfilePopup:
        self.view_my_profile_button.click()
        return ProfilePopup().wait_until_appears()

    @allure.step('Copy link to profile from online identifier')
    def copy_link_to_profile(self) -> str:
        self.copy_link_to_profile_button.click()
        link = str(pyperclip.paste())
        return link
