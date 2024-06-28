import time
from datetime import datetime
from copy import deepcopy

import allure
import pytest
from allure import step

import configs
import constants
import driver
from constants import UserAccount
from gui.components.changes_detected_popup import ChangesDetectedToastMessage
from gui.main_window import MainWindow
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703007',
                 'Change own display name from online identifier')
@pytest.mark.case(703007)
@pytest.mark.parametrize('user_account', [constants.user.user_with_random_attributes_1])
@pytest.mark.parametrize('new_name', [pytest.param('NewUserName')])
def test_change_own_display_name(main_screen: MainWindow, user_account, new_name):
    with step('Open own profile popup and check name of user is correct'):
        profile = main_screen.left_panel.open_online_identifier()
        profile_popup = profile.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_account.name

    with step('Go to edit profile settings and change the name of the user'):
        profile_popup.edit_profile().set_name(new_name)
        ChangesDetectedToastMessage().click_save_changes_button()
        assert ChangesDetectedToastMessage().is_visible is False, f'Changes detected popup is not hidden when save changes button clicked'

    with step('Open own profile popup and check name of user is correct'):
        assert main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier().user_name == new_name


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703002', 'Switch state to offline')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703003', 'Switch state to online')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703004', 'Switch state to automatic')
@pytest.mark.case(703002, 703003, 703004)
@pytest.mark.parametrize('user_data_one, user_data_two', [
    (configs.testpath.TEST_USER_DATA / 'squisher', configs.testpath.TEST_USER_DATA / 'athletic')
])
def test_switch_state_to_offline_online_automatic(multiple_instances, user_data_one, user_data_two):
    user_one: UserAccount = constants.user_account_one
    user_two: UserAccount = constants.user_account_two
    main_screen = MainWindow()

    with (multiple_instances(user_data=user_data_one) as aut_one, multiple_instances(user_data=user_data_two) as aut_two):
        with step(f'Launch multiple instances with authorized users {user_one.name} and {user_two.name}'):
            for aut, account in zip([aut_one, aut_two], [user_one, user_two]):
                aut.attach()
                main_screen.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_screen.authorize_user(account)
                main_screen.hide()

        with step(f'User {user_two.name}, switch state to offline'):
            aut_two.attach()
            main_screen.prepare()
            main_screen.left_panel.set_user_to_offline()
            main_screen.hide()

        with step(f'User {user_one.name}, sees {user_two.name} as offline'):
            aut_one.attach()
            main_screen.prepare()
            community_screen = main_screen.left_panel.select_community('Community with 2 users')
            assert community_screen.right_panel.member_is_offline(1)
            main_screen.hide()

        with step(f'User {user_two.name}, switch state to online'):
            aut_two.attach()
            main_screen.prepare()
            main_screen.left_panel.set_user_to_online()
            main_screen.hide()

        with step(f'User {user_one.name}, sees {user_two.name} as online'):
            aut_one.attach()
            main_screen.prepare()
            time.sleep(2)
            assert driver.waitFor(lambda: community_screen.right_panel.member_is_online(1),
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            main_screen.hide()

        with step(f'User {user_two.name}, switch state to automatic'):
            aut_two.attach()
            main_screen.prepare()
            settings = main_screen.left_panel
            settings.set_user_to_automatic()

        with step('Verify user status set automatically to online'):
            assert settings.user_is_online()
            main_screen.hide()

        with step(f'User {user_one.name}, sees {user_two.name} as online'):
            aut_one.attach()
            main_screen.prepare()
            assert community_screen.right_panel.member_is_online(1)
            main_screen.hide()
