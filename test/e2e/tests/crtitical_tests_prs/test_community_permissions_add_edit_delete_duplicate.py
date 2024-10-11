import random

import allure
import pytest
from allure_commons._allure import step

import configs
import constants
import driver
from constants import permission_data
from constants.community_settings import ToastMessages, PermissionsElements
from gui.components.changes_detected_popup import PermissionsChangesDetectedToastMessage
from gui.components.delete_popup import DeletePermissionPopup
from gui.main_window import MainWindow
from gui.screens.community_settings import PermissionsIntroView
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703632',
                 'Manage community: Adding new permissions, Editing permissions, Deleting permission')
@pytest.mark.case(703632, 705014, 705016)
@pytest.mark.parametrize('params', [constants.community_params])
@pytest.mark.critical
def test_add_edit_remove_duplicate_permissions(main_screen: MainWindow, params):
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    main_screen.create_community(params['name'], params['description'],
                                 params['intro'], params['outro'],
                                 params['logo']['fp'], params['banner']['fp'],
                                 ['Activism', 'Art'], constants.community_tags[:2])

    permission_set = random.choice(permission_data)

    with step('Open add new permission page'):
        community_screen = main_screen.left_panel.select_community(params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        permissions_intro_view = community_setting.left_panel.open_permissions()

    with step('Create new permission'):
        permissions_settings = permissions_intro_view.add_new_permission()
        permissions_settings.set_who_holds_checkbox_state(permission_set['checkbox_state'])
        permissions_settings.set_who_holds_asset_and_amount(permission_set['first_asset'],
                                                            permission_set['amount'])
        permissions_settings.set_who_holds_asset_and_amount(permission_set['second_asset'],
                                                            permission_set['amount'])
        permissions_settings.set_is_allowed_to(permission_set['allowed_to'])
        permissions_settings.set_in(permission_set['in_channel'])
        permissions_settings.create_permission()

    with step('Check toast message for permission creation'):
        toast_messages = main_screen.wait_for_notification()
        message = toast_messages[0]
        assert ToastMessages.CREATE_PERMISSION_TOAST.value in toast_messages, \
            f"Toast message is incorrect, current message is {message}"

    with step('Created permission is displayed on permission page'):
        if permission_set['asset_title'] is not False:
            assert driver.waitFor(
                lambda: permission_set['asset_title'] in permissions_settings.get_who_holds_tags_titles(),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        if permission_set['second_asset_title'] is not False:
            assert driver.waitFor(lambda: permission_set[
                                              'second_asset_title'] in permissions_settings.get_who_holds_tags_titles(),
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        if permission_set['allowed_to_title'] is not False:
            assert driver.waitFor(lambda: permission_set[
                                              'allowed_to_title'] in permissions_settings.get_is_allowed_tags_titles(),
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        if permission_set['in_channel'] is False:
            assert driver.waitFor(
                lambda: params['name'] in permissions_settings.get_in_community_in_channel_tags_titles(),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        if permission_set['in_channel']:
            assert driver.waitFor(lambda: permission_set[
                                              'in_channel'] in permissions_settings.get_in_community_in_channel_tags_titles(),
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

    with step('Edit permission'):
        edit_permission_view = permissions_intro_view.open_edit_permission_view()
        if permission_set['allowed_to'] is 'becomeAdmin' and permission_set['checkbox_state'] is True:
            permissions_settings.set_who_holds_checkbox_state(False)
        elif permission_set['checkbox_state'] is False:
            permissions_settings.set_allowed_to_from_permission('becomeMember')
        else:
            edit_permission_view.switch_hide_permission_checkbox(True)

        changes_popup = PermissionsChangesDetectedToastMessage().wait_until_appears()

    with step('Confirm changes and verify that permission was changed'):
        changes_popup.update_permission()
        if permission_set['allowed_to'] is 'becomeAdmin' and permission_set[
            'checkbox_state'] is True:
            if permission_set['asset_title'] is not False:
                assert driver.waitFor(lambda: permission_set[
                                                  'asset_title'] not in permissions_settings.get_who_holds_tags_titles(),
                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            if permission_set['second_asset_title'] is not False:
                assert driver.waitFor(
                    lambda: permission_set[
                                'second_asset_title'] not in permissions_settings.get_who_holds_tags_titles(),
                    configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        elif permission_set['checkbox_state'] is False:
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

    with step('Create new permission'):
        new_permission_data = {
            'checkbox_state': True,
            'first_asset': 'ETH',
            'amount': '6',
            'allowed_to': 'becomeMember'
        }
        permissions_settings = permissions_intro_view.add_new_permission()
        permissions_settings.set_who_holds_checkbox_state(new_permission_data['checkbox_state'])
        permissions_settings.set_who_holds_asset_and_amount(new_permission_data['first_asset'],
                                                            new_permission_data['amount'])
        permissions_settings.set_is_allowed_to(new_permission_data['allowed_to'])
        permissions_settings.create_permission()

    with step('Duplicate created permission and verify correct duplicate warning appears'):
        permission_view = permissions_intro_view.click_duplicate_permission()
        assert permission_view.get_warning_text() == PermissionsElements.DUPLICATE_WARNING.value
        permissions_settings.set_who_holds_asset_and_amount('Aragon', '10')
        permissions_settings.create_permission()

    with step('Duplicated permission is displayed on permission page'):
        assert driver.waitFor(
            lambda: '10 ANT' in permissions_settings.get_who_holds_tags_titles(),
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
