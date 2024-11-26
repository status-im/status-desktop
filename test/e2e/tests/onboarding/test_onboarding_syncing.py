import allure
import pyperclip
import pytest
from allure_commons._allure import step

from gui.screens.settings_syncing import SyncingSettingsView
from . import marks

import configs.testpath
from constants.syncing import SyncingSettings
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.main_window import MainWindow
from gui.screens.onboarding import WelcomeToStatusView, SyncCodeView

pytestmark = marks


@pytest.fixture
def sync_screen(main_window) -> SyncCodeView:
    with step('Open Syncing view'):
        BeforeStartedPopUp().get_started()
        welcome_screen = WelcomeToStatusView().wait_until_appears()
        return welcome_screen.sync_existing_user().open_sync_code_view()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703631', 'Wrong sync code')
@pytest.mark.case(703631)
@pytest.mark.parametrize('wrong_sync_code', [
    pytest.param('9rhfjgfkgfj890tjfgtjfgshjef900')
])
def test_wrong_sync_code(sync_screen, wrong_sync_code):
    with step('Open sync code form'):
        sync_view = sync_screen.open_enter_sync_code_form()

    with step('Paste wrong sync code and check that error message appears'):
        pyperclip.copy(wrong_sync_code)
        sync_view.click_paste_button()
        assert str(SyncingSettings.SYNC_CODE_IS_WRONG_TEXT.value == sync_view.sync_code_error_message), \
            f'Wrong sync code message did not appear'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703591', 'Generate sync code. Negative')
@pytest.mark.case(703591)
def test_cancel_setup_syncing(main_screen: MainWindow):
    with step('Open syncing settings'):
        sync_settings_view = main_screen.left_panel.open_settings().left_panel.open_syncing_settings()
        sync_settings_view.is_instructions_header_present()
        sync_settings_view.is_instructions_subtitle_present()
        if configs.DEV_BUILD:
            sync_settings_view.is_backup_button_present()
    with step('Click setup syncing and close authenticate popup'):
        sync_settings_view.click_setup_syncing().close_authenticate_popup()

    with step('Verify that authenticate popup was closed and syncing settings view appears after closing'):
        SyncingSettingsView().wait_until_appears()
