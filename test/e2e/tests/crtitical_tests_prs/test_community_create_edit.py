import allure
import pytest
from allure_commons._allure import step

from constants import RandomCommunity
from constants.community import Channel
from helpers.SettingsHelper import enable_community_creation
from scripts.utils.generators import random_community_name, random_community_description, random_community_introduction, \
    random_community_leave_message
from . import marks

import configs.testpath
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703057', 'Edit community')
@pytest.mark.case(703057)
@pytest.mark.critical
def test_create_edit_community(main_screen: MainWindow):
    enable_community_creation(main_screen)

    with step('Open create community popup'):
        communities_portal = main_screen.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()

    with step('Verify fields of create community popup and create community'):
        community = RandomCommunity()
        community_screen = create_community_form.create_community(community_data=community)

    with step('Verify community parameters in community overview'):
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

    with step('Verify community parameters on settings overview'):
        overview_setting = community_setting.left_panel.open_overview()
        assert overview_setting.name == new_name
        assert overview_setting.description == new_description

    with step('Verify community parameters in community screen'):
        community_setting.left_panel.back_to_community()
        assert community_screen.left_panel.name == new_name

    with step('Verify community parameters in community settings screen'):
        settings_screen = main_screen.left_panel.open_settings()
        community_settings = settings_screen.left_panel.open_communities_settings()
        community_info = community_settings.communities[0]
        assert community_info.name == new_name
        assert community_info.description == new_description
        assert '1' in community_info.members

    assert new_name in main_screen.left_panel.communities, \
        f'Community {new_name} should be present in the list of communities but it is not'
    context_menu = main_screen.left_panel.open_community_context_menu(new_name)
    assert not context_menu.leave_community_option.is_visible, f'Leave option should not be present'
