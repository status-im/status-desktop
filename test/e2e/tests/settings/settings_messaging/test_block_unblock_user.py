import allure
import pytest
from allure_commons._allure import step

import constants
import driver
from constants import UserAccount, RandomUser
from constants.community_settings import BlockPopupWarnings, ToastMessages
from gui.main_window import MainWindow
import configs
from gui.screens.messages import ToolBar
from gui.screens.settings_messaging import ContactItem
from tests.communities import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/738772',
                 "Block or unblock someone in Status")
@pytest.mark.case(738772)
def test_block_and_unblock_user_from_settings_and_profile(multiple_instances):
    user_one: UserAccount = RandomUser()
    user_two: UserAccount = RandomUser()
    user_three: UserAccount = RandomUser()
    timeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
    main_screen = MainWindow()

    with \
            multiple_instances(user_data=None) as aut_one, \
            multiple_instances(user_data=None) as aut_two, \
            multiple_instances(user_data=None) as aut_three:

        with step(f'Launch multiple instances with new users {user_one.name}, {user_two.name}, {user_three.name}'):
            for aut, account in zip([aut_one, aut_two, aut_three], [user_one, user_two, user_three]):
                aut.attach()
                main_screen.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_screen.authorize_user(account)
                main_screen.hide()

            with step(f'User {user_two.name}, get chat key'):
                aut_two.attach()
                main_screen.prepare()
                profile_popup = main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
                user_2_chat_key = profile_popup.copy_chat_key
                profile_popup.close()
                main_screen.hide()

            with step(f'User {user_one.name}, send contact request to {user_two.name}'):
                aut_one.attach()
                main_screen.prepare()
                settings = main_screen.left_panel.open_settings()
                contact_request_form = settings.left_panel.open_messaging_settings().open_contacts_settings().open_contact_request_form()
                contact_request_form.send(user_2_chat_key, f'Hello {user_two.name}')

            with step(f'User {user_two.name}, accept contact request from {user_one.name} via activity center'):
                aut_two.attach()
                main_screen.prepare()
                activity_center = ToolBar().open_activity_center()
                request = activity_center.find_contact_request_in_list(user_one.name, timeout)
                activity_center.click_activity_center_button(
                    'Contact requests').accept_contact_request(request)
                activity_center.click()
                main_screen.hide()

            with step(f'User {user_three.name}, get chat key'):
                aut_three.attach()
                main_screen.prepare()
                profile_popup = main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
                user_3_chat_key = profile_popup.copy_chat_key
                profile_popup.close()
                main_screen.hide()

            with step(f'User {user_two.name}, send contact request to {user_three.name}'):
                aut_two.attach()
                main_screen.prepare()
                settings = main_screen.left_panel.open_settings()
                contact_request_form = settings.left_panel.open_messaging_settings().open_contacts_settings().open_contact_request_form()
                contact_request_form.send(user_3_chat_key, f'Hello {user_three.name}')
                main_screen.hide()

            with step(f'User {user_three.name}, accept contact request from {user_two.name} via activity center'):
                aut_three.attach()
                main_screen.prepare()
                activity_center = ToolBar().open_activity_center()
                request = activity_center.find_contact_request_in_list(user_two.name, timeout)
                activity_center.click_activity_center_button(
                    'Contact requests').accept_contact_request(request)
                activity_center.click()
                main_screen.hide()

        with step(
                f'User {user_one.name}, block contact {user_two.name} from user profile and verify button Block '
                f'appeared'):
            aut_one.attach()
            main_screen.prepare()
            contacts_settings = main_screen.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            assert driver.waitFor(lambda: user_two.name in [str(contact) for contact in contacts_settings.contact_items], timeout)
            block_popup = contacts_settings.open_contacts().open_more_options_popup(user_two.name).block_user()
            warning_text = BlockPopupWarnings.BLOCK_WARNING_PART_1.value + user_two.name + BlockPopupWarnings.BLOCK_WARNING_PART_2.value
            assert driver.waitFor(lambda: block_popup.get_warning_text() == warning_text,
                                  timeout), f'Text is incorrect, actual text is {block_popup.get_warning_text()}, correct text is {warning_text}'
            block_popup.block()

        with step('Check toast message about blocked member'):
            toast_messages = main_screen.wait_for_notification()
            message_1 = ToastMessages.REMOVED_CONTACT_TOAST.value
            message_2 = user_two.name + ToastMessages.BLOCKED_USER_TOAST.value
            assert driver.waitFor(lambda: message_1 in toast_messages,
                                  timeout), f"Toast message {message_1} is incorrect, current message is {toast_messages}"
            assert driver.waitFor(lambda: message_2 in toast_messages,
                                  timeout), f"Toast message {message_2} is incorrect, current message is {toast_messages}"
            main_screen.hide()

        with step(f'User {user_two.name} does not see {user_one.name} in contacts list'):
            aut_two.attach()
            main_screen.prepare()
            contacts_settings = main_screen.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            assert driver.waitFor(lambda: user_one.name not in [str(contact) for contact in contacts_settings.contact_items], timeout)
            main_screen.hide()

        with step(
                f'User {user_one.name}, unblock {user_two.name} from contact settings and verify {user_two.name} was removed from blocked list'):
            aut_one.attach()
            main_screen.prepare()
            contacts_settings = main_screen.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            unblock_popup = contacts_settings.open_blocked().open_more_options_popup(user_two.name).unblock_user()
            warning_text = \
                BlockPopupWarnings.UNBLOCK_TEXT_1.value + user_two.name + \
                BlockPopupWarnings.UNBLOCK_TEXT_2.value + user_two.name + \
                BlockPopupWarnings.UNBLOCK_TEXT_3.value

            assert driver.waitFor(lambda: unblock_popup.get_warning_text() == warning_text,
                                  timeout), f'Text is incorrect, actual text is {unblock_popup.get_warning_text()}, correct text is {warning_text}'
            unblock_popup.unblock()

        with step('Check toast message about unblocked member'):
            toast_messages = main_screen.wait_for_notification()
            message_2 = user_two.name + ToastMessages.UNBLOCKED_USER_TOAST.value
            assert driver.waitFor(lambda: message_2 in toast_messages,
                                  timeout), f"Toast message {message_2} is incorrect, current message is {toast_messages}"
