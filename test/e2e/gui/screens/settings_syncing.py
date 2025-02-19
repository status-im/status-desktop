import allure

from constants.syncing import SyncingSettings
from gui.components.authenticate_popup import AuthenticatePopup
from gui.components.settings.sync_new_device_popup import SyncNewDevicePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import settings_names


class SyncingSettingsView(QObject):

    def __init__(self):
        super().__init__(settings_names.mainWindow_SyncingView)
        self._setup_syncing_button = Button(settings_names.settings_Setup_Syncing_StatusButton)
        self._backup_data_button = Button(settings_names.settings_Backup_Data_StatusButton)
        self._sync_new_device_instructions_header = TextLabel(settings_names.settings_Sync_New_Device_Header)
        self._sync_new_device_instructions_subtitle = TextLabel(settings_names.settings_Sync_New_Device_SubTitle)

    @allure.step('Checking instructions elements: back up button presence')
    def is_backup_button_present(self):
        assert self._backup_data_button.is_visible, f"Backup button is not visible"

    @allure.step('Checking instructions elements: header presence')
    def is_instructions_header_present(self):
        assert (self._sync_new_device_instructions_header.text
                == SyncingSettings.SYNC_A_NEW_DEVICE_INSTRUCTIONS_HEADER.value), f"Sync a new device title is incorrect"

    @allure.step('Checking instructions elements: subtitle presence')
    def is_instructions_subtitle_present(self):
        assert (self._sync_new_device_instructions_subtitle.text
                == SyncingSettings.SYNC_A_NEW_DEVICE_INSTRUCTIONS_SUBTITLE.value), f"Sync a new device subtitle is incorrect"

    @allure.step('Setup syncing')
    def open_sync_new_device_popup(self, password: str):
        self.click_setup_syncing()
        AuthenticatePopup().wait_until_appears().authenticate(password)
        return SyncNewDevicePopup().wait_until_appears()

    @allure.step('Click setup syncing')
    def click_setup_syncing(self):
        self._setup_syncing_button.click()
        return AuthenticatePopup().wait_until_appears()
