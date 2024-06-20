from copy import deepcopy
from datetime import datetime

import allure
import pytest
from allure_commons._allure import step

import driver
from gui.components.profile_popup import ProfilePopupFromMembers
from gui.main_window import MainWindow
from . import marks
import configs
import constants
from constants import UserAccount

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736170',
                 "Add a contact from community's member list")
@pytest.mark.case(736170)
def test_add_a_contact_from_community_member_list(multiple_instances):
    user_one: UserAccount = constants.user_account_one
    user_two: UserAccount = constants.user_account_two
    user_three: UserAccount = constants.user_account_three
    community_params = deepcopy(constants.community_params)
    community_params['name'] = f'{datetime.now():%d%m%Y_%H%M%S}'
    main_screen = MainWindow()

    with multiple_instances() as aut_one, multiple_instances() as aut_two, multiple_instances() as aut_three:
        with step(f'Launch multiple instances with authorized users {user_one.name} and {user_two.name}'):
            for aut, account in zip([aut_one, aut_two, aut_three], [user_one, user_two, user_three]):
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
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contact_request_popup = contacts_settings.open_contact_request_form()
            contact_request_popup.send(chat_key, f'Hello {user_two.name}')
            main_screen.hide()

        with step(f'User {user_two.name}, accept contact request from {user_one.name}'):
            aut_two.attach()
            main_screen.prepare()
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.accept_contact_request(user_one.name)
            main_screen.hide()

        with step(f'User {user_three.name}, get chat key'):
            aut_three.attach()
            main_screen.prepare()
            profile_popup = main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
            chat_key = profile_popup.copy_chat_key
            profile_popup.close()
            main_screen.hide()

        with step(f'User {user_two.name}, send contact request to {user_three.name}'):
            aut_two.attach()
            main_screen.prepare()
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contact_request_popup = contacts_settings.open_contact_request_form()
            contact_request_popup.send(chat_key, f'Hello {user_three.name}')
            main_screen.hide()

        with step(f'User {user_three.name}, accept contact request from {user_two.name}'):
            aut_three.attach()
            main_screen.prepare()
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.accept_contact_request(user_two.name)
            main_screen.hide()

        with step(f'User {user_two.name}, create community and invite {user_one.name} and {user_three.name}'):
            aut_two.attach()
            main_screen.prepare()
            with step('Enable creation of community option'):
                settings = main_screen.left_panel.open_settings()
                settings.left_panel.open_advanced_settings().enable_creation_of_communities()
            community = main_screen.create_community(community_params['name'], community_params['description'],
                                                     community_params['intro'], community_params['outro'],
                                                     community_params['logo']['fp'], community_params['banner']['fp'])
            community.left_panel.invite_people_to_community([user_one.name], 'Message')
            community.left_panel.invite_people_to_community([user_three.name], 'Message')
            main_screen.hide()

        with step(f'User {user_three.name}, accept invitation from {user_two.name}'):
            aut_three.attach()
            main_screen.prepare()
            messages_view = main_screen.left_panel.open_messages_screen()
            chat = messages_view.left_panel.click_chat_by_name(user_two.name)
            community_screen = chat.accept_community_invite(community_params['name'], 0)

        with step(f'User {user_three.name}, verify welcome community popup'):
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            assert community_params['name'] in welcome_popup.title
            assert community_params['intro'] == welcome_popup.intro
            welcome_popup.join().authenticate(user_three.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  10000), 'Join community button not hidden'
            main_screen.hide()

        with step(f'User {user_one.name}, accept invitation from {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            messages_view = main_screen.left_panel.open_messages_screen()
            chat = messages_view.left_panel.click_chat_by_name(user_two.name)
            community_screen = chat.accept_community_invite(community_params['name'], 0)

        with step(f'User {user_one.name}, verify welcome community popup'):
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            assert community_params['name'] in welcome_popup.title
            assert community_params['intro'] == welcome_popup.intro
            welcome_popup.join().authenticate(user_one.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  10000), 'Join community button not hidden'

        with step(f'User {user_one.name}, send contact request to {user_three.name} from channel'):
            profile_popup = community_screen.right_panel.click_member(user_three.name)
            profile_popup.send_request().send(f'Hello {user_three.name}')
            ProfilePopupFromMembers().wait_until_appears()
            main_screen.hide()

        with step(f'User {user_three.name}, accept contact request from {user_one.name}'):
            aut_three.attach()
            main_screen.prepare()
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.accept_contact_request(user_one.name)
            main_screen.hide()

        with step(f'User {user_one.name} verify that request ID button appeared in send request popup'):
            aut_one.attach()
            main_screen.prepare()
            profile_popup.is_request_id_button_visible()
