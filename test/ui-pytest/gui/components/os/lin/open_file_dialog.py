import allure

import constants.commands
import driver
from gui.elements.qt.button import Button
from gui.elements.qt.text_edit import TextEdit
from gui.elements.qt.window import Window
from scripts.utils.system_path import SystemPath


class OpenFileDialog(Window):

    def __init__(self):
        super(OpenFileDialog, self).__init__('please_choose_an_image_QQuickWindow')
        self._path_text_edit = TextEdit('titleBar_textInput_TextInputWithHandles')
        self._open_button = Button('please_choose_an_image_Open_Button')

    @allure.step('Open file')
    def open_file(self, fp: SystemPath):
        self._path_text_edit.text = str(fp)
        driver.type(self._path_text_edit.object, f'<{constants.commands.RETURN}>')
        self.wait_until_hidden()
