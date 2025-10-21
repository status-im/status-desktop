import allure
import pyperclip
import pytest
from allure_commons._allure import step

from gui.screens.settings_syncing import SyncingSettingsView
from . import marks

import configs.testpath
from constants.syncing import SyncingSettings
from gui.main_window import MainWindow
from gui.screens.onboarding import OnboardingWelcomeToStatusView, OnboardingSyncCodeView

pytestmark = marks


@pytest.fixture
def sync_screen(main_window) -> OnboardingSyncCodeView:
    with step('Open Syncing view'):
        welcome_screen = OnboardingWelcomeToStatusView().wait_until_appears()
        return welcome_screen.sync_existing_user()


@pytest.mark.case(703631)
@pytest.mark.parametrize('wrong_sync_code', [
    pytest.param('9rhfjgfkgfj890tjfgtjfgshjef900')
])
def test_wrong_sync_code(sync_screen, wrong_sync_code):
    with step('Open sync code form'):
        sync_code_form = sync_screen.open_enter_sync_code_form()

    with step('Paste wrong sync code and check that error message appears'):
        pyperclip.copy(wrong_sync_code)
        sync_code_form.click_paste_button()
        assert str(SyncingSettings.SYNC_CODE_IS_WRONG_TEXT.value == sync_code_form.get_sync_code_error_message), \
            f'Wrong sync code message did not appear'


@pytest.mark.case(703591)
def test_cancel_setup_syncing(main_screen: MainWindow, user_account):
    with step('Open syncing settings'):
        sync_settings_view = main_screen.left_panel.open_settings().left_panel.open_syncing_settings()
        assert sync_settings_view.sync_new_device_instructions_header.text \
               == SyncingSettings.SYNC_A_NEW_DEVICE_INSTRUCTIONS_HEADER.value, f"Sync a new device title is incorrect"
        assert sync_settings_view.sync_new_device_instructions_subtitle.text \
               == SyncingSettings.SYNC_A_NEW_DEVICE_INSTRUCTIONS_SUBTITLE.value, f"Sync a new device subtitle is incorrect"

    with step('Click setup syncing and close authenticate popup'):
        sync_new_device_popup = sync_settings_view.open_sync_new_device_popup(user_account.password)
        sync_new_device_popup.close()

    with step('Verify that authenticate popup was closed and syncing settings view appears after closing'):
        assert SyncingSettingsView().is_visible
