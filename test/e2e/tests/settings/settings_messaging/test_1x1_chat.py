import time

import allure
import pytest
from allure_commons._allure import step

import driver
from gui.components.activity_center import ContactRequest
from gui.screens.messages import MessagesScreen, ToolBar, ChatMessagesView
from . import marks

import configs.testpath
import constants
from constants import UserAccount
from constants.messaging import Messaging
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703011', 'Add a contact with a chat key')
@pytest.mark.case(703011)
@pytest.mark.parametrize('user_data_one, user_data_two', [
    (configs.testpath.TEST_USER_DATA / 'user_account_one', configs.testpath.TEST_USER_DATA / 'user_account_two')
])
def test_1x1_chat(multiple_instance, user_data_one, user_data_two):
    user_one: UserAccount = constants.user_account_one
    user_two: UserAccount = constants.user_account_two
    main_window = MainWindow()
    messages_screen = MessagesScreen()
    emoji = 'sunglasses'

    with (multiple_instance() as aut_one, multiple_instance() as aut_two):
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

        with step(f'User {user_two.name}, accept contact request from {user_one.name} via activity center'):
            aut_two.attach()
            main_window.prepare()
            activity_center = ToolBar().open_activity_center()
            request = activity_center.find_contact_request_in_list(user_one.name, configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            activity_center.click_activity_center_button(
                'Contact requests').accept_contact_request(request)
            main_window.hide()

        with step(f'User {user_one.name} send another message to {user_two.name}, edit it and verify it was changed'):
            aut_one.attach()
            main_window.prepare()
            chat = main_window.left_panel.open_messages_screen().left_panel.open_chat(user_two.name)
            ChatMessagesView().send_message_to_group_chat('How are you')
            message = chat.find_message_by_text(f'How are you', 0)
            additional_text = '?'
            time.sleep(5)
            message_actions = message.hover_message()
            message_actions.edit_message(additional_text)
            message_objects = messages_screen.chat.messages(0)
            message_items = [message.text for message in message_objects]
            for message_item in message_items:
                assert 'How are you?' in message_item
            main_window.hide()

        with step(f'User {user_two.name} opens 1x1 chat with {user_one.name}'):
            aut_two.attach()
            main_window.prepare()
            messages_screen.left_panel.open_chat(user_one.name)

        with step(f'User {user_two.name} send reply to {user_one.name}'):
            ChatMessagesView().send_message_to_group_chat('Hello squisher')
            messages_screen.group_chat.send_message_to_group_chat('Hello squisher')
            message_objects = messages_screen.chat.messages(1)
            message_items = [message.text for message in message_objects]
            for message_item in message_items:
                assert 'Hello squisher' in message_item
            for message_item in message_items:
                assert 'How are you?' in message_item

        with step(f'User {user_two.name} send emoji to {user_one.name}'):
            messages_screen.group_chat.send_emoji_to_chat(emoji)
            message_objects = messages_screen.chat.messages(0)
            message_items = [message.text for message in message_objects]
            for message_item in message_items:
                assert '😎' in message_item
            main_window.hide()

        with step(f'User {user_one.name}, received reply from {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            message_objects = messages_screen.chat.messages(1)
            message_items = [message.text for message in message_objects]
            for message_item in message_items:
                assert 'Hello squisher' in message_item

        with step(f'User {user_one.name}, received emoji from {user_two.name}'):
            time.sleep(2)
            message_objects = messages_screen.chat.messages(0)
            message_items = [message.text for message in message_objects]
            for message_item in message_items:
                assert '😎' in message_item

        with step(f'User {user_one.name}, delete own message and verify it was deleted'):
            message = messages_screen.left_panel.open_chat(user_two.name).find_message_by_text('How are you?', 3)
            message.hover_message().delete_message()

        with step(f'User {user_one.name}, cannot delete {user_two.name} message'):
            message = messages_screen.left_panel.open_chat(user_two.name).find_message_by_text('Hello squisher', 2)
            assert not message.hover_message().is_delete_button_visible()
            main_window.hide()
