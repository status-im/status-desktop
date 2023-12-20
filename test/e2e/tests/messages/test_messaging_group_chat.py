import allure
import pytest
from allure_commons._allure import step
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
@pytest.mark.parametrize('user_data_one, user_data_two, user_data_three', [
    (configs.testpath.TEST_USER_DATA / 'user_account_one', configs.testpath.TEST_USER_DATA / 'user_account_two',
     configs.testpath.TEST_USER_DATA / 'user_account_two')
])
@pytest.mark.xfail(reason="https://github.com/status-im/status-desktop/issues/12440")
def test_group_chat(multiple_instance, user_data_one, user_data_two, user_data_three):
    user_one: UserAccount = constants.user_account_one
    user_two: UserAccount = constants.user_account_two
    user_three: UserAccount = constants.user_account_three
    members = [user_two.name, user_three.name]
    main_window = MainWindow()
    messages_screen = MessagesScreen()

    with multiple_instance() as aut_one, multiple_instance() as aut_two, multiple_instance() as aut_three:
        with step(f'Launch multiple instances with authorized users {user_one.name} and {user_two.name}'):
            for aut, account in zip([aut_one, aut_two, aut_three], [user_one, user_two, user_three]):
                aut.attach()
                main_window.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_window.authorize_user(account)
                main_window.hide()

        with step(f'User {user_two.name}, get chat key'):
            aut_two.attach()
            main_window.prepare()
            profile_popup = main_window.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
            chat_key = profile_popup.get_chat_key_from_profile_link
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

        with step(f'User {user_three.name}, get chat key'):
            aut_three.attach()
            main_window.prepare()
            profile_popup = main_window.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
            chat_key = profile_popup.get_chat_key_from_profile_link
            profile_popup.close()
            main_window.hide()

        with step(f'User {user_one.name}, send contact request to {user_three.name}'):
            aut_one.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contact_request_popup = contacts_settings.open_contact_request_form()
            contact_request_popup.send(chat_key, f'Hello {user_three.name}')
            main_window.hide()

        with step(f'User {user_three.name}, accept contact request from {user_one.name}'):
            aut_three.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.accept_contact_request(user_one.name)
            main_window.hide()

        with step(f'User {user_one.name}, start chat and add {user_two.name}'):
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
            new_name = 'New_name'
            edit_group_popup = messages_screen.group_chat.open_edit_group_name_form()
            edit_group_popup.change_group_name(new_name)
            edit_group_popup.save_changes()

        with step('Verify group chat name is changed'):
            assert messages_screen.group_chat.group_name == new_name

        with step('Send message to group chat and verify it was sent'):
            messages_screen.group_chat.send_message_to_group_chat('Hi')
            message_objects = messages_screen.chat.messages
            message_items = [message.text for message in message_objects]
            for message_item in message_items:
                assert 'Hi' in message_item

        with step('Leave group'):
            messages_screen.group_chat.leave_group().confirm_leaving()

        with step('Check that group name is not displayed on left panel'):
            assert new_name not in messages_screen.left_panel.contacts
            main_window.hide()

        with step(f'Restart app for {user_two.name} and open group chat'):
            aut_two.restart()
            main_window.authorize_user(user_two)
            messages_screen.left_panel.open_chat(new_name)

        with step('Verify there are two members in group members list'):
            assert user_two.name in messages_screen.right_panel.members
            assert user_three.name in messages_screen.right_panel.members
            assert len(messages_screen.right_panel.members) == 2

        with step('Send message to group chat and verify it was sent'):
            messages_screen.group_chat.send_message_to_group_chat('Hi')
            message_objects = messages_screen.chat.messages
            message_items = [message.text for message in message_objects]
            for message_item in message_items:
                assert 'Hi' in message_item

        with step('Leave group'):
            messages_screen.left_panel.open_leave_group_popup(new_name).confirm_leaving()

        with step('Check that group name is not displayed on left panel'):
            assert new_name not in messages_screen.left_panel.contacts
            main_window.hide()

        with step(f'Restart app for {user_three.name} and open group chat'):
            aut_three.restart()
            main_window.authorize_user(user_three)
            messages_screen.left_panel.open_chat(new_name)

        with step('Verify there is one member in group members list'):
            assert user_three.name in messages_screen.right_panel.members
            assert len(messages_screen.right_panel.members) == 1

        with step('Send message to group chat and verify it was sent'):
            messages_screen.group_chat.send_message_to_group_chat('Hi')
            message_objects = messages_screen.chat.messages
            message_items = [message.text for message in message_objects]
            for message_item in message_items:
                assert 'Hi' in message_item

        with step('Leave group'):
            messages_screen.left_panel.open_leave_group_popup(new_name).confirm_leaving()

        with step('Check that group name is not displayed on left panel'):
            assert new_name not in messages_screen.left_panel.contacts
            main_window.hide()
