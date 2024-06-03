import allure

from gui.components.community.invite_contacts import InviteContactsPopup
from gui.elements.object import QObject
from gui.objects_map import names, communities_names


class ContextMenu(QObject):

    def __init__(self):
        super(ContextMenu, self).__init__(names.contextMenu_PopupItem)
        self._menu_item = QObject(names.contextMenuItem)
        self._context_add_watched_address_option = QObject(names.contextMenuItem_AddWatchOnly)
        self._context_delete_account_option = QObject(names.contextMenuItem_Delete)
        self._context_edit_account_option = QObject(names.contextMenuItem_Edit)
        self._context_hide_include_in_total_balance = QObject(names.contextMenuItem_HideInclude)
        self._context_edit_saved_address_option = QObject(names.contextSavedAddressEdit)
        self._context_delete_saved_address_option = QObject(names.contextSavedAddressDelete)
        self._edit_channel_context_item = QObject(communities_names.edit_Channel_StatusMenuItem)
        self._delete_channel_context_item = QObject(communities_names.delete_Channel_StatusMenuItem)
        self._invite_people_item = QObject(communities_names.invite_People_StatusMenuItem)
        self._mute_community_item = QObject(communities_names.mute_Community_StatusMenuItem)

    @allure.step('Is edit channel option present in context menu')
    def is_edit_channel_option_present(self):
        return self._edit_channel_context_item.exists

    @allure.step('Is delete channel option present in context menu')
    def is_delete_channel_option_present(self):
        return self._delete_channel_context_item.exists

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

    @allure.step('Select invite people to community')
    def select_invite_people(self):
        self._invite_people_item.click()
        return InviteContactsPopup()
