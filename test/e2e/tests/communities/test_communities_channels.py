import allure
import pytest
from allure_commons._allure import step

import constants
from gui.main_window import MainWindow
from . import marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703049', 'Create community channel')
@pytest.mark.case(703049)
@pytest.mark.parametrize('channel_name, channel_description, channel_emoji, channel_emoji_image, channel_color',
                         [('Channel', 'Description', 'sunglasses', '😎', '#4360df')])
def test_create_community_channel(main_screen: MainWindow, channel_name, channel_description, channel_emoji,
                                  channel_emoji_image, channel_color):
    main_screen.create_community(constants.community_params)
    community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
    community_screen.create_channel(channel_name, channel_description, channel_emoji)

    with step('Verify channel'):
        community_screen.verify_channel(
            channel_name,
            channel_description,
            channel_emoji_image,
            channel_color
        )


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703050', 'Edit community channel')
@pytest.mark.case(703050)
@pytest.mark.parametrize('channel_name, channel_description, channel_emoji, channel_emoji_image, channel_color',
                         [('Channel', 'Description', 'sunglasses', None, '#4360df')])
def test_edit_community_channel(main_screen, channel_name, channel_description, channel_emoji, channel_emoji_image,
                                channel_color):
    with step('Create simple community'):
        main_screen.create_community(constants.community_params)
        community_screen = main_screen.left_panel.select_community(constants.community_params['name'])

    with step('Verify General channel is present for recently created community'):
        community_screen.verify_channel(
            'general',
            'General channel for the community',
            None,
            channel_color
        )

    with step('Edit general channel'):
        community_screen.edit_channel('general', channel_name, channel_description, channel_emoji)

    with step('Verify edited channel details are correct in channels list'):
        channel = community_screen.left_panel.get_channel_parameters(channel_name)
        assert channel.name == channel_name
        assert channel.selected

    with step('Verify edited channel details are correct in community toolbar'):
        assert community_screen.tool_bar.channel_name == channel_name
        assert community_screen.tool_bar.channel_description == channel_description
        assert community_screen.tool_bar.channel_emoji == '😎 '
        assert community_screen.tool_bar.channel_color == channel_color


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703051', 'Delete community channel')
@pytest.mark.case(703051)
def test_delete_community_channel(main_screen):
    with step('Create simple community'):
        main_screen.create_community(constants.community_params)
        community_screen = main_screen.left_panel.select_community(constants.community_params['name'])

    with step('Delete channel'):
        community_screen.delete_channel('general')

    with step('Verify channel list is empty'):
        assert len(community_screen.left_panel.channels) == 0
