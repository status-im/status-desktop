import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.qt.button import Button
from gui.elements.qt.text_edit import TextEdit


class ColorSelectPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._hex_color_text_edit = TextEdit('communitySettings_ColorPanel_HexColor_Input')
        self._save_button = Button('communitySettings_SaveColor_Button')

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._hex_color_text_edit.wait_until_appears()
        return self

    @allure.step('Wait until hidden {0}')
    def wait_until_hidden(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._hex_color_text_edit.wait_until_hidden()

    @allure.step('Select color {1}')
    def select_color(self, value: str):
        self._hex_color_text_edit.text = value
        self._save_button.click()
        self.wait_until_hidden()
