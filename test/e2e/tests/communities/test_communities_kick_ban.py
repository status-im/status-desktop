import time

import allure
import pytest
from allure_commons._allure import step

import driver
from constants import UserAccount, RandomUser, RandomCommunity, CommunityData
from constants.community import ToastMessages
from driver.objects_access import walk_children
from gui.screens.community import Members
from gui.screens.messages import MessagesScreen
from helpers.SettingsHelper import enable_community_creation
from scripts.utils.generators import random_text_message
import configs.testpath
from gui.main_window import MainWindow


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703252', 'Kick user')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736991', 'Owner can ban member')
@pytest.mark.case(703252, 703252, 736991)
@pytest.mark.communities
def test_community_admin_ban_kick_member_and_delete_message(multiple_instances):
    user_one: UserAccount = RandomUser()
    user_two: UserAccount = RandomUser()
    timeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
    community: CommunityData = RandomCommunity()
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
            enable_community_creation(main_screen)
            main_screen.create_community(community_data=community)
            community_screen = main_screen.left_panel.select_community(community.name)
            add_members = community_screen.left_panel.open_add_members_popup()
            add_members.invite([user_one.name], message=random_text_message())
            main_screen.hide()

        with step(f'User {user_one.name}, accept invitation from {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            messages_view = main_screen.left_panel.open_messages_screen()
            assert driver.waitFor(lambda: user_two.name in messages_view.left_panel.get_chats_names,
                                  10000)
            chat = messages_view.left_panel.click_chat_by_name(user_two.name)
            community_screen = chat.click_community_invite(community.name, 0)

        with step(f'User {user_one.name}, verify welcome community popup'):
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            assert community.name in welcome_popup.title
            assert community.introduction == welcome_popup.intro
            welcome_popup.join().authenticate(user_one.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  10000), 'Join community button not hidden'
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
            assert message == user_one.name + ToastMessages.BANNED_USER_TOAST.value + community.name, \
                f"Toast message is incorrect, current message is {message}"

        with step(f'User {user_two.name}, does not see {user_one.name} in members list'):
            members_list = community_screen.right_panel.members
            assert driver.waitFor(lambda: user_one.name not in members_list, timeout)

        with step(f'User {user_two.name}, see {user_one.name} in banned members list'):
            community_screen.right_panel.click_banned_button()
            assert driver.waitFor(lambda: user_one.name not in members_list, timeout)
            main_screen.hide()

        with step(f'User {user_one.name} tries to join community when being banned by {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            chat = messages_view.left_panel.click_chat_by_name(user_two.name)
            banned_community_screen = chat.open_banned_community(community.name, 0)
            assert banned_community_screen.community_banned_member_panel.is_visible
            assert banned_community_screen.banned_title() == f"You've been banned from {community.name}"
            main_screen.left_panel.open_community_context_menu(community.name).leave_community()
            assert driver.waitFor(lambda: community.name not in main_screen.left_panel.communities, timeout)
            main_screen.hide()

        with step(f'User {user_two.name}, unban {user_one.name} in banned members list'):
            aut_two.attach()
            main_screen.prepare()
            members.unban_member(user_one.name)
            toast_messages = main_screen.wait_for_notification()
            assert len(toast_messages) == 1, \
                f"Multiple toast messages appeared"
            message = toast_messages[0]
            assert message == user_one.name + ToastMessages.UNBANNED_USER_TOAST.value + community.name, \
                f"Toast message is incorrect, current message is {message}"
            main_screen.hide()

        with step(f'User {user_one.name} joins community again'):
            aut_one.attach()
            main_screen.prepare()
            chat1 = messages_view.left_panel.click_chat_by_name(user_two.name)
            community_screen = chat1.open_banned_community(community.name, 0)
            toast_messages = main_screen.wait_for_notification()
            assert len(toast_messages) == 1, \
                f"Multiple toast messages appeared"
            message = toast_messages[0]
            assert message == ToastMessages.UNBANNED_USER_CONFIRM.value + community.name, \
                f"Toast message is incorrect, current message is {message}"
            main_screen.left_panel.open_community_context_menu(community.name).leave_community()

            messages_view1 = main_screen.left_panel.open_messages_screen()
            chat = messages_view1.left_panel.click_chat_by_name(user_two.name)
            time.sleep(1)
            community_screen = chat.click_community_invite(community.name, 0)

            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            welcome_popup.join().authenticate(user_one.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                              10000), 'Join community button not hidden'

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
            assert message == user_one.name + ToastMessages.KICKED_USER_TOAST.value + community.name, \
                f"Toast message is incorrect, current message is {message}"

        with step(f'User {user_two.name}, does not see {user_one.name} in members list'):
            assert driver.waitFor(lambda: user_one.name not in community_screen.right_panel.members, timeout)
            main_screen.hide()

        with step(f'User {user_one.name} rejoins community after being kicked'):
            aut_one.attach()
            main_screen.prepare()
            assert driver.waitFor(lambda: community.name not in main_screen.left_panel.communities, timeout)

            messages_view = main_screen.left_panel.open_messages_screen()
            chat = messages_view.left_panel.click_chat_by_name(user_two.name)
            community_screen = chat.click_community_invite(community.name, 0)

            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            welcome_popup.join().authenticate(user_one.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  10000), 'Join community button not hidden'
