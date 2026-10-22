import allure

import configs
from gui.elements.object import QObject
from gui.objects_map import messaging_names


class ChatInputEditMenu(QObject):

    def __init__(self):
        super().__init__(messaging_names.chatInputEditMenu)
        self._spelling_suggestion_item = QObject(messaging_names.spellingSuggestion_StatusMenuItem)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        super().wait_until_appears(timeout_msec)
        return self

    @allure.step('Select spelling suggestion {1}')
    def select_spelling_suggestion(self, suggestion: str):
        self._spelling_suggestion_item.real_name['objectName'] = f'spellingSuggestion_{suggestion}'
        self._spelling_suggestion_item.wait_until_appears().click()
        self._spelling_suggestion_item.real_name.pop('objectName', None)
        return self
