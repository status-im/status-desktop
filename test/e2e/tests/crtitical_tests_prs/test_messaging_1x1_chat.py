import random
import string
import time

import allure
import pytest
from allure_commons._allure import step

import driver
from constants.images_paths import HEART_EMOJI_PATH, ANGRY_EMOJI_PATH, THUMBSUP_EMOJI_PATH, THUMBSDOWN_EMOJI_PATH, \
    LAUGHING_EMOJI_PATH, SAD_EMOJI_PATH
from constants.messaging import Messaging
from constants.wallet import WalletAddress
from ext.test_files.base64_images import BASE_64_IMAGE_JPEG
from helpers.chat_helper import skip_message_backup_popup_if_visible
from gui.screens.messages import MessagesScreen

import configs.testpath
from constants import RandomUser, UserAccount
from gui.main_window import MainWindow
from scripts.utils.generators import random_text_message


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703087', '1-1 Chat')
@pytest.mark.case(703087, 738732, 738734, 738742, 738744, 738745)
@pytest.mark.critical
@pytest.mark.smoke
def test_1x1_chat_add_contact_in_settings(multiple_instances):
    user_one: UserAccount = RandomUser()
    user_two: UserAccount = RandomUser()
    main_window = MainWindow()

    messages_screen = MessagesScreen()
    emoji = 'sunglasses'
    timeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
    local_picture = configs.testpath.TEST_IMAGES / 'comm_logo.jpeg'
    picture = random.choice([BASE_64_IMAGE_JPEG, local_picture])

    EMOJI_PATHES = ["❤️", "👍", "👎", "😂", "😢", "😡"]

    with (multiple_instances(user_data=None) as aut_one, multiple_instances(user_data=None) as aut_two):
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
            main_window.left_panel.click()
            main_window.hide()

        with step(f'User {user_one.name}, send contact request to {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contact_request_popup = contacts_settings.open_contact_request_form()
            contact_request_popup.send(chat_key, f'Hello {user_two.name}')

        with step('Verify that contact request was sent and is in pending requests'):
            contacts_settings.open_pending_requests()
            assert Messaging.CONTACT_REQUEST_SENT.value == contacts_settings.contact_items[0].object.contactText
            assert len(contacts_settings.contact_items) == 1
            assert str(contacts_settings.section_header.object.text) == 'Sent'
            main_window.hide()

        with step(f'Verify that contact request was received by {user_two.name}'):
            aut_two.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.open_pending_requests()
            assert str(contacts_settings.section_header.object.text) == 'Received'
            assert user_one.name == contacts_settings.contact_items[0].contact
            assert len(contacts_settings.contact_items) == 1

        # TODO: seems the toast is disappearing very fast
        # with step('Verify toast message about new contact request received'):
        #     toast_messages = main_window.wait_for_notification()
        #     assert len(toast_messages) == 1, \
        #         f"Multiple toast messages appeared"
        #     message = toast_messages[0]
        #     assert message == Messaging.NEW_CONTACT_REQUEST.value, \
        #         f"Toast message is incorrect, current message is {message}"

        with step(f'User {user_two.name}, accept contact request from {user_one.name}'):
            contacts_settings.accept_contact_request(user_one.name)

        with step(f'Verify that contact appeared in contacts list of {user_two.name} in messaging settings'):
            # Test is on a chat screen, so we need to open settings from left panel
            contacts_settings = main_window.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_contacts()
            assert str(contacts_settings.section_header.object.text) == 'Contacts'
            assert user_one.name == contacts_settings.contact_items[0].contact
            assert len(contacts_settings.contact_items) == 1
            main_window.hide()

        with step(f'Verify that contact appeared in contacts list of {user_one.name} in messaging settings'):
            aut_one.attach()
            main_window.prepare()
            contacts_settings = main_window.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_contacts()
            assert str(contacts_settings.section_header.object.text) == 'Contacts'
            assert user_two.name == contacts_settings.contact_items[0].contact
            assert len(contacts_settings.contact_items) == 1

        with step(f'Verify that 1X1 chat with {user_two.name} appeared for {user_one.name}'):
            # Test is in contact settings, so we need to open messages from left panel
            messages_screen = main_window.left_panel.open_messages_screen()
            assert user_two.name in messages_screen.left_panel.get_chats_names
            main_window.hide()

        with step(f'Verify that 1X1 chat with {user_one.name} appeared for {user_two.name}'):
            aut_two.attach()
            main_window.prepare()
            messages_screen = main_window.left_panel.open_messages_screen()
            assert user_one.name in messages_screen.left_panel.get_chats_names

        with step(f'User {user_one.name} send  a message to {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            left_panel_chat = main_window.left_panel.open_messages_screen().left_panel
            assert driver.waitFor(lambda: user_two.name in left_panel_chat.get_chats_names,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            chat = left_panel_chat.click_chat_by_name(user_two.name)
            chat_message1 = WalletAddress.RECEIVER_ADDRESS.value

            messages_screen.group_chat.send_message_to_group_chat(chat_message1)
            message = chat.find_message_by_text(chat_message1, 0)
            additional_text = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(1, 21))
            time.sleep(5)
        # TODO: https://github.com/status-im/status-desktop/issues/17757
        # with step(f'User {user_one.name}, click address / ens link in message and verify send modal appears'):
        #     send_modal = chat.open_send_modal_from_link(chat_message1)
        #     assert str(send_modal.send_modal_recipient_panel.object.selectedRecipientAddress) == chat_message1
            left_panel_chat.click()
            skip_message_backup_popup_if_visible()

        with step(f'User {user_one.name}, edit message and verify it was changed'):
            message_actions = message.hover_message()
            message_actions.edit_message(additional_text)
            message_object = messages_screen.chat.messages(0)[0]
            assert chat_message1 + additional_text in str(message_object.object.unparsedText), \
                f"Message text is not found in last message"
            assert message_object.delegate_button.object.isEdited, \
                f"Message status was not changed to edited"
            main_window.hide()

        with step(f'User {user_two.name} opens 1x1 chat with {user_one.name}'):
            aut_two.attach()
            main_window.prepare()
            messages_screen.left_panel.click_chat_by_name(user_one.name)

        with step(f'User {user_two.name} send reply to {user_one.name}'):
            chat_message2 = \
                ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(1, 21))
            messages_screen.group_chat.send_message_to_group_chat(chat_message2)
            message_object_0 = messages_screen.chat.messages(0)[0]
            assert chat_message2 in message_object_0.text, \
                f"Message text is not found in the last message"
            message_object_1 = messages_screen.chat.messages(1)[0]
            assert chat_message1 in str(message_object_1.object.unparsedText), \
                f"Message text is not found in the last message"

        with step(f'User {user_two.name} send emoji to {user_one.name}'):
            messages_screen.group_chat.send_emoji_to_chat(emoji)
            message_object = messages_screen.chat.messages(0)[0]
            assert '😎' in message_object.text

        with step(f'User {user_two.name} send image to {user_one.name} and verify it was sent'):
            messages_screen.group_chat.send_image_to_chat(str(picture))
            message_object = messages_screen.chat.messages(0)[0]
            assert message_object.image_message.visible, \
                f"Message text is not found in the last message"
            main_window.hide()

        with step(f'User {user_one.name}, received reply from {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            time.sleep(4)
            message_object = messages_screen.chat.messages(2)[0]
            assert driver.waitFor(lambda: chat_message2 in str(message_object.object.unparsedText)), \
                f"Message text is not found in the last message"

        with step(f'User {user_one.name}, received emoji from {user_two.name}'):
            message_object = messages_screen.chat.messages(1)[0]
            assert driver.waitFor(lambda: '😎' in str(message_object.object.unparsedText), timeout), \
                f"Message text is not found in the last message"

        with step(f'User {user_one.name}, received image from {user_two.name}'):
            message_object = messages_screen.chat.messages(0)[0]
            assert message_object.image_message.visible, \
                f"There is no image in the last message"

        with step(f'User {user_one.name}, reply to own message and verify that message displayed as a reply'):
            chat_message_reply = random_text_message()

            message.hover_message().reply_own_message(chat_message_reply)
            chat = main_window.left_panel.open_messages_screen().left_panel.click_chat_by_name(user_two.name)
            message = chat.find_message_by_text(chat_message_reply, 0)
            assert message.reply_corner.exists, \
                f"Last message does not have reply corner"

        with step(f'User {user_one.name}, add reaction to the last message and verify it was added'):
            occurrence = random.randint(1, 6)
            message.open_context_menu_for_message().add_reaction_to_message(occurrence)
            assert driver.waitFor(lambda: EMOJI_PATHES[occurrence - 1] in str(message.get_emoji_reactions_pathes()[0]),
                                  timeout), \
                f"Emoji reaction is not correct"
            main_window.hide()

        with step(f'User {user_two.name}, also see emoji reaction on the last message'):
            aut_two.attach()
            main_window.prepare()
            message = chat.find_message_by_text(chat_message_reply, 0)
            assert driver.waitFor(lambda: EMOJI_PATHES[occurrence - 1] in str(message.get_emoji_reactions_pathes()[0]),
                                  timeout), \
                f"Emoji reaction is not correct"
            main_window.hide()

        with step(f'User {user_one.name}, delete own message and verify it was deleted'):
            aut_one.attach()
            main_window.prepare()
            message = chat.find_message_by_text(chat_message_reply, 0)
            message.hover_message().delete_message()

        with step(f'User {user_one.name}, cannot delete {user_two.name} message'):
            message = messages_screen.left_panel.click_chat_by_name(user_two.name).find_message_by_text(chat_message2,
                                                                                                        3)
            assert not message.hover_message().is_delete_button_visible(), \
                f"Delete button is visible although it should not be"

        with step(f'User {user_one.name}, clears chat history'):
            messages_screen.group_chat.clear_history()
            messages = messages_screen.chat.messages(index=None)
            assert len(messages) == 0, f"The history of messages is not empty"
            assert user_two.name in messages_screen.left_panel.get_chats_names, f'{chat} is not present in chats list'
            main_window.hide()

        with step(f'Verify chat history was not cleared for {user_two.name} '):
            aut_two.attach()
            main_window.prepare()
            messages_screen.left_panel.click_chat_by_name(user_one.name)
            messages = messages_screen.chat.messages(index=None)
            assert len(messages) != 0, f"The history of messages is empty"

        with step(f'User {user_two.name} close chat'):
            aut_two.attach()
            main_window.prepare()
            messages_screen.group_chat.close_chat()
            assert user_one.name not in messages_screen.left_panel.get_chats_names, f'{chat} is present in chats list'
            main_window.hide()

        with step(f'User {user_one.name} sees chat in the list'):
            aut_one.attach()
            main_window.prepare()
            assert driver.waitFor(lambda: user_two.name in messages_screen.left_panel.get_chats_names,
                                  timeout), f'{chat} is present in chats list'
            main_window.hide()
