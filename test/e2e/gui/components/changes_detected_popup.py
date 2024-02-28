import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names, communities_names


class ChangesDetectedToastMessage(QObject):

    def __init__(self):
        super(ChangesDetectedToastMessage, self).__init__(
            names.mainWindow_settingsDirtyToastMessage_SettingsDirtyToastMessage)
        self._save_button = Button(names.mainWindow_Save_changes_StatusButton)

    @allure.step('Save changes')
    def save(self):
        self._save_button.click()
        self.wait_until_hidden()


class PermissionsChangesDetectedToastMessage(QObject):

    def __init__(self):
        super().__init__(communities_names.editPermissionView_settingsDirtyToastMessage_SettingsDirtyToastMessage)
        self._update_permission_button = Button(communities_names.editPermissionView_Save_changes_StatusButton)

    @allure.step('Update permission')
    def update_permission(self):
        self._update_permission_button.click()
        self.wait_until_hidden()
