import allure

import configs.timeouts
import driver
from gui.components.settings.keycard_popup import KeycardPopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.objects_map import settings_names


class KeycardSettingsView(QObject):

    def __init__(self):
        super(KeycardSettingsView, self).__init__(settings_names.mainWindow_KeycardView)
        self._scroll = Scroll(settings_names.settingsContentBaseScrollView_Flickable)
        self._setup_keycard_with_existing_account_button = Button(settings_names.setupFromExistingKeycardAccount_StatusListItem)
        self._create_new_keycard_account_button = Button(settings_names.createNewKeycardAccount_StatusListItem)
        self._import_restore_via_seed_phrase_button = Button(settings_names.importRestoreKeycard_StatusListItem)
        self._import_from_keycard_button = Button(settings_names.importFromKeycard_StatusListItem)
        self._check_whats_on_keycard_button = Button(settings_names.checkWhatsNewKeycard_StatusListItem)
        self._factory_reset_keycard_button = Button(settings_names.factoryResetKeycard_StatusListItem)

    @allure.step('Check that keycard screen displayed')
    def check_keycard_screen_loaded(self):
        assert KeycardSettingsView().is_visible

    @allure.step('Choose create new keycard account with new seed phrase')
    def click_create_new_account_with_new_seed_phrase(self):
        self._create_new_keycard_account_button.click()
        return KeycardPopup().wait_until_appears()

    @allure.step('Choose import or restore keycard via seed phrase')
    def click_import_restore_via_seed_phrase(self):
        self._import_restore_via_seed_phrase_button.click()
        return KeycardPopup().wait_until_appears()

    @allure.step('Choose setup keycard with an existing account')
    def click_setup_keycard_with_existing_account(self):
        self._setup_keycard_with_existing_account_button.click()
        return KeycardPopup().wait_until_appears()

    @allure.step('Choose check whats on keycard')
    def click_check_whats_on_keycard(self):
        self._check_whats_on_keycard_button.click()
        return KeycardPopup().wait_until_appears()

    @allure.step('Choose factory reset a keycard')
    def click_factory_reset_keycard(self):
        self._factory_reset_keycard_button.click()
        return KeycardPopup().wait_until_appears()

    @allure.step('Check that all keycard options displayed')
    def all_keycard_options_available(self):
        assert self._setup_keycard_with_existing_account_button.is_visible, f'Setup keycard with existing account not visible'
        assert self._create_new_keycard_account_button.is_visible, f'Create new keycard button not visible'
        assert self._import_restore_via_seed_phrase_button.is_visible, f'Import and restore via seed phrase button not visible'
        self._scroll.vertical_down_to(self._import_from_keycard_button)
        assert driver.waitFor(lambda: self._import_from_keycard_button.is_visible,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Import keycard button not visible'
        assert driver.waitFor(lambda: self._check_whats_on_keycard_button.is_visible,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Check whats new keycard button not visible'
        assert driver.waitFor(lambda: self._factory_reset_keycard_button.is_visible,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Factory reset keycard button not visible'
