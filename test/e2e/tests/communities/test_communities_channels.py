import allure
import pytest
from allure_commons._allure import step

import configs
import constants
from gui.components.context_menu import ContextMenu
from gui.main_window import MainWindow
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703049', 'Create community channel')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703050', 'Edit community channel')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703051', 'Delete community channel')
@pytest.mark.case(703049, 703050, 703051)
@pytest.mark.parametrize(
    'channel_name, channel_description, channel_emoji, channel_emoji_image, channel_color, new_channel_name, new_channel_description, new_channel_emoji',
    [('Channel', 'Description', 'sunglasses', None, '#4360df', 'New-channel', 'New channel description', 'thumbsup')])
@pytest.mark.critical
def test_create_edit_remove_community_channel(main_screen, channel_name, channel_description, channel_emoji, channel_emoji_image,
                                channel_color, new_channel_name, new_channel_description, new_channel_emoji):
    with step('Create simple community'):
        community_params = constants.community_params
        main_screen.create_community(community_params['name'], community_params['description'],
                                     community_params['intro'], community_params['outro'],
                                     community_params['logo']['fp'], community_params['banner']['fp'])
        community_screen = main_screen.left_panel.select_community(community_params['name'])

    with step('Verify General channel is present for recently created community'):
        community_screen.verify_channel(
            'general',
            'General channel for the community',
            None,
            channel_color
        )

    with step('Create new channel for recently created community'):
        community_screen.create_channel(channel_name, channel_description, channel_emoji)

    with step('Verify channel'):
        community_screen.verify_channel(
            channel_name,
            channel_description,
            channel_emoji_image,
            channel_color
        )

    with step('Edit channel'):
        community_screen.edit_channel(channel_name, new_channel_name, new_channel_description, new_channel_emoji)

    with step('Verify edited channel details are correct in channels list'):
        channel = community_screen.left_panel.get_channel_parameters(new_channel_name)
        assert channel.name == new_channel_name
        assert channel.selected

    with step('Verify edited channel details are correct in community toolbar'):
        assert community_screen.tool_bar.channel_name == new_channel_name
        assert community_screen.tool_bar.channel_description == new_channel_description
        assert community_screen.tool_bar.channel_emoji == '👍 '
        assert community_screen.tool_bar.channel_color == channel_color

    with step('Delete channel'):
        community_screen.delete_channel(new_channel_name)

    with step('Delete general channel'):
        community_screen.delete_channel('general')

    with step('Verify channels list is empty'):
        assert len(community_screen.left_panel.channels) == 0


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703269', 'Member role cannot add channels')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703270', 'Member role cannot edit channels')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703271', 'Member role cannot delete channels')
@pytest.mark.case(703269, 703270, 703271)
@pytest.mark.parametrize('user_data', [configs.testpath.TEST_USER_DATA / 'squisher'])
def test_member_role_cannot_add_edit_and_delete_channels(main_screen: MainWindow):
    with step('Choose community user is not owner of'):
        community_screen = main_screen.left_panel.select_community('Super community')
    with step('Verify that member cannot add new channel'):
        with step('Verify that create channel or category button is not present'):
            assert not community_screen.left_panel.is_create_channel_or_category_button_visible()
        with step('Verify that add channel button is not present'):
            assert not community_screen.left_panel.is_add_channels_button_visible()
        with step('Right-click a channel on the left navigation bar'):
            community_screen.left_panel.right_click_on_panel()
        with step('Verify that context menu does not appear'):
            assert not ContextMenu().is_visible

    with step('Verify that member cannot edit and delete channel'):
        with step('Right-click on general channel in the left navigation bar'):
            community_screen.left_panel.open_general_channel_context_menu()
        with step('Verify that edit item is not present in context menu'):
            assert not community_screen.tool_bar.is_edit_item_visible()
        with step('Verify that delete item is not present in context menu'):
            assert not community_screen.tool_bar.is_delete_item_visible()

        with step('Open more options context menu'):
            more_options_dropdown = community_screen.tool_bar.open_more_options_dropdown()
        with step('Verify that edit item is not present in context menu'):
            assert not more_options_dropdown.is_edit_item_visible()
        with step('Verify that delete item is not present in context menu'):
            assert not more_options_dropdown.is_delete_item_visible()
