from datetime import datetime

import allure
import pytest
from allure_commons._allure import step
from . import marks

import configs
import constants
from constants import ColorCodes
from gui.main_window import MainWindow
from gui.screens.community_settings import CommunitySettingsScreen
from gui.screens.messages import MessagesScreen

pytestmark = marks

@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703255',
                 'Edit chat - Add pinned message (when any member can pin is disabled)')
@pytest.mark.case(703255, 703256)
@pytest.mark.parametrize('user_data', [configs.testpath.TEST_USER_DATA / 'squisher'])
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('community_params', [
    {
        'name': f'Name_{datetime.now():%H%M%S}',
        'description': f'Description_{datetime.now():%H%M%S}',
        'color': '#ff7d46',
    },
])
def test_pin_and_unpin_message_in_community(main_screen: MainWindow, community_params, user_account):
    with step('Create community'):
        main_screen.create_community(constants.community_params)

    with step('Go to edit community and check that pin message checkbox is not checked'):
        community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
        assert not edit_community_form.pin_message_checkbox_state

    with step('Go back to community and send message in general channel'):
        CommunitySettingsScreen().left_panel.back_to_community()
        messages_screen = MessagesScreen()
        message_text = "Hi"
        messages_screen.group_chat.send_message_to_group_chat(message_text)
        message_objects = messages_screen.chat.messages
        message_items = [message.text for message in message_objects]
        for message_item in message_items:
            assert message_text in message_item

    with step('Hover message and pin it'):
        message = messages_screen.chat.find_message_by_text(message_text)
        message.hover_message().toggle_pin()

    with step('Verify that the message was pinned'):
        assert message.message_is_pinned
        assert message.pinned_info_text + message.user_name_in_pinned_message == 'Pinned by' + user_account.name
        assert message.get_message_color() == ColorCodes.ORANGE.value

    with step('Hover message and unpin it'):
        message.hover_message().toggle_pin()

    with step('Verify that the message was unpinned'):
        assert not message.message_is_pinned
        assert message.user_name_in_pinned_message == ''
        assert not messages_screen.tool_bar.is_pin_message_tooltip_visible
