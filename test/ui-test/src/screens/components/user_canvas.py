import time

import configs
from drivers.SquishDriver import *


class UserCanvas(BaseElement):

    def __init__(self):
        super(UserCanvas, self).__init__('o_StatusListView')
        self._always_active_button = Button('userContextmenu_AlwaysActiveButton')
        self._inactive_button = Button('userContextmenu_InActiveButton')
        self._automatic_button = Button('userContextmenu_AutomaticButton')
        self._view_my_profile_button = Button('userContextMenu_ViewMyProfileAction')

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
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

    def open_profile_popup(self):
        self._view_my_profile_button.click()
        # TODO: Return profile popup
