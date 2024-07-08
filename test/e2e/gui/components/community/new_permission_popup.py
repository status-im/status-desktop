import allure

import configs
import driver
from driver.objects_access import walk_children
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import communities_names


class NewPermissionPopup(QObject):
    def __init__(self):
        super(NewPermissionPopup, self).__init__()
        self._who_holds_checkbox = CheckBox(communities_names.whoHoldsSwitch_StatusSwitch)
        self._who_holds_asset_field = TextEdit(communities_names.edit_TextEdit)
        self._who_holds_amount_field = TextEdit(communities_names.inputValue_StyledTextField)
        self._asset_item = QObject(communities_names.o_TokenItem)
        self._is_allowed_to_option_button = Button(communities_names.customPermissionListItem)
        self._hide_permission_checkbox = CheckBox(communities_names.switchItem_StatusSwitch)
        self._create_permission_button = Button(communities_names.create_permission_StatusButton)
        self._add_button_who_holds = Button(communities_names.add_update_statusButton)
        self._add_button_is_allowed_to = Button(communities_names.add_StatusButton)
        self._who_holds_list_item = QObject(communities_names.who_holds_StatusItemSelector)
        self._is_allowed_to_list_item = QObject(communities_names.is_allowed_to_StatusFlowSelector)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        driver.waitForObjectExists(self._create_permission_button.real_name, timeout_msec)
        return self

    @allure.step('Set state of who holds checkbox')
    def set_who_holds_checkbox_state(self, state):
        if state is False:
            self._who_holds_checkbox.set(state)

    @allure.step('Open Who holds context menu')
    def open_who_holds_context_menu(self, attempt: int = 2):
        try:
            for child in walk_children(self._who_holds_list_item.object):
                if getattr(child, 'objectName', '') == 'addItemButton':
                    driver.mouseClick(child)
                    return self._who_holds_asset_field.wait_until_appears()
        except AssertionError:
            if attempt:
                return self.open_who_holds_context_menu(attempt - 1)
            else:
                raise LookupError('Add button for who holds not found')

    @allure.step('Open Is allowed to context menu')
    def open_is_allowed_to_context_menu(self, attempt: int = 2):
        try:
            for child in walk_children(self._is_allowed_to_list_item.object):
                if getattr(child, 'objectName', '') == 'addItemButton':
                    driver.mouseClick(child)
                    return
        except LookupError:
            if attempt:
                return self.open_is_allowed_to_context_menu(attempt - 1)
            else:
                raise LookupError('Add button for allowed to not found')

    @allure.step('Set asset and amount')
    def set_who_holds_asset_and_amount(self, asset: str, amount: str):
        if asset is not False:
            self.open_who_holds_context_menu()
            self._who_holds_asset_field.clear().text = asset
            self._asset_item.click()
            self._who_holds_asset_field.wait_until_hidden()
            self._who_holds_amount_field.text = amount
            self.click_add_button_who_holds()
        return self

    @allure.step('Choose option from Is allowed to context menu')
    def set_is_allowed_to(self, name):
        self.open_is_allowed_to_context_menu()
        self._is_allowed_to_option_button.real_name['objectName'] = name
        self._is_allowed_to_option_button.wait_until_appears().click()
        self.click_add_button_is_allowed()
        return self

    @allure.step('Click add button for who holds')
    def click_add_button_who_holds(self, attempt: int = 2):
        self._add_button_who_holds.click()
        try:
            self._add_button_who_holds.wait_until_hidden()
        except AssertionError as err:
            if attempt:
                self.click_add_button_who_holds(attempt - 1)
            else:
                raise err

    @allure.step('Click add button is allowed')
    def click_add_button_is_allowed(self, attempt: int = 2):
        self._add_button_is_allowed_to.click()
        try:
            self._add_button_is_allowed_to.wait_until_hidden()
        except AssertionError as err:
            if attempt:
                self.click_add_button_is_allowed(attempt - 1)
            else:
                raise err

    @allure.step('Click create permission')
    def create_permission(self):
        self._create_permission_button.click()
        self._create_permission_button.wait_until_hidden()

    @allure.step('Switch hide permission checkbox')
    def switch_hide_permission_checkbox(self, state):
        self._hide_permission_checkbox.set(state)
        return self
