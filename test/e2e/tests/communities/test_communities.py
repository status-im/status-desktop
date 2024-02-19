import allure
import pytest
from allure_commons._allure import step

import driver
from constants import ColorCodes
from . import marks

import configs.testpath
import constants
from gui.main_window import MainWindow

pytestmark = marks


@pytest.mark.critical
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703630', 'Create community')
@pytest.mark.case(703630)
@pytest.mark.parametrize('params', [constants.community_params])
def test_create_community(user_account, main_screen: MainWindow, params):
    tags_to_set = constants.community_tags[:2]
    color = ColorCodes.ORANGE.value
    with step('Open create community popup'):
        communities_portal = main_screen.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()

    with step('Verify community popup fields'):
        with step('Next button is disabled'):
            assert not driver.waitFor(lambda: create_community_form.is_next_button_enabled,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC), \
                'Next button is enabled'

        with step('Select color and verify that selected color is displayed in colorpicker field'):
            create_community_form.color = color
            assert create_community_form.color == color

        with step(
                'Select tags, verify that count of tags was changed and verify that selected tags are displayed in tags field'):
            create_community_form.tags = ['Activism', 'Art']
            assert create_community_form.tags == tags_to_set

        with step('Verify that checkboxes have correct default states'):
            assert create_community_form.is_archive_checkbox_checked
            assert not create_community_form.is_pin_messages_checkbox_checked
            assert not create_community_form.is_request_to_join_checkbox_checked

        community_screen = create_community_form.create_community(params['name'], params['description'],
                                                                  params['intro'], params['outro'],
                                                                  params['logo']['fp'], params['banner']['fp'])

    with step('Verify community parameters in community overview'):
        with step('Name is correct'):
            assert community_screen.left_panel.name == params['name']
        with step('Members count is correct'):
            assert '1' in community_screen.left_panel.members

    with step('Verify General channel is present for recently created community'):
        community_screen.verify_channel(
            'general',
            'General channel for the community',
            None,
            color
        )

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
    community_params = constants.community_params
    main_screen.create_community(community_params['name'], community_params['description'],
                                 community_params['intro'], community_params['outro'],
                                 community_params['logo']['fp'], community_params['banner']['fp'])

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
