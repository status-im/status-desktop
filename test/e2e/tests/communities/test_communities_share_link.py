import allure
import pytest
from allure_commons._allure import step

import constants
from gui.main_window import MainWindow
from scripts.utils.browser import open_link, get_response
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736382', 'Share community link')
@pytest.mark.case(736382)
def test_share_community_link(main_screen: MainWindow):
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()
    with step('Create community and select it'):
        community_params = constants.community_params
        main_screen.create_community(community_params['name'], community_params['description'],
                                     community_params['intro'], community_params['outro'],
                                     community_params['logo']['fp'], community_params['banner']['fp'])
    with step('Copy community link and verify that it does not give 404 error'):
        community_link = main_screen.left_panel.open_community_context_menu(
            community_params['name']).select_invite_people().copy_community_link()
        assert get_response(community_link).status_code != 404
