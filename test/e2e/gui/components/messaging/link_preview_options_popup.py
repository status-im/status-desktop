import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.object import QObject
from gui.objects_map import names


class LinkPreviewOptionsPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._show_for_this_message_item = QObject(names.show_for_this_message_StatusMenuItem)
        self._always_show_item = QObject(names.always_show_previews_StatusMenuItem)
        self._never_show_item = QObject(names.never_show_previews_StatusMenuItem)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._show_for_this_message_item.wait_until_appears(timeout_msec)
        return self

    @allure.step('Wait until hidden {0}')
    def wait_until_hidden(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._show_for_this_message_item.wait_until_hidden(timeout_msec)
        return self

    @allure.step('Verify all preview items are present')
    def are_all_options_visible(self):
        assert self._show_for_this_message_item.is_visible
        assert self._always_show_item.is_visible
        assert self._never_show_item.is_visible
