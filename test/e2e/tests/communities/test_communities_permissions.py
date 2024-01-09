import allure
import pytest
from allure_commons._allure import step

from gui.components.toast_message import ToastMessage
from . import marks

import constants
import driver
from constants.community_settings import PermissionsElements, ToastMessages
from constants.images_paths import PERMISSION_WELCOME_IMAGE_PATH
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703632',
                 'Manage community: Adding new permissions')
@pytest.mark.case(703632)
@pytest.mark.parametrize('params', [constants.community_params])
@pytest.mark.parametrize(
    'checkbox_state, first_asset, second_asset, amount, allowed_to, in_channel, asset_title, second_asset_title, '
    'allowed_to_title',
    [
        pytest.param(True, 'Dai Stablecoin', False, '10', 'becomeMember', False, '10 DAI', False, 'Become member'),
        pytest.param(True, 'Ether', False, '1', 'becomeAdmin', False, '1 ETH', False, 'Become an admin'),
        pytest.param(True, 'Ether', 'Dai Stablecoin', '10', 'viewAndPost', '#general', '10 ETH', '10 DAI',
                     'View and post'),
        pytest.param(True, 'Ether', 'Dai Stablecoin', '10', 'viewOnly', '#general', '10 ETH', '10 DAI', 'View only'),
        pytest.param(False, False, False, False, 'becomeAdmin', False, False, False, 'Become an admin')
    ])
def test_adding_permissions(main_screen: MainWindow, params, checkbox_state: bool, first_asset, second_asset, amount,
                            allowed_to: str, in_channel, asset_title, second_asset_title, allowed_to_title: str):
    main_screen.create_community(params)

    with step('Open add new permission page'):
        community_screen = main_screen.left_panel.select_community(params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        permissions_settings = community_setting.left_panel.open_permissions().add_new_permission()

    with step('Create new permission'):
        permissions_settings.set_who_holds_checkbox_state(checkbox_state)
        permissions_settings.set_who_holds_asset_and_amount(first_asset, amount)
        permissions_settings.set_who_holds_asset_and_amount(second_asset, amount)
        permissions_settings.set_is_allowed_to(allowed_to)
        permissions_settings.set_in(in_channel)
        permissions_settings.create_permission()

    with step('Check toast message for permission creation'):
        assert len(ToastMessage().get_toast_messages) == 1, \
            f"Multiple toast messages appeared"
        message = ToastMessage().get_toast_messages[0]
        assert message == ToastMessages.CREATE_PERMISSION_TOAST.value, \
            f"Toast message is incorrect, current message is {message}"

    with step('Created permission is displayed on permission page'):
        if asset_title is not False:
            assert driver.waitFor(lambda: asset_title in permissions_settings.get_who_holds_tags_titles())
        if second_asset_title is not False:
            assert driver.waitFor(lambda: second_asset_title in permissions_settings.get_who_holds_tags_titles())
        if allowed_to_title is not False:
            assert driver.waitFor(lambda: allowed_to_title in permissions_settings.get_is_allowed_tags_titles())
        if in_channel is False:
            assert driver.waitFor(
                lambda: params['name'] in permissions_settings.get_in_community_in_channel_tags_titles())
        if in_channel:
            assert driver.waitFor(lambda: in_channel in permissions_settings.get_in_community_in_channel_tags_titles())
