import random
import string
import time

import allure
import pytest
from allure_commons._allure import step

import driver
from . import marks

import configs.testpath
import constants
from constants import UserAccount
from constants.messaging import Messaging
from gui.main_window import MainWindow
from gui.screens.messages import MessagesScreen

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703014', 'Create a group and send messages')
@pytest.mark.case(703014)
@pytest.mark.timeout(timeout=315)
@pytest.mark.parametrize('user_data_one, user_data_two, user_data_three', [
    (configs.testpath.TEST_USER_DATA / 'group_chat_user_1', configs.testpath.TEST_USER_DATA / 'group_chat_user_2',
     configs.testpath.TEST_USER_DATA / 'group_chat_user_3')
])
def test_group_chat(multiple_instances, user_data_one, user_data_two, user_data_three):
    user_one: UserAccount = constants.group_chat_user_1
    user_two: UserAccount = constants.group_chat_user_2
    user_three: UserAccount = constants.group_chat_user_3
    members = [user_two.name, user_three.name]
    main_window = MainWindow()
    messages_screen = MessagesScreen()

    with multiple_instances(user_data=user_data_one) as aut_one, multiple_instances(
            user_data=user_data_two) as aut_two, multiple_instances(
        user_data=user_data_three) as aut_three:
        with step(f'Launch multiple instances with authorized users {user_one.name}, {user_two.name}, {user_three}'):
            for aut, account in zip([aut_one, aut_two, aut_three], [user_one, user_two, user_three]):
                aut.attach()
                main_window.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_window.authorize_user(account)
                main_window.hide()

        with step(f'User {user_one.name}, start chat and add {members}'):
            aut_one.attach()
            main_window.prepare()
            main_window.left_panel.open_messages_screen()
            messages_screen.left_panel.start_chat().create_chat(members)

            with step('Verify group chat info'):
                with step('Verify group chat name'):
                    group_chat_name = user_two.name + '&' + user_three.name
                    assert messages_screen.group_chat.group_name == group_chat_name, f'Group chat name is not correct'
                with step('Welcome group message is correct'):
                    actual_welcome_message = messages_screen.group_chat.group_welcome_message
                    assert actual_welcome_message.startswith(Messaging.WELCOME_GROUP_MESSAGE.value)
                    assert actual_welcome_message.endswith(' group!')
                    assert group_chat_name in actual_welcome_message
                with step('Verify there are three members in group members list'):
                    assert user_one.name in messages_screen.right_panel.members
                    assert user_two.name in messages_screen.right_panel.members
                    assert user_three.name in messages_screen.right_panel.members
                    assert len(messages_screen.right_panel.members) == 3

            with step('Open edit group name and image form and change name'):
                group_chat_new_name = ''.join(random.choices(string.ascii_letters +
                                                             string.digits, k=24))
                edit_group_popup = messages_screen.group_chat.open_edit_group_name_form()
                edit_group_popup.change_group_name(group_chat_new_name)
                edit_group_popup.save_changes()

            with step('Verify group chat name is changed'):
                assert messages_screen.group_chat.group_name == group_chat_new_name

            with step('Send message to group chat and verify it was sent'):
                chat_message = ''.join(random.choices(string.ascii_letters +
                                                      string.digits, k=40))
                messages_screen.group_chat.send_message_to_group_chat(chat_message)
                message_objects = messages_screen.chat.messages('0')
                message_items = [message.text for message in message_objects]
                for message_item in message_items:
                    assert chat_message in message_item

            with step(f'Remove {user_three.name} from group'):
                messages_screen.group_chat.remove_member_from_chat(user_three.name)

            with step('Verify members in a group members list'):
                assert driver.waitFor(lambda: user_one.name in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert user_two.name in messages_screen.right_panel.members
                assert driver.waitFor(lambda: user_three.name not in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert len(messages_screen.right_panel.members) == 2
                main_window.hide()

        with step(f'Check group members and message for {user_two.name}'):
            aut_two.attach()
            main_window.prepare()
            assert driver.waitFor(lambda: group_chat_new_name in messages_screen.left_panel.get_chats_names,
                                  10000), f'{group_chat_new_name} is not present in chats list for {aut_two}'
            messages_screen.left_panel.click_chat_by_name(group_chat_new_name)

            with step('Verify members in a group members list'):
                assert driver.waitFor(lambda: user_one.name in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert driver.waitFor(lambda: user_two.name in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert driver.waitFor(lambda: user_three.name not in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert len(messages_screen.right_panel.members) == 2

            with step('Send message to group chat after user removal and verify it'):
                chat_message_2 = ''.join(random.choices(string.ascii_letters +
                                                        string.digits, k=40))
                messages_screen.group_chat.send_message_to_group_chat(chat_message_2)
                message_objects = messages_screen.chat.messages('1')
                message_items = [message.text for message in message_objects]
                for message_item in message_items:
                    assert chat_message_2 in message_item

            with step('Leave group'):
                messages_screen.left_panel.open_leave_group_popup(group_chat_new_name).confirm_leaving()

            with step('Check that group name is not displayed on left panel'):
                assert driver.waitFor(lambda: group_chat_new_name not in messages_screen.left_panel.get_chats_names,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            main_window.hide()

        with step(f'Check group members and message for {user_three.name}'):
            aut_three.attach()
            main_window.prepare()

            with step(f'Check that {user_three.name} is not a member of a group'):
                assert driver.waitFor(lambda: group_chat_new_name in messages_screen.left_panel.get_chats_names,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'{group_chat_new_name} is not present in chats list for {aut_three}'
                messages_screen.left_panel.click_chat_by_name(group_chat_new_name)
                gray_message_text = messages_screen.group_chat.gray_text_from_message_area
                assert gray_message_text == Messaging.YOU_NEED_TO_BE_A_MEMBER.value
                assert not messages_screen.group_chat.is_message_area_enabled

            with step('Verify members in a group members list'):
                assert user_one.name in messages_screen.right_panel.members
                assert user_two.name in messages_screen.right_panel.members
                assert driver.waitFor(lambda: user_three.name not in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert len(messages_screen.right_panel.members) == 2  # it has to be 2 since user3 is kicked and not
                # receiving any updates from that moment

            with step('Leave group'):
                messages_screen.group_chat.leave_group().confirm_leaving()

            with step('Check that group name is not displayed on left panel'):
                assert group_chat_new_name not in messages_screen.left_panel.get_chats_names
            main_window.hide()

        with step(f'Get back to {aut_one} and check members list'):
            aut_one.attach()
            main_window.prepare()
            assert group_chat_new_name in messages_screen.left_panel.get_chats_names, \
                f'{group_chat_new_name} is not present in chats list for {aut_one}'
            messages_screen.left_panel.click_chat_by_name(group_chat_new_name)
            assert user_one.name in messages_screen.right_panel.members
            assert len(messages_screen.right_panel.members) == 1

            with step('Leave group'):
                messages_screen.group_chat.leave_group().confirm_leaving()

            with step('Check that group name is not displayed on left panel'):
                assert group_chat_new_name not in messages_screen.left_panel.get_chats_names
