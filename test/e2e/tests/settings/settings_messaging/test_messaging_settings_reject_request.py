import allure
import configs.testpath
import configs.timeouts
import constants
import pytest
from allure_commons._allure import step
from constants import UserAccount
from . import marks
from constants.messaging import Messaging
from gui.main_screen import MainWindow, switch_to_status_staging

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704610',
                 'Reject a contact request with a chat key')
@pytest.mark.case(704610)
def test_messaging_settings_rejecting_request(multiple_instances):
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
            online_identifier = main_screen.left_panel.open_online_identifier()
            profile_popup = online_identifier.open_profile_popup_from_online_identifier()
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

        with step(f'Verify that contact request from user {user_two.name} was received and reject contact request'):
            aut_two.attach()
            main_screen.prepare()
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.open_pending_requests()
            contacts_settings.reject_contact_request(user_one.name)

        with step(f'Verify that contacts list of {user_two.name} is empty in messaging settings'):
            contacts_settings = main_screen.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_contacts()
            assert contacts_settings.no_friends_item_text == Messaging.NO_FRIENDS_ITEM.value
            assert contacts_settings.is_invite_friends_button_visible
            main_screen.hide()

        with step(f'Verify that contacts list of {user_one.name} is empty in messaging settings'):
            aut_one.attach()
            main_screen.prepare()
            contacts_settings = main_screen.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            contacts_settings.open_contacts()
            assert contacts_settings.no_friends_item_text == Messaging.NO_FRIENDS_ITEM.value
            assert contacts_settings.is_invite_friends_button_visible
