import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class ChangesDetectedToastMessage(QObject):

    def __init__(self):
        super(ChangesDetectedToastMessage, self).__init__(
            names.mainWindow_settingsDirtyToastMessage_SettingsDirtyToastMessage)
        self._save_button = Button(names.settingsSave_StatusButton)

    @allure.step('Save changes')
    def save(self):
        self._save_button.click()
        self.wait_until_hidden()
