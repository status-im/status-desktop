import allure
import pyperclip
import pytest
from allure_commons._allure import step

from gui.components.signing_phrase_popup import SigningPhrasePopup
from . import marks

import configs.testpath
import driver
from constants import UserAccount, RandomUser
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.splash_screen import SplashScreen
from gui.main_window import MainWindow
from gui.screens.onboarding import AllowNotificationsView, WelcomeToStatusView, SyncResultView, SyncDeviceFoundView, \
    YourEmojihashAndIdenticonRingView

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703592', 'Sync device during onboarding')
@pytest.mark.case(703592)
@pytest.mark.critical
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
            setup_syncing = main_window.left_panel.open_settings().left_panel.open_syncing_settings().set_up_syncing(
                user.password)
            sync_code = setup_syncing.syncing_code
            setup_syncing.done()
            main_window.hide()

        with step('Verify syncing code is correct'):
            sync_code_fields = sync_code.split(':')
            assert sync_code_fields[0] == 'cs3'
            assert len(sync_code_fields) == 7

        with step('Open sync code form in second instance'):
            aut_two.attach()
            main_window.prepare()
            BeforeStartedPopUp().get_started()
            welcome_screen = WelcomeToStatusView().wait_until_appears()
            sync_view = welcome_screen.sync_existing_user().open_sync_code_view()

        with step('Paste sync code on second instance and wait until device is synced'):
            sync_start = sync_view.open_enter_sync_code_form()
            pyperclip.copy(sync_code)
            sync_start.click_paste_button()
            sync_start.continue_button.click()
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
            if configs.system.get_platform() == "Darwin":
                AllowNotificationsView().start_using_status()
            SplashScreen().wait_until_appears().wait_until_hidden()
            if not configs.system.TEST_MODE and not configs._local.DEV_BUILD:
                BetaConsentPopup().confirm()
            assert SigningPhrasePopup().ok_got_it_button.is_visible
            SigningPhrasePopup().confirm_phrase()

        with step('Verify user details are the same with user in first instance'):
            online_identifier = main_window.left_panel.open_online_identifier()
            assert online_identifier.get_user_name == user.name, \
                f'Name in online identifier and display name do not match'
