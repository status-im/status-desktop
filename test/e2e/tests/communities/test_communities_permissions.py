import allure
import pytest
from allure_commons._allure import step

import configs
from gui.components.changes_detected_popup import PermissionsChangesDetectedToastMessage
from gui.components.delete_popup import DeletePermissionPopup
from gui.screens.community_settings import PermissionsIntroView
from . import marks

import constants
import driver
from constants.community_settings import ToastMessages, LimitWarnings
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703632',
                 'Manage community: Adding new permissions, Editing permissions, Deleting permission')
@pytest.mark.case(703632, 705014, 705016)
@pytest.mark.parametrize('params', [constants.community_params])
@pytest.mark.skip(reason="https://github.com/status-im/status-desktop/issues/15246")
def test_add_edit_and_remove_permissions(main_screen: MainWindow, params):
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    main_screen.create_community(params['name'], params['description'],
                                 params['intro'], params['outro'],
                                 params['logo']['fp'], params['banner']['fp'])

    permission_data = [
        {
            'checkbox_state': True,
            'first_asset': 'Dai Stablecoin',
            'second_asset': False,
            'amount': '10',
            'allowed_to': 'becomeMember',
            'in_channel': False,
            'asset_title': '10 DAI',
            'second_asset_title': False,
            'allowed_to_title': 'Become member'
        },
        {
            'checkbox_state': True,
            'first_asset': 'Ether',
            'second_asset': False,
            'amount': '1',
            'allowed_to': 'becomeAdmin',
            'in_channel': False,
            'asset_title': '1 ETH',
            'second_asset_title': False,
            'allowed_to_title': 'Become an admin'
        },
        {
            'checkbox_state': True,
            'first_asset': 'Ether',
            'second_asset': 'Dai Stablecoin',
            'amount': '10',
            'allowed_to': 'viewAndPost',
            'in_channel': '#general',
            'asset_title': '10 ETH',
            'second_asset_title': '10 DAI',
            'allowed_to_title': 'View and post'
        },
        {
            'checkbox_state': True,
            'first_asset': 'Ether',
            'second_asset': 'Dai Stablecoin',
            'amount': '10',
            'allowed_to': 'viewOnly',
            'in_channel': '#general',
            'asset_title': '10 ETH',
            'second_asset_title': '10 DAI',
            'allowed_to_title': 'View only'
        },
        {
            'checkbox_state': False,
            'first_asset': False,
            'second_asset': False,
            'amount': False,
            'allowed_to': 'becomeAdmin',
            'in_channel': False,
            'asset_title': False,
            'second_asset_title': False,
            'allowed_to_title': 'Become an admin'
        }
    ]

    with step('Open add new permission page'):
        community_screen = main_screen.left_panel.select_community(params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        permissions_intro_view = community_setting.left_panel.open_permissions()

    for index, item in enumerate(permission_data):
        with step('Create new permission'):
            permissions_settings = permissions_intro_view.add_new_permission()
            permissions_settings.set_who_holds_checkbox_state(permission_data[index]['checkbox_state'])
            permissions_settings.set_who_holds_asset_and_amount(permission_data[index]['first_asset'],
                                                                permission_data[index]['amount'])
            permissions_settings.set_who_holds_asset_and_amount(permission_data[index]['second_asset'],
                                                                permission_data[index]['amount'])
            permissions_settings.set_is_allowed_to(permission_data[index]['allowed_to'])
            permissions_settings.set_in(permission_data[index]['in_channel'])
            permissions_settings.create_permission()

        with step('Check toast message for permission creation'):
            toast_messages = main_screen.wait_for_notification()
            message = toast_messages[0]
            assert ToastMessages.CREATE_PERMISSION_TOAST.value in toast_messages, \
                f"Toast message is incorrect, current message is {message}"

        with step('Created permission is displayed on permission page'):
            if permission_data[index]['asset_title'] is not False:
                assert driver.waitFor(
                    lambda: permission_data[index]['asset_title'] in permissions_settings.get_who_holds_tags_titles(),
                    configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            if permission_data[index]['second_asset_title'] is not False:
                assert driver.waitFor(lambda: permission_data[index][
                                                  'second_asset_title'] in permissions_settings.get_who_holds_tags_titles(),
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            if permission_data[index]['allowed_to_title'] is not False:
                assert driver.waitFor(lambda: permission_data[index][
                                                  'allowed_to_title'] in permissions_settings.get_is_allowed_tags_titles(),
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            if permission_data[index]['in_channel'] is False:
                assert driver.waitFor(
                    lambda: params['name'] in permissions_settings.get_in_community_in_channel_tags_titles(),
                    configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            if permission_data[index]['in_channel']:
                assert driver.waitFor(lambda: permission_data[index][
                                                  'in_channel'] in permissions_settings.get_in_community_in_channel_tags_titles(),
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

        with step('Edit permission'):
            edit_permission_view = permissions_intro_view.open_edit_permission_view()
            if permission_data[index]['allowed_to'] is 'becomeAdmin' and permission_data[index][
                'checkbox_state'] is True:
                permissions_settings.set_who_holds_checkbox_state(False)
            elif permission_data[index]['checkbox_state'] is False:
                permissions_settings.set_allowed_to_from_permission('becomeMember')
            else:
                edit_permission_view.switch_hide_permission_checkbox(True)

            changes_popup = PermissionsChangesDetectedToastMessage().wait_until_appears()

        with step('Confirm changes and verify that permission was changed'):
            changes_popup.update_permission()
            if permission_data[index]['allowed_to'] is 'becomeAdmin' and permission_data[index][
                'checkbox_state'] is True:
                if permission_data[index]['asset_title'] is not False:
                    assert driver.waitFor(lambda: permission_data[index][
                                                      'asset_title'] not in permissions_settings.get_who_holds_tags_titles(),
                                          configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
                if permission_data[index]['second_asset_title'] is not False:
                    assert driver.waitFor(
                        lambda: permission_data[index][
                                    'second_asset_title'] not in permissions_settings.get_who_holds_tags_titles(),
                        configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            elif permission_data[index]['checkbox_state'] is False:
                assert driver.waitFor(lambda: 'Become member' in permissions_settings.get_is_allowed_tags_titles(),
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            else:
                assert driver.waitFor(lambda: permissions_intro_view.is_hide_icon_visible,
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

        with step('Check toast message for edited permission'):
            messages = main_screen.wait_for_notification()
            assert ToastMessages.UPDATE_PERMISSION_TOAST.value in messages, \
                f"Toast message is incorrect, current message is {message}"

        with step('Delete permission'):
            permissions_intro_view.click_delete_permission()
            DeletePermissionPopup().wait_until_appears().delete()

        with step('Verify that permission was deleted'):
            assert driver.waitFor(lambda: PermissionsIntroView().is_visible)

        with step('Check toast message for deleted permission'):
            messages = main_screen.wait_for_notification()
            assert ToastMessages.DELETE_PERMISSION_TOAST.value in messages, \
                f"Toast message is incorrect, current message is {message}"


@pytest.mark.parametrize('params', [constants.community_params])
@pytest.mark.skip(reason="https://github.com/status-im/status-desktop/issues/15246")
def test_add_5_member_role_permissions(main_screen: MainWindow, params):
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    main_screen.create_community(params['name'], params['description'],
                                 params['intro'], params['outro'],
                                 params['logo']['fp'], params['banner']['fp'])

    permission_data = [
        {
            'checkbox_state': True,
            'first_asset': 'Dai Stablecoin',
            'amount': '1',
            'allowed_to': 'becomeMember',
            'asset_title': '1 DAI',
            'allowed_to_title': 'Become member'
        },
        {
            'checkbox_state': True,
            'first_asset': 'Aragon',
            'amount': '2',
            'allowed_to': 'becomeMember',
            'asset_title': '2 ANT',
            'allowed_to_title': 'Become member'
        },
        {
            'checkbox_state': True,
            'first_asset': '1inch',
            'amount': '3',
            'allowed_to': 'becomeMember',
            'asset_title': '3 1INCH',
            'allowed_to_title': 'Become member'
        },
        {
            'checkbox_state': True,
            'first_asset': 'ABYSS',
            'amount': '4',
            'allowed_to': 'becomeMember',
            'asset_title': '4 ABYSS',
            'allowed_to_title': 'Become member'
        },
        {
            'checkbox_state': True,
            'first_asset': 'Bytom',
            'amount': '5',
            'allowed_to': 'becomeMember',
            'asset_title': '5 BTM',
            'allowed_to_title': 'Become member'
        }
    ]

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

        assert permissions_settings.is_member_role_warning_text_present(), 'Member role limit warning is not displayed'
        assert permissions_settings.get_member_role_limit_warning_text() \
               == LimitWarnings.MEMBER_ROLE_LIMIT_WARNING.value, \
            f'Warning text about become a member limit reached is incorrect'
