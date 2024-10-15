import allure
import pytest
from allure_commons._allure import step

from constants import RandomCommunity
from scripts.utils.generators import random_community_name, random_community_description, random_community_introduction, \
    random_community_leave_message
from . import marks

import configs.testpath
import constants
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703057', 'Edit community')
@pytest.mark.case(703057)
@pytest.mark.critical
def test_edit_community(main_screen: MainWindow):
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    with step('Create community and select it'):
        community = RandomCommunity()
        main_screen.create_community(community_data=community)
        community_screen = main_screen.left_panel.select_community(community.name)

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
