import allure

from gui.elements.object import QObject


class ContextMenu(QObject):

    def __init__(self):
        super(ContextMenu, self).__init__('contextMenu_PopupItem')
        self._menu_item = QObject('contextMenuItem')
        self._context_add_watched_address_option = QObject('contextMenuItem_AddWatchOnly')
        self._context_delete_account_option = QObject('contextMenuItem_Delete')
        self._context_edit_account_option = QObject('contextMenuItem_Edit')
        self._context_hide_include_in_total_balance = QObject('contextMenuItem_HideInclude')
        self._context_edit_saved_address_option = QObject('contextSavedAddressEdit')
        self._context_delete_saved_address_option = QObject('contextSavedAddressDelete')

    @allure.step('Select in context menu')
    def select(self, value: str):
        self._menu_item.real_name['text'] = value
        self._menu_item.click()

    @allure.step('Click Edit saved address option')
    def select_edit_saved_address(self):
        self._context_edit_saved_address_option.click()

    @allure.step('Click Delete saved address option')
    def select_delete_saved_address(self):
        self._context_delete_saved_address_option.click()

    @allure.step('Select add watched address option from context menu')
    def select_add_watched_address_from_context_menu(self):
        self._context_add_watched_address_option.click()

    @allure.step('Select delete account option from context menu')
    def select_delete_account_from_context_menu(self):
        self._context_delete_account_option.click()

    @allure.step('Select Hide/Include in total balance option from context menu')
    def select_hide_include_total_balance_from_context_menu(self):
        self._context_hide_include_in_total_balance.click()

    @allure.step('Select edit account option from context menu')
    def select_edit_account_from_context_menu(self):
        self._context_edit_account_option.click()

    @allure.step('Check delete option visibility in context menu')
    def is_delete_account_option_present(self):
        return self._context_delete_account_option.is_visible
