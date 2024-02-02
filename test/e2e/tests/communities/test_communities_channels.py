import allure
import pytest
from allure_commons._allure import step

import configs
import constants
from gui.components.context_menu import ContextMenu
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


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703269', 'Member role cannot add channels')
@pytest.mark.case(703269)
@pytest.mark.parametrize('user_data', [configs.testpath.TEST_USER_DATA / 'squisher'])
def test_member_role_cannot_add_channels(main_screen: MainWindow):
    with step('Choose community user is not owner of'):
        community_screen = main_screen.left_panel.select_community('Super community')
    with step('Verify that create channel or category button is not present'):
        assert not community_screen.left_panel.is_create_channel_or_category_button_visible()
    with step('Verify that add channel button is not present'):
        assert not community_screen.left_panel.is_add_channels_button_visible()
    with step('Right-click a channel on the left navigation bar'):
        community_screen.left_panel.right_click_on_panel()
    with step('Verify that context menu does not appear'):
        assert not ContextMenu().is_visible


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703270', 'Member role cannot edit channels')
@pytest.mark.case(703270)
@pytest.mark.parametrize('user_data', [configs.testpath.TEST_USER_DATA / 'squisher'])
def test_member_role_cannot_edit_channels(main_screen: MainWindow):
    with step('Choose community user is not owner of'):
        community_screen = main_screen.left_panel.select_community('Super community')
    with step('Right-click on general channel in the left navigation bar'):
        community_screen.left_panel.open_general_channel_context_menu()
    with step('Verify that edit item is not present in context menu'):
        assert not community_screen.tool_bar.is_edit_item_visible()
    with step('Open more options context menu'):
        more_options_dropdown = community_screen.tool_bar.open_more_options_dropdown()
    with step('Verify that edit item is not present in context menu'):
        assert not more_options_dropdown.is_edit_item_visible()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703271', 'Member role cannot delete channels')
@pytest.mark.case(703271)
@pytest.mark.parametrize('user_data', [configs.testpath.TEST_USER_DATA / 'squisher'])
def test_member_role_cannot_delete_channels(main_screen: MainWindow):
    with step('Choose community user is not owner of'):
        community_screen = main_screen.left_panel.select_community('Super community')
    with step('Right-click on general channel in the left navigation bar'):
        community_screen.left_panel.open_general_channel_context_menu()
    with step('Verify that delete item is not present in context menu'):
        assert not community_screen.tool_bar.is_delete_item_visible()
    with step('Open more options context menu'):
        more_options_dropdown = community_screen.tool_bar.open_more_options_dropdown()
    with step('Verify that delete item is not present in context menu'):
        assert not more_options_dropdown.is_delete_item_visible()
