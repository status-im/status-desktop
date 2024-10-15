import allure
import pytest
from allure_commons._allure import step

import constants
from constants import RandomCommunity
from gui.main_window import MainWindow
from scripts.utils.browser import get_response, get_page_content
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736382', 'Share community link')
@pytest.mark.case(736382)
def test_share_community_link(main_screen: MainWindow):
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    with step('Create community and select it'):
        community = RandomCommunity()
        main_screen.create_community(community_data=community)
        community_screen = main_screen.left_panel.select_community(community.name)

    with step('Copy community link and verify that it does not give 404 error'):
        community_link = main_screen.left_panel.open_community_context_menu(
            community.name).select_invite_people().copy_community_link()
        assert get_response(community_link).status_code != 404

    # TODO: fix html parsing
    # with step('Verify that community title and description are displayed on webpage and correct'):
    #     web_content = get_page_content(community_link)
    #     community_title = web_content.findAll(attrs={"name": "title"})[0].attrs['content']
    #     community_description = web_content.findAll(attrs={"name": "description"})[0].attrs['content']
    #     assert community.name in community_title
    #     assert community.description == community_description
