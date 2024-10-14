import allure
import pytest
from allure_commons._allure import step

import configs
import constants
import driver
from constants import permission_data_member
from constants.community_settings import LimitWarnings
from gui.main_window import MainWindow
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/739309',
                 'Can create up to 5 member role permissions')
@pytest.mark.case(739309)
@pytest.mark.parametrize('params', [constants.community_params])
def test_add_5_member_role_permissions(main_screen: MainWindow, params):

    permission_data = permission_data_member
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    main_screen.create_community(params['name'], params['description'],
                                 params['intro'], params['outro'],
                                 params['logo']['fp'], params['banner']['fp'],
                                 ['Activism', 'Art'], constants.community_tags[:2])

    with step('Open add new permission page'):
        community_screen = main_screen.left_panel.select_community(params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        permissions_intro_view = community_setting.left_panel.open_permissions()

    with step('Create new permission'):
        for index, item in enumerate(permission_data):
            permissions_settings = permissions_intro_view.add_new_permission()
            permissions_settings.set_who_holds_checkbox_state(permission_data[index]['checkbox_state'])
            permissions_settings.set_who_holds_asset_and_amount(permission_data[index]['first_asset'],
                                                                permission_data[index]['amount'])
            permissions_settings.set_is_allowed_to(permission_data[index]['allowed_to'])
            permissions_settings.create_permission()

        with step('Created permission is displayed on permission page'):
            if permission_data[index]['asset_title'] is not False:
                assert driver.waitFor(
                    lambda: permission_data[index]['asset_title'] in permissions_settings.get_who_holds_tags_titles(),
                    configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

    with step('Open form to create 6th member role permission and validate it is not allowed'):
        extra_permission_data = {
            'checkbox_state': True,
            'first_asset': 'Bytom',
            'amount': '6',
            'allowed_to': 'becomeMember'
        }
        permissions_settings = permissions_intro_view.add_new_permission()
        permissions_settings.set_who_holds_checkbox_state(extra_permission_data['checkbox_state'])
        permissions_settings.set_who_holds_asset_and_amount(extra_permission_data['first_asset'],
                                                            extra_permission_data['amount'])
        permissions_settings.set_is_allowed_to(extra_permission_data['allowed_to'])

        assert permissions_settings.is_warning_text_present(), 'Member role limit warning is not displayed'
        assert permissions_settings.get_warning_text() \
               == LimitWarnings.MEMBER_ROLE_LIMIT_WARNING.value, \
            f'Warning text about become a member limit reached is incorrect'
