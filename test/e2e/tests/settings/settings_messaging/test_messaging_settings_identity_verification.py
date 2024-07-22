import time

import allure
import pytest
from allure_commons._allure import step
from . import marks

import configs.testpath
import constants
from constants import UserAccount
from constants.messaging import Messaging
from gui.main_screen import MainWindow, switch_to_status_staging

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704611', 'Reply to identity request')
@pytest.mark.case(704611)
@pytest.mark.skip(reason="https://github.com/status-im/status-desktop/issues/14954")
def test_messaging_settings_identity_verification(multiple_instances):
    user_one: UserAccount = constants.user_with_random_attributes_1
    user_two: UserAccount = constants.user_with_random_attributes_2
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
            switch_to_status_staging(aut_two, main_screen, user_two)
            profile_popup = main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
            chat_key = profile_popup.copy_chat_key
            profile_popup.close()
            main_screen.hide()

        with step(f'User {user_one.name}, send contact request to {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            switch_to_status_staging(aut_one, main_screen, user_one)
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contact_request_popup = contacts_settings.open_contact_request_form()
            contact_request_popup.send(chat_key, f'Hello {user_two.name}')
            main_screen.hide()

        with step(f'User {user_two.name}, accept contact request from {user_one.name}'):
            aut_two.attach()
            main_screen.prepare()
            contacts_settings = main_screen.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_pending_requests().accept_contact_request(user_one.name)

        with step(f'Verify that contact appeared in contacts list of {user_two.name} in messaging settings'):
            contacts_settings = main_screen.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_contacts()
            main_screen.hide()

        with step(f'Send verify identity request from {user_one.name} to {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            verify_identity_popup = contacts_settings.open_contacts().open_more_options_popup(
                user_two.name).verify_identity()
            assert verify_identity_popup.message_note == Messaging.MESSAGE_NOTE_IDENTITY_REQUEST.value
            assert not verify_identity_popup.is_send_verification_button_enabled
            verify_identity_popup.type_message('Hi. Is that you?').send_verification()

        with step('Verify toast message about sent ID verification request'):
            toast_messages = main_screen.wait_for_notification()
            assert Messaging.ID_VERIFICATION_REQUEST_SENT.value in toast_messages
            main_screen.hide()

        with step(f'Check incoming identity request for {user_two.name}'):
            aut_two.attach()
            main_screen.prepare()
            time.sleep(2)
            respond_identity_popup = contacts_settings.open_more_options_popup(user_one.name).respond_to_id_request()
            respond_identity_popup.type_message('Hi. Yes, its me').send_answer()

        with step('Verify toast message about sent ID verification reply'):
            toast_messages = main_screen.wait_for_notification()
            assert Messaging.ID_VERIFICATION_REPLY_SENT.value in toast_messages
