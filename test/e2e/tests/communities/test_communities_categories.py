import allure
import pytest
from allure_commons._allure import step

import configs
import constants
from gui.components.community.community_category_popup import EditCategoryPopup, CategoryPopup
from gui.components.context_menu import ContextMenu
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


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703233', 'Edit category')
@pytest.mark.case(703233)
@pytest.mark.parametrize(
    'category_name, general_checkbox, channel_name, channel_description, channel_emoji, second_channel_name, second_channel_description, second_channel_emoji',
    [
        pytest.param('Category in general', True, 'Channel', 'Description', 'sunglasses', 'Second-channel',
                     'Description', 'sunglasses')
    ])
def test_edit_community_category(main_screen: MainWindow, category_name, general_checkbox, channel_name,
                                 channel_description, channel_emoji, second_channel_name, second_channel_description,
                                 second_channel_emoji):
    with step('Create community and select it'):
        main_screen.create_community(constants.community_params)
        community_screen = main_screen.left_panel.select_community(constants.community_params['name'])

    with step('Create community category and verify that it displays correctly'):
        community_screen.create_category(category_name, general_checkbox)
        community_screen.verify_category(category_name)

    with step('Create community channel inside category'):
        community_screen.left_panel.open_new_channel_popup_in_category().create(channel_name, channel_description,
                                                                                channel_emoji)

    with step('Create community channel outside of category'):
        community_screen.create_channel(second_channel_name, second_channel_description, second_channel_emoji)

    with step('Verify that selected channel is listed outside of category'):
        assert community_screen.left_panel.get_channel_or_category_index(second_channel_name) == 0

    with step('Open edit category popup'):
        category_popup = community_screen.edit_category()
        category_popup.enter_category_title("New category").click_checkbox_by_index(0)
        category_popup.save()

    with step('Verify that selected channel is now listed inside category'):
        assert community_screen.left_panel.get_channel_or_category_index(second_channel_name) == 3

    with step('Open edit category popup'):
        category_popup = community_screen.edit_category()
        category_popup.click_checkbox_by_index(2)
        category_popup.save()

    with step('Verify that selected channel is now listed outside of category'):
        assert community_screen.left_panel.get_channel_or_category_index(second_channel_name) == 0


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703272', 'Member role cannot add category')
@pytest.mark.case(703272)
@pytest.mark.parametrize('user_data', [configs.testpath.TEST_USER_DATA / 'squisher'])
def test_member_role_cannot_add_categories(main_screen: MainWindow):
    with step('Choose community user is not owner of'):
        community_screen = main_screen.left_panel.select_community('Super community')
    with step('Verify that create channel or category button is not present'):
        assert not community_screen.left_panel.is_create_channel_or_category_button_visible()
    with step('Verify that add category button is not present'):
        assert not community_screen.left_panel.is_add_category_button_visible()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703273', 'Member role cannot edit category')
@pytest.mark.case(703273)
@pytest.mark.parametrize('user_data', [configs.testpath.TEST_USER_DATA / 'squisher'])
def test_member_role_cannot_edit_category(main_screen: MainWindow):
    with step('Choose community user is not owner of'):
        community_screen = main_screen.left_panel.select_community('Super community')
    with step('Right-click on category in the left navigation bar'):
        community_screen.left_panel.open_category_context_menu()
    with step('Verify that context menu does not appear'):
        assert not ContextMenu().is_visible
    with step('Verify that delete item is not present in more options context menu'):
        assert not community_screen.left_panel.open_more_options().is_edit_item_visible()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703274', 'Member role cannot delete category')
@pytest.mark.case(703274)
@pytest.mark.parametrize('user_data', [configs.testpath.TEST_USER_DATA / 'squisher'])
def test_member_role_cannot_delete_category(main_screen: MainWindow):
    with step('Choose community user is not owner of'):
        community_screen = main_screen.left_panel.select_community('Super community')
    with step('Right-click on category in the left navigation bar'):
        community_screen.left_panel.open_category_context_menu()
    with step('Verify that context menu does not appear'):
        assert not ContextMenu().is_visible
    with step('Verify that delete item is not present in more options context menu'):
        assert not community_screen.left_panel.open_more_options().is_delete_item_visible()
