import allure

import configs
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names, communities_names, wallet_names


class ChangesDetectedToastMessage(QObject):

    def __init__(self):
        super(ChangesDetectedToastMessage, self).__init__(
            names.mainWindow_settingsDirtyToastMessage_SettingsDirtyToastMessage)
        self._save_button = Button(names.mainWindow_Save_changes_StatusButton)

    @allure.step('Save changes')
    def click_save_changes_button(self):
        self._save_button.click()

    @allure.step('Check if save changes button is visible')
    def is_save_changes_button_visible(self) -> bool:
        return self._save_button.is_visible


class PermissionsChangesDetectedToastMessage(QObject):

    def __init__(self):
        super().__init__(communities_names.editPermissionView_settingsDirtyToastMessage_SettingsDirtyToastMessage)
        self._update_permission_button = Button(communities_names.editPermissionView_Update_permission_StatusButton)

    @allure.step('Update permission')
    def update_permission(self, max_attempts: int = 4):
        for attempt in range(1, max_attempts + 1):
            self._update_permission_button.click()
            try:
                # Use a shorter timeout per attempt, but allow multiple attempts
                self.wait_until_hidden(timeout_msec=configs.timeouts.PROCESS_TIMEOUT_SEC * 1000)
                # If we reach here, the popup is hidden - success!
                return
            except TimeoutError:
                if attempt < max_attempts:
                    # Continue to next attempt
                    continue
                else:
                    # Last attempt failed, re-raise the exception
                    raise


class CustomSortOrderChangesDetectedToastMessage(ChangesDetectedToastMessage):

    def __init__(self):
        super(CustomSortOrderChangesDetectedToastMessage, self).__init__()
        self._save_button = Button(wallet_names.mainWindow_Save_StatusFlatButton)
        self._save_and_apply_button = Button(wallet_names.mainWindow_Save_and_apply_StatusButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._save_and_apply_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Save and apply changes')
    def save_and_apply_changes(self):
        self._save_and_apply_button.click()
        self.wait_until_hidden()

    @allure.step('Save changes')
    def save_changes(self):
        self._save_button.click()
        self.wait_until_hidden()
