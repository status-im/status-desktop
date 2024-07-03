import allure
import pytest
from allure_commons._allure import step

import configs.testpath
import constants
import driver
from constants import UserAccount
from constants.links import external_link, link_to_status_community, status_user_profile_link
from constants.messaging import Messaging
from gui.main_window import MainWindow
from gui.screens.messages import MessagesScreen, ToolBar
from tests.settings.settings_messaging import marks

import configs.testpath

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704596',
                 'Sending a link for the first time - default setting')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704578', 'Status community link preview bubble')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704589', 'Status user profile link preview')
@pytest.mark.case(704596, 704578, 704578)
@pytest.mark.parametrize('community_name, domain_link, user_name, domain_link_2, user_emoji_hash',
                         [pytest.param('Status', 'status.app', 'test_user', 'github.com',
                                       '0x047bc087919ee9875fcca0a01f46261c3c1d8ecbb9cd95f95903316190bd81946909cceb5fcda5d9f1a442fa20f71b5aa0f938cad87e83d45211bf5803352c9010')
                          ])
def test_link_previews(multiple_instances, community_name, domain_link, user_name, domain_link_2, user_emoji_hash):
    user_one: UserAccount = constants.user_with_random_attributes_1
    user_two: UserAccount = constants.user_with_random_attributes_2
    main_window = MainWindow()
    messages_screen = MessagesScreen()
    path = configs.testpath.TEST_IMAGES / 'comm_logo.jpeg'
    timeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC

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

        with step(f'User {user_two.name}, accept contact request from {user_one.name} via activity center'):
            aut_two.attach()
            main_window.prepare()
            activity_center = ToolBar().open_activity_center()
            request = activity_center.find_contact_request_in_list(user_one.name, configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            activity_center.click_activity_center_button(
                'Contact requests').accept_contact_request(request)

        with step(f'User {user_two.name} opens 1x1 chat with {user_one.name} and paste external link'):
            messages_screen.left_panel.click_chat_by_name(user_one.name)
            message = external_link
            messages_screen.group_chat.type_message(message)

        with step('Verify text in the link preview bubble'):
            assert driver.waitFor(
                lambda: Messaging.SHOW_PREVIEWS_TITLE.value == messages_screen.group_chat.get_show_link_preview_bubble_title(),
                timeout), f'Actual title of the link preview is not correct'
            assert Messaging.SHOW_PREVIEWS_TEXT.value == messages_screen.group_chat.get_show_link_preview_bubble_description(), \
                f'Actual text of the link preview is not correct'

        with step('Click options combobox and verify that there are 3 options'):
            messages_screen.group_chat.click_options().are_all_options_visible()

        with step('Close link preview options popup and send a message'):
            messages_screen.group_chat.close_link_preview_popup().confirm_sending_message()

        with step('Verify that message was sent without preview'):
            sent_message = messages_screen.chat.messages(0)
            assert driver.waitFor(lambda: sent_message[0].link_preview is None,
                                  timeout), f'Message was wrongly sent with preview'

        with step(f'Paste external link again and verify that there are still 3 options'):
            messages_screen.group_chat.type_message(message)
            messages_screen.group_chat.click_options().are_all_options_visible()

        with step('Close link preview options popup and send a message'):
            messages_screen.group_chat.close_link_preview_popup().confirm_sending_message()

        with step('Change preview settings to always show previews in messaging settings'):
            main_window.left_panel.open_settings().left_panel.open_messaging_settings().click_always_show()
            main_window.left_panel.open_messages_screen().left_panel.click_chat_by_name(user_one.name)

        with step(f'Paste external link again'):
            messages_screen.group_chat.type_message(message)

        with step('Wait until link preview is ready'):
            assert driver.waitFor(
                lambda: domain_link_2 == messages_screen.group_chat.get_link_preview_bubble_description(),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

        with step(f'Paste image to the same message'):
            messages_screen.group_chat.choose_image(str(path))
            messages_screen.group_chat.send_message()

        with step('Verify image and link unfurl are present in the last sent message'):
            message_object = messages_screen.chat.messages(0)[0]
            assert driver.waitFor(lambda: message_object.image_message.visible,
                                  timeout), f"Image is not found in the last message"
            assert driver.waitFor(lambda: message_object.delegate_button.is_visible,
                                  timeout), f"Link preview is not found in the last message"
            assert driver.waitFor(lambda: message_object.banner_image.is_visible,
                                  timeout), f"Banner image is not found in the last message"
            assert driver.waitFor(
                lambda: domain_link_2 == message_object.get_link_domain(),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

        with step(f'Paste link to status community'):
            message_community = link_to_status_community
            messages_screen.group_chat.type_message(message_community)

        with step('Verify title and subtitle of preview are correct and close button exists'):
            assert driver.waitFor(
                lambda: community_name == messages_screen.group_chat.get_link_preview_bubble_title(),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            assert driver.waitFor(
                lambda: domain_link == messages_screen.group_chat.get_link_preview_bubble_description(),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

        with step('Close link preview options popup and send a message'):
            messages_screen.group_chat.confirm_sending_message()

        with step(f'Paste link to user profile link and send message'):
            message_user = status_user_profile_link
            messages_screen.group_chat.type_message(message_user)
            assert driver.waitFor(
                lambda: user_name == messages_screen.group_chat.get_link_preview_bubble_title(), 12000)
            messages_screen.group_chat.confirm_sending_message()

        with step('Verify title and emojihash are correct for link preview of sent message'):
            sent_message = messages_screen.chat.messages(0)
            assert driver.waitFor(lambda: sent_message[0].get_link_preview_title() == user_name,
                                  timeout)
            assert driver.waitFor(lambda: sent_message[0].link_preview_emoji_hash == user_emoji_hash,
                                  timeout)
