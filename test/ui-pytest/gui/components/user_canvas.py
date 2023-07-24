import time

import configs
import constants
import driver
from gui.components.profile_popup import ProfilePopup
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
from gui.elements.qt.text_label import TextLabel


class UserCanvas(QObject):

    def __init__(self):
        super(UserCanvas, self).__init__('o_StatusListView')
        self._always_active_button = Button('userContextmenu_AlwaysActiveButton')
        self._inactive_button = Button('userContextmenu_InActiveButton')
        self._automatic_button = Button('userContextmenu_AutomaticButton')
        self._view_my_profile_button = Button('userContextMenu_ViewMyProfileAction')
        self._user_name_text_label = TextLabel('userLabel_StyledText')
        self._profile_image = QObject('o_StatusIdenticonRing')

    @property
    def user_name(self) -> str:
        return self._user_name_text_label.text

    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        super(UserCanvas, self).wait_until_appears(timeout_msec)
        time.sleep(1)
        return self

    def set_user_state_online(self):
        self._always_active_button.click()
        self.wait_until_hidden()

    def set_user_state_offline(self):
        self._inactive_button.click()
        self.wait_until_hidden()

    def set_user_automatic_state(self):
        self._automatic_button.click()
        self.wait_until_hidden()

    def open_profile_popup(self) -> ProfilePopup:
        self._view_my_profile_button.click()
        return ProfilePopup().wait_until_appears()

    def is_user_image_contains(self, text: str):
        # To remove all artifacts, the image cropped.
        self._profile_image.image.crop(
            driver.UiTypes.ScreenRectangle(
                5, 5, self._profile_image.image.width-10, self._profile_image.image.height-10
            ))
        return self._profile_image.image.has_text(text, constants.tesseract.text_on_profile_image)
