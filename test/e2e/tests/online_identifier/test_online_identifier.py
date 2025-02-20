import allure
import pytest
from allure import step

import configs
from constants import UserAccount, RandomUser
from gui.screens.messages import ToolBar
from scripts.utils.generators import random_name_string
from gui.components.changes_detected_popup import ChangesDetectedToastMessage
from gui.main_window import MainWindow
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703007',
                 'Change own display name from online identifier')
@pytest.mark.case(703007)
def test_change_own_display_name(main_screen: MainWindow, user_account):
    with step('Open own profile popup and check name of user is correct'):
        profile = main_screen.left_panel.open_online_identifier()
        profile_popup = profile.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_account.name

    with step('Go to edit profile settings and change the name of the user'):
        updated_name = random_name_string()
        profile_popup.edit_profile().set_name(updated_name)
        ChangesDetectedToastMessage().click_save_changes_button()
        assert ChangesDetectedToastMessage().is_visible is False, \
            f'Changes detected popup is not hidden when save changes button clicked'

    with step('Open own profile popup and check name of user is correct'):
        assert main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier().user_name == updated_name


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703002', 'Switch state to offline')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703003', 'Switch state to online')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703004', 'Switch state to automatic')
@pytest.mark.case(703002, 703003, 703004)
@pytest.mark.skip(reason='To review later, perhaps does not worth automating')
def test_switch_state_to_offline_online_automatic(multiple_instances):
    user_one: UserAccount = RandomUser()
    user_two: UserAccount = RandomUser()
    main_screen = MainWindow()

    with (multiple_instances(user_data=None) as aut_one, multiple_instances(
            user_data=None) as aut_two):
        with step(f'Launch multiple instances for {user_one.name} and {user_two.name}'):
            for aut, account in zip([aut_one, aut_two], [user_one, user_two]):
                aut.attach()
                main_screen.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_screen.authorize_user(account)
                main_screen.hide()

        with step(f'User {user_two.name}, get chat key'):
            aut_two.attach()
            main_screen.prepare()
            profile_popup = main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
            chat_key = profile_popup.copy_chat_key
            profile_popup.close()
            main_screen.hide()

        with step(f'User {user_one.name}, send contact request to {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            settings = main_screen.left_panel.open_settings()
            contact_request_form = settings.left_panel.open_messaging_settings().open_contacts_settings().open_contact_request_form()
            contact_request_form.send(chat_key, f'Hello {user_two.name}')

        with step(f'User {user_two.name}, accept contact request from {user_one.name} via activity center'):
            aut_two.attach()
            main_screen.prepare()
            activity_center = ToolBar().open_activity_center()
            request = activity_center.find_contact_request_in_list(user_one.name, configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            activity_center.click_activity_center_button(
                'Contact requests').accept_contact_request(request)
            activity_center.click()

        with step(f'User {user_two.name}, switch state to offline'):
            main_screen.left_panel.set_user_to_offline()
            main_screen.hide()

        with step(f'User {user_one.name}, sees {user_two.name} as offline'):
            aut_one.attach()
            main_screen.prepare()
            assert settings.user_is_offline()
            main_screen.hide()

        with step(f'User {user_two.name}, switch state to online'):
            aut_two.attach()
            main_screen.prepare()
            main_screen.left_panel.set_user_to_online()
            main_screen.hide()

