import time
from copy import deepcopy
from datetime import datetime

import allure
import pytest
from allure_commons._allure import step

import driver
from constants import ColorCodes, UserAccount, RandomUser
from constants.community_settings import ToastMessages
from gui.screens.community import Members
from gui.screens.messages import MessagesScreen
from . import marks

import configs.testpath
import constants
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703630', 'Create community')
@pytest.mark.case(703630)
@pytest.mark.parametrize('params', [constants.community_params])
def test_create_community(user_account, main_screen: MainWindow, params):
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    with step('Open create community popup'):
        communities_portal = main_screen.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()

    with step('Verify fields of create community popup and create community'):
        color = ColorCodes.ORANGE.value
        community_screen = create_community_form.create_community(params['name'], params['description'],
                                                                  params['intro'], params['outro'],
                                                                  params['logo']['fp'], params['banner']['fp'], color,
                                                                  ['Activism', 'Art'], constants.community_tags[:2])

    with step('Verify community parameters in community overview'):
        with step('Name is correct'):
            assert community_screen.left_panel.name == params['name']
        with step('Members count is correct'):
            assert '1' in community_screen.left_panel.members

    with step('Verify General channel is present for recently created community'):
        community_screen.verify_channel(
            'general',
            'General channel for the community',
            None
        )

    with step('Verify community parameters in community settings view'):
        community_setting = community_screen.left_panel.open_community_settings()
        overview_setting = community_setting.left_panel.open_overview()
        with step('Name is correct'):
            assert overview_setting.name == params['name']
        with step('Description is correct'):
            assert overview_setting.description == params['description']
        with step('Members count is correct'):
            members_settings = community_setting.left_panel.open_members()
            assert user_account.name in members_settings.members

    with step('Verify community parameters in community settings screen'):
        settings_screen = main_screen.left_panel.open_settings()
        community_settings = settings_screen.left_panel.open_communities_settings()
        community = community_settings.get_community_info(params['name'])
        assert community.name == params['name']
        assert community.description == params['description']
        assert '1' in community.members


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703252', 'Kick user')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703254', 'Edit chat - Delete any message')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736991', 'Owner can ban member')
@pytest.mark.case(703252, 703252, 736991)
@pytest.mark.skip(reason='Not possible to get floating buttons on hover for list item')
def test_community_admin_ban_kick_member_and_delete_message(multiple_instances):
    user_one: UserAccount = RandomUser()
    user_two: UserAccount = RandomUser()
    timeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
    community_params = deepcopy(constants.community_params)
    community_params['name'] = f'{datetime.now():%d%m%Y_%H%M%S}'
    main_screen = MainWindow()

    with multiple_instances(user_data=None) as aut_one, multiple_instances(user_data=None) as aut_two:
        with step(f'Launch multiple instances with authorized users {user_one.name} and {user_two.name}'):
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

        with step(f'User {user_two.name}, create community and invite {user_one.name}'):
            settings = main_screen.left_panel.open_settings()
            settings.left_panel.open_advanced_settings().enable_creation_of_communities()

            community = main_screen.create_community(community_params['name'], community_params['description'],
                                                     community_params['intro'], community_params['outro'],
                                                     community_params['logo']['fp'], community_params['banner']['fp'])
            community.left_panel.invite_people_to_community([user_one.name], 'Message')
            main_screen.hide()

        with step(f'User {user_one.name}, accept invitation from {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            messages_view = main_screen.left_panel.open_messages_screen()
            assert driver.waitFor(lambda: user_two.name in messages_view.left_panel.get_chats_names,
                                  10000)
            chat = messages_view.left_panel.click_chat_by_name(user_two.name)
            community_screen = chat.accept_community_invite(community_params['name'], 0)

        with step(f'User {user_one.name}, verify welcome community popup'):
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            assert community_params['name'] in welcome_popup.title
            assert community_params['intro'] == welcome_popup.intro
            welcome_popup.join().authenticate(user_one.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  10000), 'Join community button not hidden'
            messages_screen = MessagesScreen()
            message_text = "Hi"
            messages_screen.group_chat.send_message_to_group_chat(message_text)
            main_screen.hide()

        with step(f'User {user_two.name}, delete member message of {user_one.name} and verify it was deleted'):
            aut_two.attach()
            main_screen.prepare()
            community_screen = main_screen.left_panel.select_community(community_params['name'])
            messages_screen = MessagesScreen()
            message = messages_screen.chat.find_message_by_text(message_text, '0')
            message.hover_message().delete_message()
            assert messages_screen.chat.get_deleted_message_state
            main_screen.hide()

        with step(f'User {user_one.name} verify that message was deleted by {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            assert driver.waitFor(lambda: messages_screen.chat.get_deleted_message_state, timeout)
            main_screen.hide()

        with step(f'User {user_two.name}, ban {user_one.name} from the community'):
            aut_two.attach()
            main_screen.prepare()
            community_setting = community_screen.left_panel.open_community_settings()
            members = community_setting.left_panel.open_members()
            members.ban_member(user_one.name).confirm_banning()

        with step('Check toast message about banned member'):
            toast_messages = main_screen.wait_for_notification()
            assert len(toast_messages) == 1, \
                f"Multiple toast messages appeared"
            message = toast_messages[0]
            assert message == user_one.name + ToastMessages.BANNED_USER_TOAST.value + community_params['name'], \
                f"Toast message is incorrect, current message is {message}"

        with step(f'User {user_two.name}, does not see {user_one.name} in members list'):
            members_list = community_screen.right_panel.members
            assert driver.waitFor(lambda: user_one.name not in members_list, timeout)

        with step(f'User {user_two.name}, see {user_one.name} in banned members list'):
            community_screen.right_panel.click_banned_button()
            assert driver.waitFor(lambda: user_one.name not in members_list, timeout)

        with step(f'User {user_two.name}, unban {user_one.name} in banned members list'):
            members.unban_member(user_one.name)
            time.sleep(2)

        with step('Check toast message about unbanned member'):
            toast_messages = main_screen.wait_for_notification()
            toast_message = user_one.name + ToastMessages.UNBANNED_USER_TOAST.value + community_params['name']
            assert driver.waitFor(lambda: toast_message in toast_messages, timeout), \
                f"Toast message is incorrect, current message {toast_message} is not in {toast_messages}"
            main_screen.hide()

        with step(f'User {user_one.name} join community again {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            community_screen = chat.accept_community_invite(community_params['name'], 0)
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            welcome_popup.join().authenticate(user_one.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  10000), 'Join community button not hidden'
            main_screen.hide()

        with step(f'User {user_two.name}, kick {user_one.name} from the community'):
            aut_two.attach()
            main_screen.prepare()
            Members().click_all_members_button()
            members.kick_member(user_one.name)

        with step('Check toast message about kicked member'):
            toast_messages = main_screen.wait_for_notification()
            assert len(toast_messages) == 1, \
                f"Multiple toast messages appeared"
            message = toast_messages[0]
            assert message == user_one.name + ToastMessages.KICKED_USER_TOAST.value + community_params['name'], \
                f"Toast message is incorrect, current message is {message}"

        with step(f'User {user_two.name}, does not see {user_one.name} in members list'):
            assert driver.waitFor(lambda: user_one.name not in community_screen.right_panel.members, timeout)
            main_screen.hide()

        with step(f'User {user_one.name} is not in the community anymore'):
            aut_one.attach()
            main_screen.prepare()
            assert driver.waitFor(lambda: community_params['name'] not in main_screen.left_panel.communities, timeout)
