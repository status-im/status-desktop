import allure

import configs
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class EmojiPopup(QObject):
    def __init__(self):
        super(EmojiPopup, self).__init__(names.mainWallet_AddEditAccountPopup_AccountEmojiSearchBox)
        self._search_text_edit = TextEdit(names.mainWallet_AddEditAccountPopup_AccountEmojiSearchBox)
        self._emoji_item = QObject(names.mainWallet_AddEditAccountPopup_AccountEmoji)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._search_text_edit.wait_until_appears(timeout_msec)
        return self

    @allure.step('Select emoji')
    def select(self, name: str):
        self._search_text_edit.text = name
        self._emoji_item.real_name['objectName'] = 'statusEmoji_' + name
        self._emoji_item.click()
