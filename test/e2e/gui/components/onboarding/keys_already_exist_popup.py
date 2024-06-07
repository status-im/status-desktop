import typing

import allure

import configs
import driver
from gui.components.base_popup import BasePopup
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class KeysAlreadyExistPopup(BasePopup):
    def __init__(self):
        super(KeysAlreadyExistPopup, self).__init__()
        self._keys_exist_title = QObject(names.headline_StatusTitleSubtitle)
        self._keys_exist_text = TextLabel(names.keys_exist_StatusBaseText)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._keys_exist_title.wait_until_appears(timeout_msec)
        return self

    @allure.step('Get title of key exist popup')
    def get_key_exist_title(self) -> str:
        return str(self._keys_exist_title.object.title)

    @allure.step('Get text of key exist popup')
    def get_text_labels(self) -> typing.List[str]:
        text_labels = []
        for item in driver.findAllObjects(self._keys_exist_text.real_name):
            text_labels.append(str(item.text))
        return text_labels
