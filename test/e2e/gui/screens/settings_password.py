import allure

import configs.timeouts
import driver
from driver.objects_access import walk_children
from gui.components.change_password_popup import ChangePasswordPopup
from gui.components.social_links_popup import SocialLinksPopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class ChangePasswordView(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_PasswordView)
        self._scroll_view = Scroll(names.settingsContentBaseScrollView_Flickable)
        self._change_password_button = Button(names.change_password_menu_change_password_button)
        self._current_password_text_field = TextEdit(names.change_password_menu_current_password)
        self._new_password_text_field = TextEdit(names.change_password_menu_new_password)
        self._confirm_password_text_field = TextEdit(names.change_password_menu_new_password_confirm)

    @allure.step('Fill in the form, submit and sign out')
    def change_password(self, old_pwd: str, new_pwd: str):
        self._current_password_text_field.text = old_pwd
        self._new_password_text_field.text = new_pwd
        self._confirm_password_text_field.text = new_pwd
        self._change_password_button.click()
        return ChangePasswordPopup()

