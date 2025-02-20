import allure
import pytest
from allure_commons._allure import step

from constants import UserAccount
from scripts.utils.generators import random_password_string
from gui.components.change_password_popup import ChangePasswordPopup

from driver.aut import AUT
from gui.main_window import MainWindow


@pytest.mark.timeout(timeout=180)
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703005',
                 'Change the password and login with new password')
@pytest.mark.case(703005)
@pytest.mark.critical
# TODO: follow up on https://github.com/status-im/status-desktop/issues/13013
def test_change_password_and_login(aut: AUT, main_screen: MainWindow, user_account):
    with step('Open change password view'):
        settings_scr = main_screen.left_panel.open_settings()
        password_view = settings_scr.left_panel.open_password_settings()

    with step('Fill in the change password form and submit'):
        new_password = random_password_string()
        password_view.change_password(user_account.password, new_password)

    with step('Click re-encrypt data button and then restart'):
        ChangePasswordPopup().click_re_encrypt_data_restart_button()

    with step('Restart application'):
        aut.restart()
        main_screen.prepare()

    with step('Login with new password'):
        main_screen.authorize_user(UserAccount(name=user_account.name,
                                               password=new_password))

    with step('Verify that the user logged in correctly'):
        online_identifier = main_screen.left_panel.open_online_identifier()
        profile_popup = online_identifier.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_account.name
