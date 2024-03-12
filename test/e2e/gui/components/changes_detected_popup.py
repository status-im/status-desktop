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
    def click_save_changes_button(self):
        self._save_button.click()

    @allure.step('Check if save changes button is visible')
    def is_save_changes_button_visible(self):
        return self._save_button.is_visible


class PermissionsChangesDetectedToastMessage(QObject):

    def __init__(self):
        super().__init__(communities_names.editPermissionView_settingsDirtyToastMessage_SettingsDirtyToastMessage)
        self._update_permission_button = Button(communities_names.editPermissionView_Save_changes_StatusButton)

    @allure.step('Update permission')
    def update_permission(self):
        self._update_permission_button.click()
        self.wait_until_hidden()
