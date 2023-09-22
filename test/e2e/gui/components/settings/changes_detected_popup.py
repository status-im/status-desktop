import allure

from gui.components.base_popup import BasePopup
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
from gui.elements.qt.text_edit import TextEdit


class ChangesDetectedToastMessage(QObject):

    def __init__(self):
        super(ChangesDetectedToastMessage, self).__init__('mainWindow_settingsDirtyToastMessage_SettingsDirtyToastMessage')
        self._save_button = Button('settingsSave_StatusButton')

    @allure.step('Save changes')
    def save(self):
        self._save_button.click()
        self.wait_until_hidden()
