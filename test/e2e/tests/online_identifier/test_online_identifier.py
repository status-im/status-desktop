import allure
import pytest
from allure import step

import constants
from driver.aut import AUT
from gui.components.changes_detected_popup import ChangesDetectedToastMessage
from gui.main_window import MainWindow
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703007',
                 'Change own display name from online identifier')
@pytest.mark.case(703007)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('new_name', [pytest.param('NewUserName')])
# @pytest.mark.skip(reason='https://github.com/status-im/status-desktop/issues/13868')
def test_change_own_display_name(main_screen: MainWindow, user_account, new_name):
    with step('Open own profile popup and check name of user is correct'):
        profile = main_screen.left_panel.open_online_identifier()
        profile_popup = profile.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_account.name

    with step('Go to edit profile settings and change the name of the user'):
        profile_popup.edit_profile().set_name(new_name)
        ChangesDetectedToastMessage().click_save_changes_button()
        assert ChangesDetectedToastMessage().is_save_changes_button_visible() is False, \
            f'Save button is not hidden when clicked'

    with step('Open own profile popup and check name of user is correct'):
        assert main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier().user_name == new_name


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703002', 'Switch state to offline')
@pytest.mark.case(703002)
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/149")
def test_switch_states_between_offline_and_online(aut: AUT, main_screen: MainWindow, user_account):
    with (step('Open settings and switch state to offline')):
        settings = main_screen.left_panel
        settings.set_user_to_offline()

    with step('Verify user appears offline'):
        assert settings.user_is_offline()

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account)

    with step('Verify user appears offline'):
        assert settings.user_is_offline()

    with (step('Open settings and switch state to online')):
        settings = main_screen.left_panel
        settings.set_user_to_online()

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account)

    with step('Verify user appears online'):
        assert settings.user_is_online()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703004', 'Switch state to automatic')
@pytest.mark.case(703004)
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/149")
def test_switch_state_to_automatic(aut: AUT, main_screen: MainWindow, user_account):
    with step('Open settings and switch state to automatic'):
        settings = main_screen.left_panel
        settings.set_user_to_automatic()

    with step('Verify user status set automatically to online'):
        assert settings.user_is_set_to_automatic()

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account)

    with step('Verify user status set automatically to online'):
        assert settings.user_is_set_to_automatic()
