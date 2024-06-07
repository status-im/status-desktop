import allure
import pyperclip
import pytest
from allure_commons._allure import step

from gui.screens.settings_syncing import SyncingSettingsView
from . import marks

import configs.testpath
import constants
import driver
from constants import UserAccount
from constants.syncing import SyncingSettings
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.settings.sync_new_device_popup import SyncNewDevicePopup
from gui.components.splash_screen import SplashScreen
from gui.main_window import MainWindow
from gui.screens.onboarding import AllowNotificationsView, WelcomeToStatusView, SyncResultView, \
    SyncCodeView, SyncDeviceFoundView, YourEmojihashAndIdenticonRingView

pytestmark = marks


@pytest.fixture
def sync_screen(main_window) -> SyncCodeView:
    with step('Open Syncing view'):
        BeforeStartedPopUp().get_started()
        wellcome_screen = WelcomeToStatusView().wait_until_appears()
        return wellcome_screen.sync_existing_user().open_sync_code_view()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703592', 'Sync device during onboarding')
@pytest.mark.case(703592)
@pytest.mark.critical
def test_sync_device_during_onboarding(multiple_instances):
    user: UserAccount = constants.user_with_random_attributes_1
    main_window = MainWindow()

    with multiple_instances(user_data=None) as aut_one, multiple_instances(user_data=None) as aut_two:
        with step('Get syncing code in first instance'):
            aut_one.attach()
            main_window.prepare()
            main_window.authorize_user(user)
            sync_settings_view = main_window.left_panel.open_settings().left_panel.open_syncing_settings()
            sync_settings_view.is_instructions_header_present()
            sync_settings_view.is_instructions_subtitle_present()
            if configs.DEV_BUILD:
                sync_settings_view.is_backup_button_present()
            setup_syncing = main_window.left_panel.open_settings().left_panel.open_syncing_settings().set_up_syncing(
                user.password)
            sync_code = setup_syncing.syncing_code
            setup_syncing.done()
            main_window.hide()

        with step('Verify syncing code is correct'):
            sync_code_fields = sync_code.split(':')
            assert sync_code_fields[0] == 'cs3'
            assert len(sync_code_fields) == 5

        with step('Open sync code form in second instance'):
            aut_two.attach()
            main_window.prepare()
            BeforeStartedPopUp().get_started()
            wellcome_screen = WelcomeToStatusView().wait_until_appears()
            sync_view = wellcome_screen.sync_existing_user().open_sync_code_view()

        with step('Paste sync code on second instance and wait until device is synced'):
            sync_start = sync_view.open_enter_sync_code_form()
            pyperclip.copy(sync_code)
            sync_start.click_paste_button()
            sync_device_found = SyncDeviceFoundView()
            assert driver.waitFor(
                lambda: 'Device found!' in sync_device_found.device_found_notifications, 15000)
            try:
                assert driver.waitForObjectExists(SyncResultView().real_name, 15000), \
                    f'Sync result view is not shown within 15 seconds'
            except (Exception, AssertionError) as ex:
                raise ex
            sync_result = SyncResultView()
            assert driver.waitFor(
                lambda: 'Device synced!' in sync_result.device_synced_notifications, 23000)
            assert user.name in sync_device_found.device_found_notifications

        with step('Sign in to synced account'):
            sync_result.sign_in()
            SplashScreen().wait_until_hidden()
            YourEmojihashAndIdenticonRingView().verify_emojihash_view_present().next()
            if configs.system.IS_MAC:
                AllowNotificationsView().start_using_status()
            SplashScreen().wait_until_appears().wait_until_hidden()
            if not configs.system.TEST_MODE:
                BetaConsentPopup().confirm()

        with step('Verify user details are the same with user in first instance'):
            online_identifier = main_window.left_panel.open_online_identifier()
            assert online_identifier.get_user_name == user.name, \
                f'Name in online identifier and display name do not match'


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
        assert SyncingSettings.SYNC_CODE_IS_WRONG_TEXT.value == sync_view.sync_code_error_message, f'Wrong sync code message did not appear'


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
