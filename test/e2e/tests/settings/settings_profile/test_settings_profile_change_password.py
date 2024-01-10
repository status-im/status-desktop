import allure
import psutil
import pytest
from allure_commons._allure import step
from . import marks

import constants
from driver.aut import AUT
from gui.main_window import MainWindow

pytestmark = marks


@pytest.mark.timeout(timeout=180)
# @pytest.mark.critical
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703005',
                 'Change the password and login with new password')
@pytest.mark.case(703005)
@pytest.mark.parametrize('user_account, user_account_changed_password',
                         [pytest.param(constants.user.user_account_one,
                                       constants.user.user_account_one_changed_password)])
@pytest.mark.xfail(reason='https://github.com/status-im/status-desktop/issues/13013')
def test_change_password_and_login(aut: AUT, main_screen: MainWindow, user_account, user_account_changed_password):
    with step('Open profile settings'):
        settings_scr = main_screen.left_panel.open_settings().left_panel.open_profile_settings()

    with step('Open change password popup'):
        change_psw_pop_up = settings_scr.open_change_password_popup()

    with step('Fill in the change password form and submit'):
        change_psw_pop_up.change_password(
            user_account.password, user_account_changed_password.password)

    with step('Verify the application process is not running'):
        psutil.Process(aut.pid).wait(timeout=10)

    with step('Restart application'):
        aut.restart()

    with step('Login with new password'):
        main_screen.authorize_user(user_account_changed_password)

    with step('Verify that the user logged in correctly'):
        online_identifier = main_screen.left_panel.open_online_identifier()
        profile_popup = online_identifier.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_account.name
