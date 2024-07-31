import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class NicknamePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._nickname_field = TextEdit(names.nickname_edit_TextEdit)
        self._cancel_button = Button(names.cancel_nickname_StatusFlatButton)
        self._add_nickname_button = Button(names.add_nickname_StatusButton)
        self._remove_nickname = Button(names.remove_nickname_StatusFlatButton)
        self._change_nickname = Button(names.change_nickname_StatusButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._nickname_field.wait_until_appears(timeout_msec)
        return self

    @allure.step('Enter nickname')
    def enter_nickname(self, name: str):
        self._nickname_field.text = name

    @allure.step('Add nickname')
    def add_nickname(self):
        self._add_nickname_button.click()

    @allure.step('Change nickname')
    def change_nickname(self):
        self._change_nickname.click()

    @allure.step('Remove nickname')
    def remove_nickname(self):
        self._remove_nickname.click()
