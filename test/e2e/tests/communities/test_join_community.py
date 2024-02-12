from copy import deepcopy
from datetime import datetime

import allure
import pytest
from allure_commons._allure import step

import configs.testpath
import constants
import driver
from constants import UserAccount
from gui.main_window import MainWindow


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703510', 'Join community via owner invite')
@pytest.mark.case(703510)
@pytest.mark.parametrize('user_data_one, user_data_two', [
    (configs.testpath.TEST_USER_DATA / 'user_account_one', configs.testpath.TEST_USER_DATA / 'user_account_two')
])
def test_join_community_via_owner_invite(multiple_instance, user_data_one, user_data_two):
    user_one: UserAccount = constants.user_account_one
    user_two: UserAccount = constants.user_account_two
    community_params = deepcopy(constants.community_params)
    community_params['name'] = f'{datetime.now():%d%m%Y_%H%M%S}'
    main_window = MainWindow()

    with multiple_instance() as aut_one, multiple_instance() as aut_two:
        with step(f'Launch multiple instances with authorized users {user_one.name} and {user_two.name}'):
            for aut, account in zip([aut_one, aut_two], [user_one, user_two]):
                aut.attach()
                main_window.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_window.authorize_user(account)
                main_window.hide()

        with step(f'User {user_two.name}, get chat key'):
            aut_two.attach()
            main_window.prepare()
            profile_popup = main_window.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
            chat_key = profile_popup.copy_chat_key
            profile_popup.close()
            main_window.hide()

        with step(f'User {user_one.name}, send contact request to {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contact_request_popup = contacts_settings.open_contact_request_form()
            contact_request_popup.send(chat_key, f'Hello {user_two.name}')
            main_window.hide()

        with step(f'User {user_two.name}, accept contact request from {user_one.name}'):
            aut_two.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.accept_contact_request(user_one.name)
            main_window.hide()

        with step(f'User {user_one.name}, create community and {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            main_window.create_community(community_params)
            main_window.left_panel.invite_people_in_community([user_two.name], 'Message', community_params['name'])
            main_window.hide()

        with step(f'User {user_two.name}, accept invitation from {user_one.name}'):
            aut_two.attach()
            main_window.prepare()
            messages_view = main_window.left_panel.open_messages_screen()
            chat = messages_view.left_panel.open_chat(user_one.name)
            community_screen = chat.accept_community_invite(community_params['name'])

        with step(f'User {user_two.name}, verify welcome community popup'):
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            assert community_params['name'] in welcome_popup.title
            assert community_params['intro'] == welcome_popup.intro
            welcome_popup.join().authenticate(user_one.password)
            welcome_popup.share_address()
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), 'Join community button not hidden'

        with step(f'User {user_two.name}, see two members in community members list'):
            assert driver.waitFor(lambda: user_one.name in community_screen.right_panel.members)
            assert driver.waitFor(lambda: '2' in community_screen.left_panel.members)
            main_window.hide()

        with step(f'User {user_one.name}, see two members in community members list'):
            aut_one.attach()
            main_window.prepare()
            assert driver.waitFor(lambda: user_two.name in community_screen.right_panel.members)
            assert '2' in community_screen.left_panel.members
