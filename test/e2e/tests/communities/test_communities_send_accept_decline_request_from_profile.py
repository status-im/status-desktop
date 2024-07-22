import allure
import pytest
from allure_commons._allure import step

import driver
from gui.components.profile_popup import ProfilePopupFromMembers
from gui.components.remove_contact_popup import RemoveContactPopup
from gui.main_window import MainWindow, switch_to_status_staging
from . import marks
import configs
import constants
from constants import UserAccount

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736170',
                 "Add a contact from community's member list")
@pytest.mark.case(736170)
@pytest.mark.parametrize('user_data_one, user_data_two, user_data_three', [
    (configs.testpath.TEST_USER_DATA / 'squisher', configs.testpath.TEST_USER_DATA / 'athletic',
     configs.testpath.TEST_USER_DATA / 'nervous')
])
def test_communities_send_accept_decline_request_remove_contact_from_profile(multiple_instances, user_data_one,
                                                                             user_data_two, user_data_three):
    user_one: UserAccount = constants.user_account_one
    user_two: UserAccount = constants.user_account_two
    user_three: UserAccount = constants.user_account_three
    timeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
    main_screen = MainWindow()

    with multiple_instances(user_data=user_data_one) as aut_one, multiple_instances(
            user_data=user_data_two) as aut_two, multiple_instances(user_data=user_data_three) as aut_three:
        with step(f'Launch multiple instances with authorized users {user_one.name}, {user_two.name}, {user_three}'):
            for aut, account in zip([aut_one, aut_two, aut_three], [user_one, user_two, user_three]):
                aut.attach()
                main_screen.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_screen.authorize_user(account)
                main_screen.hide()

        with step(f'User {user_one.name}, send contact request to {user_three.name} from user profile'):
            aut_one.attach()
            main_screen.prepare()
            switch_to_status_staging(aut_one, main_screen, user_one)
            community_screen = main_screen.left_panel.select_community('Community with 2 users')
            profile_popup = community_screen.right_panel.click_member(user_three.name)
            profile_popup.send_request().send(f'Hello {user_three.name}')
            ProfilePopupFromMembers().wait_until_appears()
            main_screen.hide()

        with step(f'User {user_three.name}, accept contact request from {user_one.name} from user profile'):
            aut_three.attach()
            main_screen.prepare()
            switch_to_status_staging(aut_three, main_screen, user_three)
            community_screen = main_screen.left_panel.select_community('Community with 2 users')
            profile_popup = community_screen.right_panel.click_member(user_one.name)
            profile_popup.review_contact_request().accept()
            main_screen.hide()

        with step(f'User {user_one.name} verify that send message button appeared in profile popup'):
            aut_one.attach()
            main_screen.prepare()
            assert driver.waitFor(lambda: profile_popup.is_send_message_button_visible(),
                                  timeout), f'Send message button is not visible'

        with step(f'User {user_one.name} remove {user_three.name} from contacts from user profile'):
            profile_popup.choose_context_menu_option('Remove contact')
            RemoveContactPopup().wait_until_appears().remove()

        with step(f'User {user_one.name}, send contact request to {user_three.name} from user profile again'):
            profile_popup.send_request().send(f'Hello {user_three.name}')
            ProfilePopupFromMembers().wait_until_appears()
            main_screen.hide()

        with step(f'User {user_three.name}, decline contact request from user profile {user_one.name}'):
            aut_three.attach()
            main_screen.prepare()
            profile_popup.review_contact_request().decline()

        with step(f'User {user_three.name} verify that send request button is available again in profile popup'):
            assert driver.waitFor(lambda: profile_popup.is_send_request_button_visible,
                                  timeout), f'Send request button is not visible'
