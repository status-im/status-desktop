import allure
import pytest
from allure_commons._allure import step

import constants
from gui.main_window import MainWindow
from . import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703226', 'Add category')
@pytest.mark.case(703226)
@pytest.mark.parametrize('category_name, general_checkbox', [
    pytest.param('Category in general', True, marks=pytest.mark.critical),
    pytest.param('Category out of general', False)
])
def test_create_community_category(main_screen: MainWindow, category_name, general_checkbox):
    main_screen.create_community(constants.community_params)
    community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
    community_screen.create_category(category_name, general_checkbox)

    with step('Verify category'):
        community_screen.verify_category(category_name)


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703227', 'Remove category')
@pytest.mark.case(703227)
@pytest.mark.parametrize('category_name, general_checkbox, channel_name, channel_description, channel_emoji', [
    pytest.param('Category in general', True, 'Channel', 'Description', 'sunglasses')
])
def test_remove_community_category(main_screen: MainWindow, category_name, general_checkbox, channel_name,
                                   channel_description, channel_emoji):
    main_screen.create_community(constants.community_params)
    community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
    community_screen.create_category(category_name, general_checkbox)

    with step('Verify category'):
        community_screen.verify_category(category_name)

    with step('Create channel inside category'):
        community_screen.left_panel.open_new_channel_popup_in_category().create(channel_name, channel_description,
                                                                                channel_emoji)

    with step('Delete category'):
        community_screen.delete_category()

    with step('Verify category is not in the list'):
        assert category_name not in community_screen.left_panel.categories_items

    with step('Verify created channel and general channel are still in the list'):
        new_channel = community_screen.left_panel.get_channel_parameters(channel_name)
        general_channel = community_screen.left_panel.get_channel_parameters('general')
        assert new_channel in community_screen.left_panel.channels
        assert general_channel in community_screen.left_panel.channels
