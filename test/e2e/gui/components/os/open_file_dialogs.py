import logging

import allure

import driver
from gui.elements.text_edit import TextEdit
from gui.elements.window import Window
from gui.objects_map import names
from scripts.utils.system_path import SystemPath

LOG = logging.getLogger(__name__)


class OpenFileDialog(Window):

    def __init__(self):
        super(OpenFileDialog, self).__init__(names.chooseAnImageALogo_QQuickWindow)
        self._file_path_text_edit = TextEdit(names.titleBar_currentPathField_TextField)

    @allure.step('Open file')
    def open_file(self, fp: SystemPath):
        driver.type(self._file_path_text_edit.object, "<Ctrl+A>")
        driver.type(self._file_path_text_edit.object, str(fp))
        driver.type(self._file_path_text_edit.object, "<Return>")
        self.wait_until_hidden()
