import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class PinnedMessagesPanel(QObject):

    def __init__(self):
        super().__init__(names.chatInfoPinsList)
        self._info_button = Button(names.chatToolbar_infoButton)
        self._unpin_menu_item = Button(names.pinnedMessagesPanel_unpin)
        self._pinned_message_details = QObject(names.pinMessageDetails_in_pinsPanel)

    @allure.step('Unpin message')
    def unpin_message(self):
        self._pinned_message_details.wait_until_appears()
        self._pinned_message_details.right_click()
        self._unpin_menu_item.wait_until_appears().click()
        return self

    @allure.step('Close pinned messages panel')
    def close(self):
        self._info_button.click()
        self.wait_until_hidden()
