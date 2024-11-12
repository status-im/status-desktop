import allure
import pytest
from allure_commons._allure import step

from constants import RandomCommunity
from gui.main_window import MainWindow
from helpers.SettingsHelper import enable_community_creation
from scripts.utils.browser import get_response, get_page_content
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736382', 'Share community link')
@pytest.mark.case(736382)
def test_share_community_link(main_screen: MainWindow):

    enable_community_creation(main_screen)

    with step('Create community and select it'):
        community = RandomCommunity()
        main_screen.create_community(community_data=community)
        main_screen.left_panel.select_community(community.name)

    with step('Copy community link and verify that it does not give 404 error'):
        community_link = main_screen.left_panel.open_community_context_menu(
            community.name).select_invite_people().copy_community_link()
        assert get_response(community_link).status_code == 200

    with step('Verify that community title and description are displayed on webpage and correct'):
        web_content = get_page_content(community_link)

        content_list = []

        for item in web_content.find_all('meta'):
            if 'content' in item.attrs:
                content_list.append(item.attrs['content'])

        assert f'Join {community.name} community in Status' in content_list
        assert community.description in content_list
