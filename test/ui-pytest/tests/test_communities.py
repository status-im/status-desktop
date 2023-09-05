from datetime import datetime

import allure
import pytest
from allure_commons._allure import step

import configs.testpath
import constants.user
from gui.main_window import MainWindow
from gui.screens.community import CommunityScreen
from scripts.tools import image

pytestmark = allure.suite("Communities")


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703084', 'Create community')
@pytest.mark.case(703084)
@pytest.mark.parametrize('params', [constants.user.default_community_params])
def test_create_community(user_account, main_screen: MainWindow, params):
    with step('Create community'):
        communities_portal = main_screen.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()
        community_screen = create_community_form.create(params)

    with step('Verify community parameters in community overview'):
        with step('Icon is correct'):
            community_icon = main_screen.left_panel.get_community_logo(params['name'])
            image.compare(community_icon, 'button_logo.png', timout_sec=5)
        with step('Name is correct'):
            assert community_screen.left_panel.name == params['name']
        with step('Members count is correct'):
            assert '1' in community_screen.left_panel.members
        with step('Logo is correct'):
            image.compare(community_screen.left_panel.logo, 'logo.png')

    with step('Verify community parameters in community settings view'):
        community_setting = community_screen.left_panel.open_community_settings()
        overview_setting = community_setting.left_panel.open_overview()
        with step('Name is correct'):
            assert overview_setting.name == params['name']
        with step('Description is correct'):
            assert overview_setting.description == params['description']
        with step('Members count is correct'):
            members_settings = community_setting.left_panel.open_members()
            assert user_account.name in members_settings.members

    with step('Verify community parameters in community settings screen'):
        settings_screen = main_screen.left_panel.open_settings()
        community_settings = settings_screen.open_communities_settings()
        community = community_settings.get_community_info(params['name'])
        assert community.name == params['name']
        assert community.description == params['description']
        assert '1' in community.members
        image.compare(community.image, 'logo_in_settings.png')


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703056', 'Edit community separately')
@pytest.mark.case(703056)
@pytest.mark.parametrize('community', [constants.user.default_community_params], indirect=True)
@pytest.mark.parametrize('community_params', [
        {
            'name': f'Name_{datetime.now():%H%M%S}',
            'description': f'Description_{datetime.now():%H%M%S}',
            'color': '#ff7d46',
        },

])
def test_edit_community_separately(main_screen, community: dict, community_params):

    with step('Edit community name'):
        community_screen = main_screen.left_panel.select_community(community['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
        edit_community_form.edit({'name': community_params['name']})

    with step('Name is correct'):
        overview_setting = community_setting.left_panel.open_overview()
        assert overview_setting.name == community_params['name']
    with step('Description is correct'):
        assert overview_setting.description == constants.default_community_params['description']

    with step('Edit community name'):
        edit_community_form = overview_setting.open_edit_community_view()
        edit_community_form.edit({'description': community_params['description']})

    with step('Name is correct'):
        overview_setting = community_setting.left_panel.open_overview()
        assert overview_setting.name == community_params['name']
    with step('Description is correct'):
        assert overview_setting.description == community_params['description']


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703057', 'Edit community')
@pytest.mark.case(703057)
@pytest.mark.parametrize('community', [constants.user.default_community_params], indirect=True)
@pytest.mark.parametrize('params', [
        {
            'name': 'Updated Name',
            'description': 'Updated Description',
            'logo': {'fp': configs.testpath.TEST_FILES / 'banner.png', 'zoom': None, 'shift': None},
            'banner': {'fp': configs.testpath.TEST_FILES / 'tv_signal.png', 'zoom': None, 'shift': None},
            'color': '#ff7d46',
            'tags': ['Ethereum'],
            'intro': 'Updated Intro',
            'outro': 'Updated Outro'
        }
])
def test_edit_community(main_screen: MainWindow, community: dict, params):

    with step('Edit community'):
        community_screen = main_screen.left_panel.select_community(community['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
        edit_community_form.edit(params)

    with step('Verify community parameters on settings overview'):
        overview_setting = community_setting.left_panel.open_overview()
        with step('Name is correct'):
            assert overview_setting.name == params['name']
        with step('Description is correct'):
            assert overview_setting.description == params['description']

    with step('Verify community parameters in community screen'):
        community_setting.left_panel.back_to_community()
        with step('Icon is correct'):
            community_icon = main_screen.left_panel.get_community_logo(params['name'])
            image.compare(community_icon, 'button_updated_logo.png')
        with step('Name is correct'):
            assert community_screen.left_panel.name == params['name']
        with step('Logo is correct'):
            image.compare(community_screen.left_panel.logo, 'updated_logo.png')

    with step('Verify community parameters in community settings screen'):
        settings_screen = main_screen.left_panel.open_settings()
        community_settings = settings_screen.open_communities_settings()
        community_info = community_settings.communities[0]
        assert community_info.name == params['name']
        assert community_info.description == params['description']
        assert '1' in community_info.members
        image.compare(community_info.image, 'logo_in_settings_updated.png')


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703049', 'Create community channel')
@pytest.mark.case(703049)
@pytest.mark.parametrize('community', [constants.user.default_community_params], indirect=True)
@pytest.mark.parametrize('channel_name, channel_description, channel_emoji', [('Channel', 'Description', 'sunglasses')])
def test_create_community_channel(main_screen: MainWindow, community: dict, channel_name, channel_description,
                                  channel_emoji):
    community_screen = main_screen.left_panel.select_community(community['name'])
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
@pytest.mark.parametrize('community', [constants.user.default_community_params], indirect=True)
@pytest.mark.parametrize('channel_name, channel_description, channel_emoji', [('Channel', 'Description', 'sunglasses')])
def test_edit_community_channel(community: dict, channel_name, channel_description, channel_emoji):
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
@pytest.mark.parametrize('community', [constants.user.default_community_params], indirect=True)
def test_delete_community_channel(community: dict):
    with step('Delete channel'):
        CommunityScreen().delete_channel('general')

    with step('Verify channel is not exists'):
        assert not CommunityScreen().left_panel.channels
