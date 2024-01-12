import time

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
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704611', 'Reply to identity request')
@pytest.mark.case(704611)
@pytest.mark.parametrize('user_data_one, user_data_two', [
    (configs.testpath.TEST_USER_DATA / 'user_account_one', configs.testpath.TEST_USER_DATA / 'user_account_two')
])
@pytest.mark.xfail(reason='https://github.com/status-im/status-desktop/issues/13199')
def test_messaging_settings_identity_verification(multiple_instance, user_data_one, user_data_two):
    user_one: UserAccount = constants.user_account_one
    user_two: UserAccount = constants.user_account_two
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
            contacts_settings = main_window.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_pending_requests().accept_contact_request(user_one.name)

        with step(f'Verify that contact appeared in contacts list of {user_two.name} in messaging settings'):
            contacts_settings = main_window.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_contacts()
            main_window.hide()

        with step(f'Send verify identity request from {user_one.name} to {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            verify_identity_popup = contacts_settings.open_contacts().open_more_options_popup(
                user_two.name).verify_identity()
            assert verify_identity_popup.message_note == Messaging.MESSAGE_NOTE_IDENTITY_REQUEST.value
            assert not verify_identity_popup.is_send_verification_button_enabled
            verify_identity_popup.type_message('Hi. Is that you?').send_verification()
            main_window.hide()

        with step(f'Check incoming identity request for {user_two.name}'):
            aut_two.attach()
            main_window.prepare()
            time.sleep(2)
            respond_identity_popup = contacts_settings.open_more_options_popup(user_one.name).respond_to_id_request()
            respond_identity_popup.type_message('Hi. Yes, its me').send_answer()

        with step(f'Answer has been sent {user_two.name}'):
            assert respond_identity_popup.is_change_answer_button_visible
            respond_identity_popup.close()
