import logging
import time

import allure

import constants
import driver
from gui.elements.os.mac.button import Button
from gui.elements.os.mac.object import NativeObject
from gui.elements.os.mac.text_edit import TextEdit
from scripts.utils.system_path import SystemPath

_logger = logging.getLogger(__name__)


class OpenFileDialog(NativeObject):

    def __init__(self):
        super(OpenFileDialog, self).__init__('openFileDialog')
        self._open_button = Button('openButton')

    def _open_go_to_dialog(self, attempt: int = 2):
        # Set focus
        driver.nativeMouseClick(int(self.bounds.x + 10), int(self.bounds.y + 10), driver.Qt.LeftButton)
        time.sleep(1)
        driver.nativeType(f'<{constants.commands.OPEN_GOTO}>')
        try:
            return _GoToDialog().wait_until_appears()
        except LookupError as err:
            _logger.debug(err)
            if attempt:
                self._open_go_to_dialog(attempt - 1)
            else:
                raise err

    @allure.step('Open file')
    def open_file(self, fp: SystemPath):
        # Set focus
        driver.nativeMouseClick(int(self.bounds.x + 10), int(self.bounds.y + 10), driver.Qt.LeftButton)
        time.sleep(1)
        driver.nativeType(f'<{constants.commands.OPEN_GOTO}>')
        self._open_go_to_dialog().select_file(fp)
        self._open_button.click()
        self.wait_until_hidden()


class _GoToDialog(NativeObject):

    def __init__(self):
        self.go_to_text_edit = TextEdit('pathTextField')
        super(_GoToDialog, self).__init__('goToDialog')

    @allure.step('Select file')
    def select_file(self, fp: SystemPath):
        self.go_to_text_edit.text = str(fp)
        driver.nativeMouseClick(int(self.bounds.x + 10), int(self.bounds.y + 10), driver.Qt.LeftButton)
        time.sleep(1)
        driver.nativeType(f'<{constants.commands.RETURN}>')
        self.wait_until_hidden()
