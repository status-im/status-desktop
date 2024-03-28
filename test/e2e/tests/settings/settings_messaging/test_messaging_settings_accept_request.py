import allure
import pytest
from allure_commons._allure import step

from . import marks

import configs.testpath
import constants
from constants import UserAccount
from constants.messaging import Messaging
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703011', 'Add a contact with a chat key')
@pytest.mark.case(703011)
# TODO: reason='https://github.com/status-im/desktop-qa-automation/issues/346'
def test_messaging_settings_accepting_request(multiple_instances):
    user_one: UserAccount = constants.user_with_random_attributes_1
    user_two: UserAccount = constants.user_with_random_attributes_2
    main_window = MainWindow()

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

        with step('Verify that contact request was sent and is in pending requests'):
            contacts_settings.open_pending_requests()
            assert Messaging.CONTACT_REQUEST_SENT.value == contacts_settings.contact_items[0].object.contactText
            assert len(contacts_settings.contact_items) == 1
            assert contacts_settings.pending_request_sent_list_title == 'Sent'
            main_window.hide()

        with step(f'Verify that contact request was received by {user_two.name}'):
            aut_two.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.open_pending_requests()
            assert contacts_settings.pending_request_received_list_title == 'Received'
            assert user_one.name == contacts_settings.contact_items[0].contact
            assert len(contacts_settings.contact_items) == 1

        # TODO https://github.com/status-im/desktop-qa-automation/issues/346
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
            contacts_settings = main_window.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_contacts()
            assert contacts_settings.contacts_list_title == 'Contacts'
            assert user_one.name == contacts_settings.contact_items[0].contact
            assert len(contacts_settings.contact_items) == 1
            main_window.hide()

        with step(f'Verify that contact appeared in contacts list of {user_one.name} in messaging settings'):
            aut_one.attach()
            main_window.prepare()
            contacts_settings = main_window.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_contacts()
            assert contacts_settings.contacts_list_title == 'Contacts'
            assert user_two.name == contacts_settings.contact_items[0].contact
            assert len(contacts_settings.contact_items) == 1

        with step(f'Verify that 1X1 chat with {user_two.name} appeared for {user_one.name}'):
            messages_screen = main_window.left_panel.open_messages_screen()
            assert user_two.name in messages_screen.left_panel.get_chats_list()
            main_window.hide()

        with step(f'Verify that 1X1 chat with {user_one.name} appeared for {user_two.name}'):
            aut_two.attach()
            main_window.prepare()
            messages_screen = main_window.left_panel.open_messages_screen()
            assert user_one.name in messages_screen.left_panel.get_chats_list()
