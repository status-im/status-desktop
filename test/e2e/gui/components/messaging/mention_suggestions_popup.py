import allure

import configs
from gui.elements.object import QObject
from gui.objects_map import messaging_names


class MentionSuggestionsPopup(QObject):

    def __init__(self):
        super().__init__(messaging_names.mainWindow_suggestionsBox)
        self._suggestion_list = QObject(messaging_names.mainWindow_suggestionBoxList)
        self._suggestion_item = QObject(messaging_names.suggestionsBox_mentionSuggestion_Rectangle)

    @staticmethod
    def mention_filter_text(display_name: str) -> str:
        name = (display_name or '').strip()
        if not name:
            return name
        if ' ' in name:
            return name.split()[0]
        return name if len(name) <= 24 else name[:24]

    @allure.step('Select mention suggestion {1}')
    def select(self, display_name: str, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self.wait_until_appears(timeout_msec)
        self._suggestion_list.wait_until_appears(timeout_msec)
        self._suggestion_item.real_name['objectName'] = display_name
        self._suggestion_item.wait_until_appears(timeout_msec).click()
        self.wait_until_hidden(timeout_msec)
        return self
