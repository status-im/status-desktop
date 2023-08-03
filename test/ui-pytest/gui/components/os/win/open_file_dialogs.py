import logging

import allure

from gui.elements.os.win.button import Button
from gui.elements.os.win.object import NativeObject
from gui.elements.os.win.text_edit import TextEdit
from scripts.utils.system_path import SystemPath

_logger = logging.getLogger(__name__)


class OpenFileDialog(NativeObject):

    def __init__(self):
        super().__init__('file_Dialog')
        self._file_path_text_edit = TextEdit('choose_file_Edit')
        self._select_button = Button('choose_Open_Button')

    @allure.step('Open file')
    def open_file(self, fp: SystemPath):
        self._file_path_text_edit.text = str(fp)
        self._select_button.click()
        self.wait_until_hidden()
