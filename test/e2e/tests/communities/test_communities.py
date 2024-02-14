from datetime import datetime

import allure
import pytest
from allure_commons._allure import step
from . import marks

import configs.testpath
import constants
from gui.main_window import MainWindow

pytestmark = marks


# @pytest.mark.critical TODO: https://github.com/status-im/status-desktop/issues/13483
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703084', 'Create community')
@pytest.mark.case(703084)
@pytest.mark.parametrize('params', [constants.community_params])
def test_create_community(user_account, main_screen: MainWindow, params):
    with step('Create community'):
        communities_portal = main_screen.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()
        community_screen = create_community_form.create_community(params)

    with step('Verify community parameters in community overview'):
        with step('Name is correct'):
            assert community_screen.left_panel.name == params['name']
        with step('Members count is correct'):
            assert '1' in community_screen.left_panel.members

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
        community_settings = settings_screen.left_panel.open_communities_settings()
        community = community_settings.get_community_info(params['name'])
        assert community.name == params['name']
        assert community.description == params['description']
        assert '1' in community.members


@pytest.mark.skip(reason='https://github.com/status-im/desktop-qa-automation/issues/487')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703056', 'Edit community separately')
@pytest.mark.case(703056)
@pytest.mark.parametrize('community_params', [
    {
        'name': f'Name_{datetime.now():%H%M%S}',
        'description': f'Description_{datetime.now():%H%M%S}',
        'color': '#ff7d46',
    },
])
def test_edit_community_separately(main_screen, community_params):
    main_screen.create_community(constants.community_params)

    with step('Edit community name'):
        community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
        edit_community_form.edit({'name': community_params['name']})

    with step('Name is correct'):
        overview_setting = community_setting.left_panel.open_overview()
        assert overview_setting.name == community_params['name']
    with step('Description is correct'):
        assert overview_setting.description == constants.community_params['description']

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
@pytest.mark.critical
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
def test_edit_community(main_screen: MainWindow, params):
    main_screen.create_community(constants.community_params)

    with step('Edit community'):
        community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
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
        with step('Name is correct'):
            assert community_screen.left_panel.name == params['name']

    with step('Verify community parameters in community settings screen'):
        settings_screen = main_screen.left_panel.open_settings()
        community_settings = settings_screen.left_panel.open_communities_settings()
        community_info = community_settings.communities[0]
        assert community_info.name == params['name']
        assert community_info.description == params['description']
        assert '1' in community_info.members
