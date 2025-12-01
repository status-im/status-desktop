import allure
import pytest
from allure_commons._allure import step

import driver
from gui.components.profile_popup import ProfilePopupFromMembers
from gui.components.remove_contact_popup import RemoveContactPopup
from gui.main_window import MainWindow
from helpers.chat_helper import skip_message_backup_popup_if_visible
from helpers.multiple_instances_helper import authorize_user_in_aut, get_chat_key, switch_to_aut
from scripts.utils.generators import random_text_message
import configs
from constants import UserAccount, RandomUser, RandomCommunity


@pytest.mark.case(736170, 738776, 738777)
@pytest.mark.smoke
@pytest.mark.communities
def test_communities_send_accept_decline_request_remove_contact_from_profile(multiple_instances):
    user_one: UserAccount = RandomUser()
    user_two: UserAccount = RandomUser()
    user_three: UserAccount = RandomUser()
    timeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
    main_screen = MainWindow()

    with multiple_instances(user_data=None) as aut_one, multiple_instances(
            user_data=None) as aut_two, multiple_instances(user_data=None) as aut_three:
        with step(f'Launch multiple instances with authorized users {user_one.name}, {user_two.name}, {user_three}'):
            for aut, account in zip([aut_one, aut_two, aut_three], [user_one, user_two, user_three]):
                authorize_user_in_aut(aut, main_screen, account)

        with step(f'User {user_two.name}, get chat key'):
            chat_key = get_chat_key(aut_two, main_screen)
            main_screen.minimize()

        with step(f'User {user_one.name}, send contact request to {user_two.name}'):
            switch_to_aut(aut_one, main_screen)
            settings = main_screen.left_panel.open_settings()
            contact_request_form = settings.left_panel.open_messaging_settings().open_contacts_settings().open_contact_request_form()
            contact_request_form.send(chat_key, f'Hello {user_two.name}')
            main_screen.minimize()

        with step(
                f'User {user_two.name}, accept contact request from {user_one.name} and send contact request to {user_three.name} '):
            switch_to_aut(aut_two, main_screen)
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.accept_contact_request(user_one.name)
            skip_message_backup_popup_if_visible()

        with step(f'User {user_three.name}, get chat key'):
            switch_to_aut(aut_three, main_screen)
            chat_key = get_chat_key(aut_three, main_screen)
            main_screen.minimize()


        with step(f'User {user_two.name}, send contact request to {user_three.name}'):
            switch_to_aut(aut_two, main_screen)
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contact_request_popup = contacts_settings.open_contact_request_form()
            contact_request_popup.send(chat_key, f'Hello {user_three.name}')
            main_screen.minimize()

        with step(f'User {user_three.name}, accept contact request from {user_two.name}'):
            switch_to_aut(aut_three, main_screen)
            settings = main_screen.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.accept_contact_request(user_two.name)
            skip_message_backup_popup_if_visible()
            main_screen.minimize()

        with step(f'User {user_two.name}, creates community and invites {user_one.name} and {user_three.name}'):
            switch_to_aut(aut_two, main_screen)

            with step('Create community and select it'):
                community = RandomCommunity()
                main_screen.left_panel.create_community(community_data=community)
                community_screen = main_screen.left_panel.select_community(community.name)

            add_popup = community_screen.left_panel.open_add_members_popup()
            add_popup.invite([user_one.name, user_three.name], message=random_text_message())
            main_screen.minimize()

        with step(f'User {user_three.name}, accept invitation from {user_two.name}'):
            switch_to_aut(aut_three, main_screen)
            messages_view = main_screen.left_panel.open_messages_screen()
            skip_message_backup_popup_if_visible()
            chat = messages_view.left_panel.click_chat_by_name(user_two.name)
            community_screen = chat.click_community_invite(community.name, 0)

        with step(f'User {user_three.name}, verify welcome community popup'):
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            assert community.name in welcome_popup.title
            assert community.introduction == welcome_popup.intro
            welcome_popup.join().authenticate(user_three.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), 'Join community button not hidden'
            main_screen.minimize()

        with step(f'User {user_one.name}, accept invitation from {user_two.name}'):
            switch_to_aut(aut_one, main_screen)
            messages_view = main_screen.left_panel.open_messages_screen()
            chat = messages_view.left_panel.click_chat_by_name(user_two.name)
            skip_message_backup_popup_if_visible()
            community_screen = chat.click_community_invite(community.name, 0)

        with step(f'User {user_one.name}, verify welcome community popup'):
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            assert community.name in welcome_popup.title
            assert community.introduction == welcome_popup.intro
            welcome_popup.join().authenticate(user_one.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), 'Join community button not hidden'

        with step(
                f'User {user_one.name} send contact request to {user_three.name} from user profile from members list'):
            community_screen = main_screen.left_panel.select_community(community.name)
            profile_popup = community_screen.right_panel.click_member(user_three.name)
            profile_popup.send_request().send(f'Hello {user_three.name}')
            ProfilePopupFromMembers().wait_until_appears()
            main_screen.minimize()

        with step(
                f'User {user_three.name}, accept contact request from {user_one.name} from user profile from members list'):
            switch_to_aut(aut_three, main_screen)
            community_screen = main_screen.left_panel.select_community(community.name)
            profile_popup = community_screen.right_panel.click_member(user_one.name)
            profile_popup.review_contact_request().accept_button.click()
            main_screen.minimize()

        with step(f'User {user_one.name} verify that send message button appeared in profile popup'):
            switch_to_aut(aut_one, main_screen)
            assert driver.waitFor(lambda: profile_popup.is_send_message_button_visible(),
                                  timeout), f'Send message button is not visible'

        with step(f'User {user_one.name} remove {user_three.name} from contacts from user profile'):
            profile_popup.choose_context_menu_option('Remove contact')
            RemoveContactPopup().wait_until_appears().remove_contact_button.click()

        with step(f'User {user_one.name}, send contact request to {user_three.name} from user profile again'):
            profile_popup.send_request().send(f'Hello {user_three.name}')
            ProfilePopupFromMembers().wait_until_appears()
            main_screen.minimize()

        with step(f'User {user_three.name}, decline contact request from user profile {user_one.name}'):
            switch_to_aut(aut_three, main_screen)
            profile_decline = community_screen.right_panel.click_member(user_one.name)
            profile_decline.review_contact_request().ignore_button.click()

        with step(f'User {user_three.name} verify that send request button is available again in profile popup'):
            assert driver.waitFor(lambda: profile_popup.is_send_request_button_visible,
                                  timeout), f'Send request button is not visible'
