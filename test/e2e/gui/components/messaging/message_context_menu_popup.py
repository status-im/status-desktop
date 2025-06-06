import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.object import QObject
from gui.objects_map import messaging_names


class MessageContextMenuPopup(QObject):

    def __init__(self):
        super().__init__(messaging_names.messageContextView)
        self._emoji_reaction = QObject(messaging_names.o_EmojiReaction)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._emoji_reaction.wait_until_appears(timeout_msec)
        return self

    @allure.step('Add reaction to message')
    def add_reaction_to_message(self, occurrence: int):
        # for 1st element occurrence is absent in real name, for other elements it starts from 2
        if occurrence > 1:
            self._emoji_reaction.real_name['occurrence'] = occurrence
        self._emoji_reaction.click()
