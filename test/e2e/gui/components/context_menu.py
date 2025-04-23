import allure

from gui.components.community.community_category_popup import EditCategoryPopup
from gui.components.community.invite_contacts import InviteContactsPopup
from gui.components.community.leave_community_confirmation import LeaveCommunityConfirmationPopup
from gui.components.delete_popup import DeleteCategoryPopup
from gui.elements.object import QObject
from gui.objects_map import names, communities_names


class ContextMenu(QObject):

    def __init__(self):
        super(ContextMenu, self).__init__(names.contextMenu_PopupItem)
        self.menu_item = QObject(names.contextMenuItem)
        # wallet account context items
        self.add_watched_address_from_context = QObject(names.contextMenuItem_AddWatchOnly)
        self.delete_from_context = QObject(names.contextMenuItem_Delete)
        self.edit_from_context = QObject(names.contextMenuItem_Edit)
        self.copy_address_from_context = QObject(names.contextMenuItem_Copy_Address)
        self.hide_include_in_total_balance = QObject(names.contextMenuItem_HideInclude)
        self.edit_saved_address_from_context = QObject(names.contextSavedAddressEdit)
        self.delete_saved_address_from_context = QObject(names.contextSavedAddressDelete)
        # community context items
        self.edit_channel_from_context = QObject(communities_names.edit_Channel_StatusMenuItem)
        self.delete_channel_from_context = QObject(communities_names.delete_Channel_StatusMenuItem)
        self.invite_from_context = QObject(communities_names.invite_People_StatusMenuItem)
        self.mute_from_context = QObject(communities_names.mute_Community_StatusMenuItem)
        self.leave_community_option = QObject(communities_names.leave_Community_StatusMenuItem)
        self.edit_category_item = QObject(communities_names.edit_Category_StatusMenuItem)
        self.delete_category_item = QObject(communities_names.delete_Category_StatusMenuItem)
        self.community_invite_people_context_item = QObject(communities_names.invite_People_StatusMenuItem)

    @allure.step('Select in context menu')
    def select(self, value: str):
        self.menu_item.real_name['text'] = value
        self.menu_item.click()

    @allure.step('Select invite people to community in context menu')
    def select_invite_people(self):
        self.invite_from_context.click()
        return InviteContactsPopup()

    @allure.step('Select leave community in context menu')
    def leave_community(self):
        self.leave_community_option.click()
        return LeaveCommunityConfirmationPopup()

    @allure.step('Open edit category popup')
    def open_edit_category_popup(self) -> EditCategoryPopup:
        self.edit_category_item.click()
        return EditCategoryPopup().wait_until_appears()

    @allure.step('Open delete category popup')
    def open_delete_category_popup(self) -> DeleteCategoryPopup:
        self.delete_category_item.click()
        return DeleteCategoryPopup().wait_until_appears()

