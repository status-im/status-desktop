import allure
import pytest
from allure_commons._allure import step

import constants
from gui.main_window import MainWindow
from gui.screens.community import CommunityScreen


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703049', 'Create community channel')
@pytest.mark.case(703049)
@pytest.mark.parametrize('channel_name, channel_description, channel_emoji', [('Channel', 'Description', 'sunglasses')])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
def test_create_community_channel(main_screen: MainWindow, channel_name, channel_description, channel_emoji):
    main_screen.create_community(constants.community_params)
    community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
    community_screen.create_channel(channel_name, channel_description, channel_emoji)

    with step('Verify channel'):
        community_screen.verify_channel(
            channel_name,
            channel_description,
            'channel_icon_in_list.png',
            'channel_icon_in_toolbar.png',
            'channel_icon_in_chat.png'
        )


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703050', 'Edit community channel')
@pytest.mark.case(703050)
@pytest.mark.parametrize('channel_name, channel_description, channel_emoji', [('Channel', 'Description', 'sunglasses')])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
def test_edit_community_channel(main_screen, channel_name, channel_description, channel_emoji):
    main_screen.create_community(constants.community_params)
    community_screen = CommunityScreen()

    with step('Verify General channel'):
        community_screen.verify_channel(
            'general',
            'General channel for the community',
            'general_channel_icon_in_list.png',
            'general_channel_icon_in_toolbar.png',
            'general_channel_icon_in_chat.png'
        )

    community_screen.edit_channel('general', channel_name, channel_description, channel_emoji)

    with step('Verify General channel'):
        community_screen.verify_channel(
            channel_name,
            channel_description,
            'channel_icon_in_list.png',
            'channel_icon_in_toolbar.png',
            'channel_icon_in_chat.png'
        )


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703051', 'Delete community channel')
@pytest.mark.case(703051)
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
def test_delete_community_channel(main_screen):
    main_screen.create_community(constants.community_params)

    with step('Delete channel'):
        CommunityScreen().delete_channel('general')

    with step('Verify channel is not exists'):
        assert not CommunityScreen().left_panel.channels
