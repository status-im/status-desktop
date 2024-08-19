import allure
import pytest
from allure_commons._allure import step

import constants
import driver
from constants import UserAccount
from constants.community_settings import BlockPopupWarnings, ToastMessages
from gui.main_window import MainWindow
import configs
from tests.communities import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/738772',
                 "Block or unblock someone in Status")
@pytest.mark.case(738772)
@pytest.mark.parametrize('user_data_one, user_data_two, user_data_three', [
    (configs.testpath.TEST_USER_DATA / 'squisher', configs.testpath.TEST_USER_DATA / 'athletic',
     configs.testpath.TEST_USER_DATA / 'nervous')
])
def test_block_and_unblock_user_from_settings_and_profile(multiple_instances, user_data_one, user_data_two, user_data_three):
    user_one: UserAccount = constants.user_account_one
    user_two: UserAccount = constants.user_account_two
    user_three: UserAccount = constants.user_account_three
    timeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
    main_screen = MainWindow()

    with multiple_instances(user_data=user_data_one) as aut_one, multiple_instances(
            user_data=user_data_two) as aut_two, multiple_instances(user_data=user_data_three) as aut_three:
        with step(f'Launch multiple instances with authorized users {user_one.name}, {user_two.name}, {user_three}'):
            for aut, account in zip([aut_one, aut_two, aut_three], [user_one, user_two, user_three]):
                aut.attach()
                main_screen.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_screen.authorize_user(account)
                main_screen.hide()

        with step(
                f'User {user_one.name}, block contact {user_two.name} from user profile and verify button Unblock '
                f'appeared'):
            aut_one.attach()
            main_screen.prepare()
            community_screen = main_screen.left_panel.select_community('Community with 2 users')
            profile_popup = community_screen.right_panel.click_member(user_two.name)
            block_popup = profile_popup.block_user()
            warning_text = BlockPopupWarnings.BLOCK_WARNING_PART_1.value + user_two.name + BlockPopupWarnings.BLOCK_WARNING_PART_2.value
            assert driver.waitFor(lambda: block_popup.get_warning_text() == warning_text,
                                  timeout), f'Text is incorrect, actual text is {block_popup.get_warning_text()}, correct text is {warning_text}'
            block_popup.block()
            with step('Check that Unblock user button appeared'):
                assert driver.waitFor(lambda: profile_popup.is_unblock_button_visible,
                                      timeout), f"Unblock button did not appear"
            main_screen.left_panel.click()

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
            assert driver.waitFor(lambda: user_one.name not in contacts_settings.contact_items, timeout)
            main_screen.hide()

        with step(
                f'User {user_one.name}, unblock {user_two.name} from contact settings and verify {user_two.name} was removed from blocked list'):
            aut_one.attach()
            main_screen.prepare()
            contacts_settings = main_screen.left_panel.open_settings().left_panel.open_messaging_settings().open_contacts_settings()
            unblock_popup = contacts_settings.open_blocked().open_more_options_popup(user_two.name).unblock_user()
            warning_text = BlockPopupWarnings.UNBLOCK_TEXT_1.value + user_two.name + BlockPopupWarnings.UNBLOCK_TEXT_2.value
            assert driver.waitFor(lambda: unblock_popup.get_warning_text() == warning_text,
                                  timeout), f'Text is incorrect, actual text is {unblock_popup.get_warning_text()}, correct text is {warning_text}'
            unblock_popup.unblock()

        with step('Check toast message about unblocked member'):
            toast_messages = main_screen.wait_for_notification()
            message_2 = user_two.name + ToastMessages.UNBLOCKED_USER_TOAST.value
            assert driver.waitFor(lambda: message_2 in toast_messages,
                                  timeout), f"Toast message {message_2} is incorrect, current message is {toast_messages}"

        with step(
                f'User {user_one.name}, block stranger {user_three.name} from user profile and verify button Unblock appeared'):
            community_screen = main_screen.left_panel.select_community('Community with 2 users')
            profile_popup = community_screen.right_panel.click_member(user_three.name)
            block_popup = profile_popup.block_user()
            block_popup.block()

        with step('Check that Unblock user button appeared'):
            assert driver.waitFor(lambda: profile_popup.is_unblock_button_visible, timeout), f"Unblock button did not appear"

        with step(
                f'User {user_one.name}, unblock stranger {user_three.name} from user profile and verify that Unblock button dissapeared and send request is visible again'):
            profile_popup.unblock_user().unblock()
            assert driver.waitFor(lambda: profile_popup.is_send_request_button_visible(), timeout)
