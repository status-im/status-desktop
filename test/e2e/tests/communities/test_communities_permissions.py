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
@pytest.mark.parametrize(
    'checkbox_state, first_asset, second_asset, amount, allowed_to, in_channel, asset_title, second_asset_title, '
    'allowed_to_title',
    [
        pytest.param(True, 'Dai Stablecoin', False, '10', 'becomeMember', False, '10 DAI', False, 'Become member', ),
        pytest.param(True, 'Ether', False, '1', 'becomeAdmin', False, '1 ETH', False, 'Become an admin'),
        pytest.param(True, 'Ether', 'Dai Stablecoin', '10', 'viewAndPost', '#general', '10 ETH', '10 DAI',
                     'View and post'),
        pytest.param(True, 'Ether', 'Dai Stablecoin', '10', 'viewOnly', '#general', '10 ETH', '10 DAI', 'View only'),
        pytest.param(False, False, False, False, 'becomeAdmin', False, False, False, 'Become an admin')
    ])
def test_add_edit_and_remove_permissions(main_screen: MainWindow, params, checkbox_state: bool, first_asset,
                                         second_asset, amount, allowed_to: str, in_channel, asset_title,
                                         second_asset_title, allowed_to_title: str):
    main_screen.create_community(params['name'], params['description'],
                                 params['intro'], params['outro'],
                                 params['logo']['fp'], params['banner']['fp'])

    with step('Open add new permission page'):
        community_screen = main_screen.left_panel.select_community(params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        permissions_intro_view = community_setting.left_panel.open_permissions()
        permissions_settings = permissions_intro_view.add_new_permission()

    with step('Create new permission'):
        permissions_settings.set_who_holds_checkbox_state(checkbox_state)
        permissions_settings.set_who_holds_asset_and_amount(first_asset, amount)
        permissions_settings.set_who_holds_asset_and_amount(second_asset, amount)
        permissions_settings.set_is_allowed_to(allowed_to)
        permissions_settings.set_in(in_channel)
        permissions_settings.create_permission()

    with step('Check toast message for permission creation'):
        toast_messages = main_screen.wait_for_notification()
        assert len(toast_messages) == 1, \
            f"Multiple toast messages appeared"
        message = toast_messages[0]
        assert message == ToastMessages.CREATE_PERMISSION_TOAST.value, \
            f"Toast message is incorrect, current message is {message}"

    with step('Created permission is displayed on permission page'):
        if asset_title is not False:
            assert driver.waitFor(lambda: asset_title in permissions_settings.get_who_holds_tags_titles(),
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        if second_asset_title is not False:
            assert driver.waitFor(lambda: second_asset_title in permissions_settings.get_who_holds_tags_titles(),
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        if allowed_to_title is not False:
            assert driver.waitFor(lambda: allowed_to_title in permissions_settings.get_is_allowed_tags_titles(),
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        if in_channel is False:
            assert driver.waitFor(
                lambda: params['name'] in permissions_settings.get_in_community_in_channel_tags_titles(),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        if in_channel:
            assert driver.waitFor(lambda: in_channel in permissions_settings.get_in_community_in_channel_tags_titles(),
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

    with step('Edit permission'):
        edit_permission_view = permissions_intro_view.open_edit_permission_view()
        if allowed_to is 'becomeAdmin' and checkbox_state is True:
            permissions_settings.set_who_holds_checkbox_state(False)
        elif checkbox_state is False:
            permissions_settings.set_allowed_to_from_permission('becomeMember')
        else:
            edit_permission_view.switch_hide_permission_checkbox(True)

        changes_popup = PermissionsChangesDetectedToastMessage().wait_until_appears()

    with step('Confirm changes and verify that permission was changed'):
        changes_popup.update_permission()
        if allowed_to is 'becomeAdmin' and checkbox_state is True:
            if asset_title is not False:
                assert driver.waitFor(lambda: asset_title not in permissions_settings.get_who_holds_tags_titles(),
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            if second_asset_title is not False:
                assert driver.waitFor(
                    lambda: second_asset_title not in permissions_settings.get_who_holds_tags_titles(),
                    configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        elif checkbox_state is False:
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
def test_add_5_member_role_permissions(main_screen: MainWindow, params):
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
