import allure
import pyperclip
import pytest
from allure_commons._allure import step

import configs.testpath
import driver
from configs.timeouts import APP_LOAD_TIMEOUT_MSEC
from constants import UserAccount, RandomUser
from constants.dock_buttons import DockButtons
from gui.components.splash_screen import SplashScreen
from gui.main_window import MainWindow
from gui.screens.onboarding import OnboardingWelcomeToStatusView, SyncResultView, OnboardingProfileSyncedView, \
    OnboardingBiometricsView


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703592', 'Sync device during onboarding')
@pytest.mark.case(703592, 738760)
@pytest.mark.critical
@pytest.mark.smoke
def test_sync_device_during_onboarding(multiple_instances):
    user: UserAccount = RandomUser()
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
            setup_syncing = main_window.left_panel.open_settings().left_panel.open_syncing_settings().open_sync_new_device_popup(
                user.password)
            setup_syncing.wait_until_enabled()
            sync_code = setup_syncing.syncing_code
            main_window.hide()

        with step('Verify syncing code is correct'):
            sync_code_fields = sync_code.split(':')
            assert sync_code_fields[0] == 'cs3'
            assert len(sync_code_fields) == 7

        with step('Open sync code form in second instance'):
            aut_two.attach()
            main_window.prepare()
            welcome_screen = OnboardingWelcomeToStatusView().wait_until_appears()
            sync_view = welcome_screen.sync_existing_user()

        with step('Paste sync code on second instance and wait until device is synced'):
            sync_start = sync_view.open_enter_sync_code_form()
            pyperclip.copy(sync_code)
            sync_start.click_paste_button()
            sync_start.continue_button.click()
            profile_syncing_view = OnboardingProfileSyncedView().wait_until_appears()
            assert 'Profile sync in progress' in \
                   str(profile_syncing_view.profile_synced_view_header.wait_until_appears().object.text), \
                f'Profile sync process did not start'
            assert profile_syncing_view.log_in_button.wait_until_appears(timeout_msec=15000), \
                f'Log in button is not shown within 15 seconds'
            assert 'Profile synced' in str(profile_syncing_view.profile_synced_view_header.wait_until_appears().object.text), \
                f'Device is not synced'

        with step('Sign in to synced account'):
            profile_syncing_view.log_in_button.click()
            if configs.system.get_platform() == "Darwin":
                OnboardingBiometricsView().maybe_later()
            SplashScreen().wait_until_hidden(APP_LOAD_TIMEOUT_MSEC)

        with step('Verify user details are the same with user in first instance'):
            # TODO: Switch this to use home online identifier
            main_window.home.open_from_dock(DockButtons.SETTINGS.value)
            online_identifier = main_window.left_panel.open_online_identifier()
            assert online_identifier.get_user_name == user.name, \
                f'Name in online identifier and display name do not match'
            main_window.hide()

        with step('Check the first instance'):
            aut_one.attach()
            main_window.prepare()
            sync_device_found = SyncResultView()
            assert driver.waitFor(
                lambda: 'Device synced!' in sync_device_found.device_synced_notifications, 23000)
            assert user.name in sync_device_found.device_synced_notifications
