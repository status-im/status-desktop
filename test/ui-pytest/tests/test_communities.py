from datetime import datetime

import allure
import pytest
from allure_commons._allure import step

import configs.testpath
from gui.main_window import MainWindow
from scripts.tools import image

pytestmark = allure.suite("Communities")


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703084', 'Create community')
@pytest.mark.case(703084)
@pytest.mark.parametrize('community_params', [
        {
            'name': f'Name',
            'description': f'Description',
            'logo': {'fp': configs.testpath.TEST_FILES / 'tv_signal.png', 'zoom': None, 'shift': None},
            'banner': {'fp': configs.testpath.TEST_FILES / 'banner.png', 'zoom': None, 'shift': None},
            'color': '#ff7d46',
            'tags': ['Culture', 'Sports'],
            'intro': 'Intro',
            'outro': 'Outro'
        }
])
def test_create_community(user_account, main_screen: MainWindow, community_params):
    with step('Create community'):
        communities_portal = main_screen.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()
        community_screen = create_community_form.create(community_params)

    with step('Verify community parameters in community overview'):
        with step('Icon is correct'):
            community_icon = main_screen.left_panel.get_community_logo(community_params['name'])
            image.compare(community_icon, 'button_logo.png', timout_sec=5)
        with step('Name is correct'):
            assert community_screen.left_panel.name == community_params['name']
        with step('Members count is correct'):
            assert '1' in community_screen.left_panel.members
        with step('Logo is correct'):
            image.compare(community_screen.left_panel.logo, 'logo.png')

    with step('Verify community parameters in community settings view'):
        community_setting = community_screen.left_panel.open_community_settings()
        overview_setting = community_setting.left_panel.open_overview()
        with step('Name is correct'):
            assert overview_setting.name == community_params['name']
        with step('Description is correct'):
            assert overview_setting.description == community_params['description']
        with step('Members count is correct'):
            members_settings = community_setting.left_panel.open_members()
            assert user_account.name in members_settings.members

    with step('Verify community parameters in community settings screen'):
        settings_screen = main_screen.left_panel.open_settings()
        community_settings = settings_screen.open_communities_settings()
        community = community_settings.get_community_info(community_params['name'])
        assert community.name == community_params['name']
        assert community.description == community_params['description']
        assert '1' in community.members
        image.compare(community.image, 'logo_in_settings.png')


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703056', 'Edit community separately')
@pytest.mark.case(703056)
@pytest.mark.parametrize('default_params, update_params', [(
        {
            'name': 'Name',
            'description': 'Description',
            'logo': {'fp': configs.testpath.TEST_FILES / 'tv_signal.png', 'zoom': None, 'shift': None},
            'banner': {'fp': configs.testpath.TEST_FILES / 'banner.png', 'zoom': None, 'shift': None},
            'intro': 'Intro',
            'outro': 'Outro'
        },
        {
            'name': f'Name_{datetime.now():%H%M%S}',
            'description': f'Description_{datetime.now():%H%M%S}',
            'color': '#ff7d46',
        },

)])
def test_edit_community_separately(main_screen: MainWindow, default_params, update_params):
    with step('Create community'):
        communities_portal = main_screen.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()
        community_screen = create_community_form.create(default_params)

    with step('Edit community name'):
        community_setting = community_screen.left_panel.open_community_settings()
        edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
        edit_community_form.edit({'name': update_params['name']})

    with step('Name is correct'):
        overview_setting = community_setting.left_panel.open_overview()
        assert overview_setting.name == update_params['name']
    with step('Description is correct'):
        assert overview_setting.description == default_params['description']

    with step('Edit community name'):
        edit_community_form = overview_setting.open_edit_community_view()
        edit_community_form.edit({'description': update_params['description']})

    with step('Name is correct'):
        overview_setting = community_setting.left_panel.open_overview()
        assert overview_setting.name == update_params['name']
    with step('Description is correct'):
        assert overview_setting.description == update_params['description']


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703057', 'Edit community')
@pytest.mark.case(703057)
@pytest.mark.parametrize('default_params, community_params', [(
        {
            'name': f'Name_{datetime.now():%H%M%S}',
            'description': f'Description_{datetime.now():%H%M%S}',
            'logo': {'fp': configs.testpath.TEST_FILES / 'tv_signal.png', 'zoom': None, 'shift': None},
            'banner': {'fp': configs.testpath.TEST_FILES / 'banner.png', 'zoom': None, 'shift': None},
            'color': '#ff7d46',
            'tags': ['Culture', 'Sports'],
            'intro': 'Intro',
            'outro': 'Outro'
        },
        {
            'name': 'Updated Name',
            'description': 'Updated Description',
            'logo': {'fp': configs.testpath.TEST_FILES / 'banner.png', 'zoom': None, 'shift': None},
            'banner': {'fp': configs.testpath.TEST_FILES / 'tv_signal.png', 'zoom': None, 'shift': None},
            'color': '#7140fd',
            'tags': ['Ethereum'],
            'intro': 'Updated Intro',
            'outro': 'Updated Outro'
        }
)])
def test_edit_community(main_screen: MainWindow, default_params, community_params):
    with step('Create community'):
        communities_portal = main_screen.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()
        community_screen = create_community_form.create(default_params)

    with step('Edit community'):
        community_setting = community_screen.left_panel.open_community_settings()
        edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
        edit_community_form.edit(community_params)

    with step('Verify community parameters on settings overview'):
        overview_setting = community_setting.left_panel.open_overview()
        with step('Name is correct'):
            assert overview_setting.name == community_params['name']
        with step('Description is correct'):
            assert overview_setting.description == community_params['description']

    with step('Verify community parameters in community screen'):
        community_setting.left_panel.back_to_community()
        with step('Icon is correct'):
            community_icon = main_screen.left_panel.get_community_logo(community_params['name'])
            image.compare(community_icon, 'button_updated_logo.png')
        with step('Name is correct'):
            assert community_screen.left_panel.name == community_params['name']
        with step('Logo is correct'):
            image.compare(community_screen.left_panel.logo, 'updated_logo.png')

    with step('Verify community parameters in community settings screen'):
        settings_screen = main_screen.left_panel.open_settings()
        community_settings = settings_screen.open_communities_settings()
        community = community_settings.communities[0]
        assert community.name == community_params['name']
        assert community.description == community_params['description']
        assert '1' in community.members
        image.compare(community.image, 'logo_in_settings_updated.png')
