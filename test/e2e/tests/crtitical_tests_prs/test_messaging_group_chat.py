import random
import string

import allure
import pytest
from allure_commons._allure import step

import driver
from constants.links import external_link, link_to_status_community

import configs.testpath
from constants import UserAccount, RandomUser
from constants.messaging import Messaging
from gui.main_window import MainWindow
from gui.screens.messages import MessagesScreen, ToolBar
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703014', 'Create a group and send messages')
@pytest.mark.case(703014)
@pytest.mark.timeout(timeout=315)
@pytest.mark.critical
@pytest.mark.parametrize('community_name, domain_link, domain_link_2',
                         [pytest.param('Status', 'status.app', 'github.com')
                          ])
def test_group_chat_add_contact_in_ac(multiple_instances, community_name, domain_link, domain_link_2):
    user_one: UserAccount = RandomUser()
    user_two: UserAccount = RandomUser()
    user_three: UserAccount = RandomUser()
    members = [user_two.name, user_three.name]
    main_window = MainWindow()
    messages_screen = MessagesScreen()
    path = configs.testpath.TEST_IMAGES / 'comm_logo.jpeg'
    timeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC

    with \
            multiple_instances(user_data=None) as aut_one, \
            multiple_instances(user_data=None) as aut_two, \
            multiple_instances(user_data=None) as aut_three:
        with step(f'Launch multiple instances with new users {user_one.name}, {user_two.name}, {user_three}'):
            for aut, account in zip([aut_one, aut_two, aut_three], [user_one, user_two, user_three]):
                aut.attach()
                main_window.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_window.authorize_user(account)
                main_window.hide()

        with step(f'User {user_two.name}, get chat key'):
            aut_two.attach()
            main_window.prepare()
            profile_popup = main_window.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
            user_2_chat_key = profile_popup.copy_chat_key
            profile_popup.close()
            main_window.hide()

        with step(f'User {user_one.name}, send contact request to {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            contact_request_form = settings.left_panel.open_messaging_settings().open_contacts_settings().open_contact_request_form()
            contact_request_form.send(user_2_chat_key, f'Hello {user_two.name}')

        with step(f'User {user_two.name}, accept contact request from {user_one.name} via activity center'):
            aut_two.attach()
            main_window.prepare()
            activity_center = ToolBar().open_activity_center()
            request = activity_center.find_contact_request_in_list(user_one.name, timeout)
            activity_center.click_activity_center_button(
                'Contact requests').accept_contact_request(request)
            activity_center.click()
            main_window.hide()

        with step(f'User {user_three.name}, get chat key'):
            aut_three.attach()
            main_window.prepare()
            profile_popup = main_window.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
            user_3_chat_key = profile_popup.copy_chat_key
            profile_popup.close()
            main_window.hide()

        with step(f'User {user_one.name}, send contact request to {user_three.name}'):
            aut_one.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            contact_request_form = settings.left_panel.open_messaging_settings().open_contacts_settings().open_contact_request_form()
            contact_request_form.send(user_3_chat_key, f'Hello {user_three.name}')

        with step(f'User {user_three.name}, accept contact request from {user_one.name} via activity center'):
            aut_three.attach()
            main_window.prepare()
            activity_center = ToolBar().open_activity_center()
            request = activity_center.find_contact_request_in_list(user_one.name, timeout)
            activity_center.click_activity_center_button(
                'Contact requests').accept_contact_request(request)
            activity_center.click()
            main_window.hide()

        with step(f'User {user_one.name}, start chat and add {members}'):
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
                group_chat_new_name = ''.join(random.choices(string.ascii_letters +
                                                             string.digits, k=24))
                edit_group_popup = messages_screen.group_chat.open_edit_group_name_form()
                edit_group_popup.change_group_name(group_chat_new_name)
                edit_group_popup.save_changes()

            with step('Verify group chat name is changed'):
                assert messages_screen.group_chat.group_name == group_chat_new_name

            with step('Send message to group chat and verify it was sent'):
                chat_message = ''.join(random.choices(string.ascii_letters +
                                                      string.digits, k=40))
                messages_screen.group_chat.send_message_to_group_chat(chat_message)
                message_objects = messages_screen.chat.messages('0')
                message_items = [message.text for message in message_objects]
                for message_item in message_items:
                    assert chat_message in message_item

            with step(f'Remove {user_three.name} from group'):
                messages_screen.group_chat.remove_member_from_chat(user_three.name)

            with step('Verify members in a group members list'):
                assert driver.waitFor(lambda: user_one.name in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert user_two.name in messages_screen.right_panel.members
                assert driver.waitFor(lambda: user_three.name not in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert len(messages_screen.right_panel.members) == 2
                main_window.hide()

        with step(f'Check group members and message for {user_two.name}'):
            aut_two.attach()
            main_window.prepare()

            assert driver.waitFor(lambda: group_chat_new_name in messages_screen.left_panel.get_chats_names,
                                  10000), f'{group_chat_new_name} is not present in chats list for {aut_two}'
            messages_screen.left_panel.click_chat_by_name(group_chat_new_name)

            with step('Verify members in a group members list'):
                assert driver.waitFor(lambda: user_one.name in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert driver.waitFor(lambda: user_two.name in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert driver.waitFor(lambda: user_three.name not in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert len(messages_screen.right_panel.members) == 2

            with step('Send message to group chat after user removal and verify it'):
                chat_message_2 = ''.join(random.choices(string.ascii_letters +
                                                        string.digits, k=40))
                messages_screen.group_chat.send_message_to_group_chat(chat_message_2)
                message_objects = messages_screen.chat.messages('1')
                message_items = [message.text for message in message_objects]
                for message_item in message_items:
                    assert chat_message_2 in message_item

            with step(f'User {user_two.name}, get own profile link and emoji hash in online identifier'):
                profile_link = main_window.left_panel.open_online_identifier().copy_link_to_profile()
                public_key_from_emoji_hash = main_window.left_panel.open_online_identifier().open_profile_popup_from_online_identifier().get_emoji_hash

            with step(f'User {user_two.name} paste external link'):
                message = external_link
                messages_screen.group_chat.send_message_to_group_chat(message)
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
                main_window.left_panel.open_messages_screen().left_panel.click_chat_by_name(group_chat_new_name)

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
                message_user = profile_link
                messages_screen.group_chat.type_message(message_user)
                assert driver.waitFor(
                    lambda: user_two.name == messages_screen.group_chat.get_link_preview_bubble_title(), 12000)
                messages_screen.group_chat.confirm_sending_message()

            with step('Verify title and emojihash are correct for link preview of sent message'):
                sent_message = messages_screen.chat.messages(0)
                assert driver.waitFor(lambda: sent_message[0].get_link_preview_title() == user_two.name,
                                      timeout)
                assert driver.waitFor(lambda: sent_message[0].link_preview_emoji_hash == public_key_from_emoji_hash,
                                      timeout)

            with step('Leave group'):
                messages_screen.group_chat.leave_group().confirm_leaving()

            with step('Check that group name is not displayed on left panel'):
                assert driver.waitFor(lambda: group_chat_new_name not in messages_screen.left_panel.get_chats_names,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            main_window.hide()

        with step(f'Check group members and message for {user_three.name}'):
            aut_three.attach()
            main_window.prepare()

            with step(f'Check that {user_three.name} is not a member of a group'):
                assert driver.waitFor(lambda: group_chat_new_name in messages_screen.left_panel.get_chats_names,
                                      10000), f'{group_chat_new_name} is not present in chats list for {aut_three}'
                messages_screen.left_panel.click_chat_by_name(group_chat_new_name)
                gray_message_text = messages_screen.group_chat.gray_text_from_message_area
                assert gray_message_text == Messaging.YOU_NEED_TO_BE_A_MEMBER.value
                assert not messages_screen.group_chat.is_message_area_enabled

            with step('Verify members in a group members list'):
                assert user_one.name in messages_screen.right_panel.members
                assert user_two.name in messages_screen.right_panel.members
                assert driver.waitFor(lambda: user_three.name not in messages_screen.right_panel.members,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                assert len(messages_screen.right_panel.members) == 2

            with step('Leave group'):
                messages_screen.group_chat.leave_group().confirm_leaving()

            with step('Check that group name is not displayed on left panel'):
                assert group_chat_new_name not in messages_screen.left_panel.get_chats_names
            main_window.hide()

        with step(f'Get back to {user_one.name} and check members list'):
            aut_one.attach()
            main_window.prepare()
            assert group_chat_new_name in messages_screen.left_panel.get_chats_names, \
                f'{group_chat_new_name} is not present in chats list for {aut_one}'
            messages_screen.left_panel.click_chat_by_name(group_chat_new_name)
            assert user_one.name in messages_screen.right_panel.members
            assert len(messages_screen.right_panel.members) == 1

            with step('Leave group'):
                messages_screen.group_chat.leave_group().confirm_leaving()

            with step('Check that group name is not displayed on left panel'):
                assert group_chat_new_name not in messages_screen.left_panel.get_chats_names
