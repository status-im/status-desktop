import allure
import pytest
from allure_commons._allure import step

import driver
from constants.community import Channel
from gui.main_window import MainWindow
from scripts.utils.browser import get_response, get_page_content
from scripts.utils.generators import random_text_message, random_community_introduction, random_community_description, \
    random_community_name, random_community_leave_message
import configs
from constants import ColorCodes, UserAccount, RandomUser, RandomCommunity
from gui.screens.community_settings import CommunitySettingsScreen
from gui.screens.messages import MessagesScreen


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703255',
                 'Edit chat - Add pinned message (when any member can pin is disabled)')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703256',
                 'Edit chat - Remove pinned message (when any member can pin is disabled)')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703510', 'Join community via owner invite')
@pytest.mark.case(703255, 703256, 703510, 738743, 738754, 738798, 738799)
@pytest.mark.communities
@pytest.mark.smoke
@pytest.mark.critical
def test_create_edit_join_community_pin_unpin_message(multiple_instances):
    user_one: UserAccount = RandomUser()
    user_two: UserAccount = RandomUser()
    main_screen = MainWindow()

    with multiple_instances() as aut_one, multiple_instances() as aut_two:
        with step(f'Launch multiple instances with authorized users {user_one.name} and {user_two.name}'):
            for aut, account in zip([aut_one, aut_two], [user_one, user_two]):
                aut.attach()
                main_screen.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_screen.authorize_user(account)
                main_screen.hide()

        with step(f'User {user_two.name}, get chat key'):
            aut_two.attach()
            main_screen.prepare()
            profile_popup = main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier()
            chat_key = profile_popup.copy_chat_key
            main_screen.left_panel.click()
            main_screen.hide()

        with step(f'User {user_one.name}, send contact request to {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contact_request_popup = contacts_settings.open_contact_request_form()
            contact_request_popup.send(chat_key, f'Hello {user_two.name}')
            main_screen.hide()

        with step(f'User {user_two.name}, accept contact request from {user_one.name}'):
            aut_two.attach()
            main_screen.prepare()
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.accept_contact_request(user_one.name)

        with step(f'User {user_two.name}, create community and invite {user_one.name}'):
            with step('Create community and select it'):
                community = RandomCommunity()
                main_screen.left_panel.create_community(community_data=community)

            with step('Verify community parameters in community overview'):
                community_screen = main_screen.left_panel.select_community(community.name)
                assert community_screen.left_panel.name == community.name
                assert '1' in community_screen.left_panel.members

            with step('Verify General channel is present for recently created community'):
                community_screen.verify_channel(
                    Channel.DEFAULT_CHANNEL_NAME.value,
                    Channel.DEFAULT_CHANNEL_DESC.value,
                    None
                )
            with step('Edit community'):
                community_setting = community_screen.left_panel.open_community_settings()
                edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
                new_name = random_community_name()
                new_description = random_community_description()
                new_logo = {'fp': configs.testpath.TEST_FILES / 'banner.png', 'zoom': None, 'shift': None}['fp']
                new_banner = {'fp': configs.testpath.TEST_FILES / 'tv_signal.png', 'zoom': None, 'shift': None}['fp']
                new_introduction = random_community_introduction()
                new_leaving_message = random_community_leave_message()
                edit_community_form.edit(new_name, new_description,
                                         new_introduction, new_leaving_message,
                                         new_logo, new_banner)

            with step('Copy community link and verify that it does not give 404 error'):
                invite_modal = main_screen.left_panel.open_community_context_menu(
                    name=new_name).select_invite_people()
                community_link = invite_modal.copy_community_link()
                assert get_response(community_link).status_code == 200

            with step('Verify that community title and description are displayed on webpage and correct'):
                web_content = get_page_content(community_link)

                content_list = []

                for item in web_content.find_all('meta'):
                    if 'content' in item.attrs:
                        content_list.append(item.attrs['content'])

                assert f'Join {new_name} community in Status' in content_list
                assert new_description in content_list
                invite_modal.close_button.click()

            with step('Verify community parameters on settings overview'):
                overview_setting = community_setting.left_panel.open_overview()
                assert overview_setting.name == new_name
                assert overview_setting.description == new_description

            with step('Verify community parameters in community screen'):
                community_setting.left_panel.back_to_community()
                assert community_screen.left_panel.name == new_name

            # TODO: https://github.com/status-im/status-desktop/issues/18417

            with step('Verify community parameters in community settings screen'):
                settings_screen = main_screen.left_panel.open_settings()
                community_settings = settings_screen.left_panel.open_communities_settings()
                community_info = community_settings.communities[0]
                assert community_info.name == new_name
                assert community_info.description == new_description
                assert '1' in community_info.members

            assert new_name in main_screen.left_panel.communities(), \
                f'Community {new_name} should be present in the list of communities but it is not'
            context_menu = main_screen.left_panel.open_community_context_menu(new_name)
            assert not context_menu.leave_community_option.is_visible, f'Leave option should not be present'
            main_screen.left_panel.click()

            with step(f'Invite {user_one.name}'):
                community_screen = main_screen.left_panel.select_community(new_name)
                add_members = community_screen.left_panel.open_add_members_popup()
                add_members.invite([user_one.name], message=random_text_message())
            main_screen.hide()

        with step(f'User {user_one.name}, accept invitation from {user_two.name}'):
            aut_one.attach()
            main_screen.prepare()
            messages_view = main_screen.left_panel.open_messages_screen()
            chat = messages_view.left_panel.click_chat_by_name(user_two.name)
            chat.click_community_invite(new_name, 0)

        with step(f'User {user_one.name}, verify welcome community popup'):
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            assert new_name in welcome_popup.title
            assert new_introduction == welcome_popup.intro
            welcome_popup.join().authenticate(user_one.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  configs.timeouts.APP_LOAD_TIMEOUT_MSEC), 'Join community button not hidden'

        with step(f'User {user_one.name}, see two members in community members list'):
            assert driver.waitFor(lambda: user_two.name in community_screen.right_panel.members, 10000)
            assert driver.waitFor(lambda: '2' in community_screen.left_panel.members)
            main_screen.hide()

        with step(f'User {user_two.name}, see two members in community members list'):
            aut_two.attach()
            main_screen.prepare()
            assert driver.waitFor(lambda: user_one.name in community_screen.right_panel.members, 10000)
            assert '2' in community_screen.left_panel.members

        with step(f'Go to edit community for {user_two.name} and check that pin message checkbox is not checked'):
            community_screen = main_screen.left_panel.select_community(new_name)
            community_setting = community_screen.left_panel.open_community_settings()
            edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
            assert not edit_community_form.pin_message_checkbox_state

        with step('Go back to community and send a couple of message in general channel'):
            CommunitySettingsScreen().left_panel.back_to_community()
            messages_screen = MessagesScreen()
            message_text = random_text_message()
            messages_screen.group_chat.send_message_to_group_chat(message_text)
            second_message_text = random_text_message()
            messages_screen.group_chat.send_message_to_group_chat(second_message_text)
            newest_message_object = messages_screen.chat.messages(0)
            message_items = [message.text for message in newest_message_object]
            for message_item in message_items:
                assert second_message_text in message_item, f'Message {message_text} is not visible'

        with step(f'Hover message {second_message_text} and pin it'):
            message = messages_screen.chat.find_message_by_text(second_message_text, 0)
            message.hover_message().pin_message()
            main_screen.hide()

        with step(f'User {user_one.name} see the {second_message_text} as pinned'):
            aut_one.attach()
            main_screen.prepare()
            message = messages_screen.chat.find_message_by_text(second_message_text, 1)
            assert driver.waitFor(lambda: message.message_is_pinned, configs.timeouts.APP_LOAD_TIMEOUT_MSEC)
            assert message.pinned_info_text + message.user_name_in_pinned_message == 'Pinned by' + user_two.name
            assert message.get_message_color() == ColorCodes.ORANGE.value
            main_screen.hide()

        with step(f'User {user_two.name} unpin message from pinned messages popup'):
            aut_two.attach()
            main_screen.prepare()
            pinned_msgs = messages_screen.tool_bar.open_pinned_messages_popup()
            pinned_msgs.unpin_message().close()

        with step(f'User {user_one.name} see the {second_message_text} as unpinned'):
            aut_one.attach()
            main_screen.prepare()
            message = messages_screen.chat.find_message_by_text(second_message_text, 1)
            assert driver.waitFor(lambda: not message.message_is_pinned, configs.timeouts.APP_LOAD_TIMEOUT_MSEC)
            assert message.user_name_in_pinned_message == ''
            assert not messages_screen.tool_bar.pinned_message_tooltip.is_visible
