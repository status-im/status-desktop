import allure
import pytest
from allure_commons._allure import step
from . import marks

import configs.testpath
import constants
from gui.main_window import MainWindow

pytestmark = marks


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
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()
    community_params = constants.community_params
    main_screen.create_community(community_params['name'], community_params['description'],
                                 community_params['intro'], community_params['outro'],
                                 community_params['logo']['fp'], community_params['banner']['fp'],
                                 ['Activism', 'Art'], constants.community_tags[:2])

    with step('Edit community'):
        community_screen = main_screen.left_panel.select_community(community_params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
        edit_community_form.edit(params['name'], params['description'],
                                 params['intro'], params['outro'],
                                 params['logo']['fp'], params['banner']['fp'])

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
