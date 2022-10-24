# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    StatusCommunityScreen.py
# *
# * \date    July 2022
# * \brief   Community Screen.
# *****************************************************************************/


from enum import Enum
import time
from unittest import TestSuite

from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from drivers.SDKeyboardCommands import *
from .StatusMainScreen import StatusMainScreen
from utils.FileManager import *
from screens.StatusChatScreen import MessageContentType

class CommunityCreateMethods(Enum):
    BOTTOM_MENU = "bottom_menu"
    RIGHT_CLICK_MENU = "right_click_menu"

class CommunityScreenComponents(Enum):
    CHAT_LOG = "chatView_log"  
    COMMUNITY_HEADER_BUTTON = "mainWindow_communityHeader_StatusChatInfoButton"
    COMMUNITY_HEADER_NAME_TEXT= "community_ChatInfo_Name_Text"
    COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON = "mainWindow_createChannelOrCategoryBtn_StatusBaseText"
    COMMUNITY_CREATE_CHANNEL_MENU_ITEM = "create_channel_StatusMenuItemDelegate"
    COMMUNITY_CREATE_CATEGORY_MENU_ITEM = "create_category_StatusMenuItemDelegate"
    COMMUNITY_EDIT_CATEGORY_MENU_ITEM = "edit_сategory_StatusMenuItemDelegate"
    COMMUNITY_DELETE_CATEGORY_MENU_ITEM = "delete_сategory_StatusMenuItemDelegate"
    COMMUNITY_CONFIRM_DELETE_CATEGORY_BUTTON = "confirmDeleteCategoryButton_StatusButton"
    CHAT_IDENTIFIER_CHANNEL_ICON = "mainWindow_chatInfoBtnInHeader_StatusChatInfoButton"
    CHAT_MORE_OPTIONS_BUTTON = "chat_moreOptions_menuButton"
    EDIT_CHANNEL_MENU_ITEM = "edit_Channel_StatusMenuItemDelegate"
    COMMUNITY_COLUMN_VIEW = "mainWindow_communityColumnView_CommunityColumnView"
    DELETE_CHANNEL_MENU_ITEM = "delete_Channel_StatusMenuItemDelegate"
    DELETE_CHANNEL_CONFIRMATION_DIALOG_DELETE_BUTTON = "delete_Channel_ConfirmationDialog_DeleteButton"
    NOT_CATEGORIZED_CHAT_LIST = "mainWindow_communityColumnView_statusChatList"
    COMMUNITY_CHAT_LIST_CATEGORIES = "communityChatListCategories_Repeater"
    CHAT_INPUT_ROOT = "chatInput_Root"
    TOGGLE_PIN_MESSAGE_BUTTON = "chatView_TogglePinMessageButton"
    PIN_TEXT = "chatInfoButton_Pin_Text"
    ADD_MEMBERS_BUTTON = "community_AddMembers_Button"
    EXISTING_CONTACTS_LISTVIEW = "community_InviteFirends_Popup_ExistinContacts_ListView"
    INVITE_POPUP_NEXT_BUTTON = "community_InviteFriendsToCommunityPopup_NextButton"
    INVITE_POPUP_MESSAGE_INPUT = "community_ProfilePopupInviteMessagePanel_MessageInput"
    INVITE_POPUP_SEND_BUTTON = "community_InviteFriend_SendButton"

class CommunitySettingsComponents(Enum):
    EDIT_COMMUNITY_SCROLL_VIEW = "communitySettings_EditCommunity_ScrollView"
    EDIT_COMMUNITY_BUTTON = "communitySettings_EditCommunity_Button"
    EDIT_COMMUNITY_NAME_INPUT = "communitySettings_EditCommunity_Name_Input"
    EDIT_COMMUNITY_DESCRIPTION_INPUT = "communitySettings_EditCommunity_Description_Input"
    EDIT_COMMUNITY_COLOR_PICKER_BUTTON = "communitySettings_EditCommunity_ColorPicker_Button"
    SAVE_BUTTON = "settingsSave_StatusButton"
    BACK_TO_COMMUNITY_BUTTON = "communitySettings_BackToCommunity_Button"
    COMMUNITY_NAME_TEXT = "communitySettings_CommunityName_Text"
    COMMUNITY_DESCRIPTION_TEXT = "communitySettings_CommunityDescription_Text"
    COMMUNITY_LETTER_IDENTICON = "communitySettings_Community_LetterIdenticon"
    MEMBERS_BUTTON = "communitySettings_Members_NavigationListItem"
    MEMBERS_TAB_MEMBERS_LISTVIEW = "communitySettings_MembersTab_Members_ListView"
    MEMBER_KICK_BUTTON = "communitySettings_MembersTab_Member_Kick_Button"
    MEMBER_CONFIRM_KICK_BUTTON = "communitySettings_KickModal_Kick_Button"

class CommunityColorPanelComponents(Enum):
    HEX_COLOR_INPUT = "communitySettings_ColorPanel_HexColor_Input"
    SAVE_COLOR_BUTTON = "communitySettings_SaveColor_Button"

class CreateOrEditCommunityChannelPopup(Enum):
    COMMUNITY_CHANNEL_NAME_INPUT: str = "createOrEditCommunityChannelNameInput_TextEdit"
    COMMUNITY_CHANNEL_DESCRIPTION_INPUT: str = "createOrEditCommunityChannelDescriptionInput_TextEdit"
    COMMUNITY_CHANNEL_SAVE_OR_CREATE_BUTTON: str = "createOrEditCommunityChannelBtn_StatusButton"
    EMOJI_BUTTON: str = "createOrEditCommunityChannel_EmojiButton"
    EMOJI_SEARCH_TEXT_INPUT: str = "statusDesktop_mainWindow_AppMain_EmojiPopup_SearchTextInput"
    EMOJI_POPUP_EMOJI_PLACEHOLDER = "createOrEditCommunityChannel_Emoji_Button_Placeholder"

class CreateOrEditCommunityCategoryPopup(Enum):
    COMMUNITY_CATEGORY_NAME_INPUT: str = "createOrEditCommunityCategoryNameInput_TextEdit"
    COMMUNITY_CATEGORY_LIST: str = "createOrEditCommunityCategoryChannelList_ListView"
    COMMUNITY_CATEGORY_LIST_ITEM_PLACEHOLDER: str = "createOrEditCommunityCategoryChannelList_ListItem_Placeholder"
    COMMUNITY_CATEGORY_BUTTON: str = "createOrEditCommunityCategoryBtn_StatusButton"

class StatusCommunityScreen:

    def __init__(self):
        self._retry_number = 0
        verify_screen(CommunityScreenComponents.COMMUNITY_HEADER_BUTTON.value)

    def _find_channel_in_category_popup(self, community_channel_name: str):
        listView = get_obj(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_LIST.value)

        for index in range(listView.count):
            listItem = listView.itemAtIndex(index)
            if (listItem.objectName.toLower() == community_channel_name.lower()):
                return True, listItem
        return False, None

    def _find_category_in_chat(self, community_category_name: str):
        chatListCategories = get_obj(CommunityScreenComponents.COMMUNITY_CHAT_LIST_CATEGORIES.value)

        for index in range(chatListCategories.count):
            item = chatListCategories.itemAt(index)
            if (item.objectName == community_category_name):
                return True, item
        return False, None

    def _toggle_channels_in_category_popop(self, community_channel_names: str):
        for channel_name in community_channel_names.split(", "):
            [loaded, channel] = self._find_channel_in_category_popup(channel_name)
            if loaded:
                click_obj(channel)
            else:
                verify_failure("Can't find channel " + channel_name)

    def _get_checked_channel_names_in_category_popup(self, channel_name = ""):
        listView = wait_and_get_obj(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_LIST.value)
        
        if (channel_name != ""):
            # Wait for the list item to be loaded
            wait_by_wildcards(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_LIST_ITEM_PLACEHOLDER.value, "%NAME%", channel_name)
        
        result = []

        for index in range(listView.count):
            listItem = listView.itemAtIndex(index)
            if (listItem.checked):
                result.append(listItem.objectName.toLower())

        return result

    def _open_edit_channel_popup(self):
        click_obj_by_name(CommunityScreenComponents.CHAT_MORE_OPTIONS_BUTTON.value)
        click_obj_by_name(CommunityScreenComponents.EDIT_CHANNEL_MENU_ITEM.value)

    def _open_category_edit_popup(self, category):
        # For some reason it clicks on a first channel in category instead of category
        click_obj(category.chatListCategory.statusChatListCategoryItem)
        right_click_obj(category.chatListCategory.statusChatListCategoryItem)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_EDIT_CATEGORY_MENU_ITEM.value)

    def verify_community_name(self, communityName: str):
        verify_text_matching(CommunityScreenComponents.COMMUNITY_HEADER_NAME_TEXT.value, communityName)

    def create_community_channel(self, communityChannelName: str, communityChannelDescription: str, method: str):
        if (method == CommunityCreateMethods.BOTTOM_MENU.value):
            click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON.value)
        elif (method == CommunityCreateMethods.RIGHT_CLICK_MENU.value):
            right_click_obj_by_name(CommunityScreenComponents.COMMUNITY_COLUMN_VIEW.value)
        else:
            print("Unknown method to create a channel: ", method)

        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL_MENU_ITEM.value)

        wait_for_object_and_type(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value, communityChannelName)
        type(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_DESCRIPTION_INPUT.value, communityChannelDescription)

        click_obj_by_name(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_SAVE_OR_CREATE_BUTTON.value)

    def edit_community_channel(self, new_community_channel_name: str):
        self._open_edit_channel_popup()

        # Select all text in the input before typing
        wait_for_object_and_type(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value, "<Ctrl+a>")
        type(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value, new_community_channel_name)
        click_obj_by_name(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_SAVE_OR_CREATE_BUTTON.value)
        time.sleep(0.5)

    def create_community_category(self, community_category_name, community_channel_names, method):
        if (method == CommunityCreateMethods.BOTTOM_MENU.value):
            click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON.value)
        elif (method == CommunityCreateMethods.RIGHT_CLICK_MENU.value):
            right_click_obj_by_name(CommunityScreenComponents.COMMUNITY_COLUMN_VIEW.value)
        else:
            verify_failure("Unknown method to create a category: ", method)

        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CATEGORY_MENU_ITEM.value)

        wait_for_object_and_type(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_NAME_INPUT.value, community_category_name)
        self._toggle_channels_in_category_popop(community_channel_names)
        click_obj_by_name(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_BUTTON.value)

    def edit_community_category(self, community_category_name, new_community_category_name, community_channel_names):
        [loaded, category] = self._find_category_in_chat(community_category_name)
        verify(loaded, "Finding category: " + community_category_name)

        self._open_category_edit_popup(category)

        # Select all text in the input before typing
        wait_for_object_and_type(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_NAME_INPUT.value, "<Ctrl+a>")
        type(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_NAME_INPUT.value, new_community_category_name)
        self._toggle_channels_in_category_popop(community_channel_names)
        click_obj_by_name(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_BUTTON.value)

    def delete_community_category(self, community_category_name):
        [loaded, category] = self._find_category_in_chat(community_category_name)
        verify(loaded, "Finding category: " + community_category_name)

        # For some reason it clicks on a first channel in category instead of category
        click_obj(category.chatListCategory.statusChatListCategoryItem)
        right_click_obj(category.chatListCategory.statusChatListCategoryItem)

        click_obj_by_name(CommunityScreenComponents.COMMUNITY_DELETE_CATEGORY_MENU_ITEM.value)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CONFIRM_DELETE_CATEGORY_BUTTON.value)

    def verify_category_name_missing(self, community_category_name):
        [result, _] = self._find_category_in_chat(community_category_name)
        verify_false(result, "Category " + community_category_name + " still exist")

    def verify_category_contains_channels(self, community_category_name, community_channel_names):
        [loaded, category] = self._find_category_in_chat(community_category_name)
        verify(loaded, "Finding category: " + community_category_name)

        self._open_category_edit_popup(category)

        checked_channel_names = self._get_checked_channel_names_in_category_popup(community_channel_names[0])
        split = community_channel_names.split(", ")
        for channel_name in split:
            if channel_name in checked_channel_names:
                split.remove(channel_name)
            else:
                verify_failure("Channel " + channel_name + " should be checked in category " + community_category_name)
        comma = ", "
        verify(len(split) == 0, "Channel(s) " + comma.join(split) + " should not be checked in category " + community_category_name)

    def edit_community(self, new_community_name: str, new_community_description: str, new_community_color: str):
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_HEADER_BUTTON.value)
        click_obj_by_name(CommunitySettingsComponents.EDIT_COMMUNITY_BUTTON.value)

        # Select all text in the input before typing
        wait_for_object_and_type(CommunitySettingsComponents.EDIT_COMMUNITY_NAME_INPUT.value, "<Ctrl+a>")
        type(CommunitySettingsComponents.EDIT_COMMUNITY_NAME_INPUT.value, new_community_name)

        wait_for_object_and_type(CommunitySettingsComponents.EDIT_COMMUNITY_DESCRIPTION_INPUT.value, "<Ctrl+a>")
        type(CommunitySettingsComponents.EDIT_COMMUNITY_DESCRIPTION_INPUT.value, new_community_description)

        scroll_obj_by_name(CommunitySettingsComponents.EDIT_COMMUNITY_SCROLL_VIEW.value)
        time.sleep(1)
        scroll_obj_by_name(CommunitySettingsComponents.EDIT_COMMUNITY_SCROLL_VIEW.value)
        time.sleep(1)

        click_obj_by_name(CommunitySettingsComponents.EDIT_COMMUNITY_COLOR_PICKER_BUTTON.value)
        wait_for_object_and_type(CommunityColorPanelComponents.HEX_COLOR_INPUT.value, "<Ctrl+a>")
        type(CommunityColorPanelComponents.HEX_COLOR_INPUT.value, new_community_color)
        click_obj_by_name(CommunityColorPanelComponents.SAVE_COLOR_BUTTON.value)

        click_obj_by_name(CommunitySettingsComponents.SAVE_BUTTON.value)
        time.sleep(0.5)

        # Validation
        verify_text_matching(CommunitySettingsComponents.COMMUNITY_NAME_TEXT.value, new_community_name)
        verify_text_matching(CommunitySettingsComponents.COMMUNITY_DESCRIPTION_TEXT.value, new_community_description)
        obj = get_obj(CommunitySettingsComponents.COMMUNITY_LETTER_IDENTICON.value)
        expect_true(obj.color.name == new_community_color, "Community color was not changed correctly")

    def go_back_to_community(self):
        click_obj_by_name(CommunitySettingsComponents.BACK_TO_COMMUNITY_BUTTON.value)

    def delete_current_community_channel(self):
        click_obj_by_name(CommunityScreenComponents.CHAT_MORE_OPTIONS_BUTTON.value)
        click_obj_by_name(CommunityScreenComponents.DELETE_CHANNEL_MENU_ITEM.value)
        click_obj_by_name(CommunityScreenComponents.DELETE_CHANNEL_CONFIRMATION_DIALOG_DELETE_BUTTON.value)

    def check_channel_count(self, count_to_check: int):
        chatListObj = get_obj(CommunityScreenComponents.NOT_CATEGORIZED_CHAT_LIST.value)
        verify_equals(chatListObj.statusChatListItems.count, int(count_to_check))

    def search_and_change_community_channel_emoji(self, emoji_description: str):
        self._open_edit_channel_popup()

        click_obj_by_name(CreateOrEditCommunityChannelPopup.EMOJI_BUTTON.value)

        # Search emoji
        wait_for_object_and_type(CreateOrEditCommunityChannelPopup.EMOJI_SEARCH_TEXT_INPUT.value, emoji_description)
        # Click on the first found emoji button
        click_obj(wait_by_wildcards(CreateOrEditCommunityChannelPopup.EMOJI_POPUP_EMOJI_PLACEHOLDER.value, "%NAME%", "*"))
        # save changes
        click_obj_by_name(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_SAVE_OR_CREATE_BUTTON.value)

    def check_community_channel_emoji(self, emojiStr: str):
        obj = wait_and_get_obj(CommunityScreenComponents.CHAT_IDENTIFIER_CHANNEL_ICON.value)
        expect_true(str(obj.emojiIcon).find(emojiStr) >= 0, "Same emoji check")

    def _verify_image_sent(self, message_index: int):
        image_obj = get_obj(CommunityScreenComponents.CHAT_LOG.value).itemAtIndex(message_index)
        verify_values_equal(str(image_obj.messageContentType), str(MessageContentType.IMAGE.value), "The last message is not an image.")

    def send_test_image(self, fixtures_root: str, multiple_images: bool, message: str):
        chat_input = wait_and_get_obj(CommunityScreenComponents.CHAT_INPUT_ROOT.value)
        
        chat_input.selectImageString(fixtures_root + "images/ui-test-image0.jpg")
        
        if (multiple_images):
            #self._select_test_image(fixtures_root, 1)
            chat_input.selectImageString(fixtures_root + "images/ui-test-image1.jpg")
        
        if (message != ""):
            # Type the message in the input (focus should be on the chat input)
            native_type(message)
                
        # Send the image (and message if present)
        native_type("<Return>")
    
    def verify_sent_test_image(self, multiple_images: bool, has_message: bool):
        image_index = 1 if has_message else 0
        self._verify_image_sent(image_index)
        
        if (multiple_images):
            # Verify second image
            image_index = 2 if has_message else 1
            self._verify_image_sent(image_index)


    def _do_wait_for_pin_button(self, message_index: int):
        if (self._retry_number > 3):
            verify_failure("Cannot find the pin button after hovering the message")
        
        message_object_to_pin = wait_and_get_obj(CommunityScreenComponents.CHAT_LOG.value).itemAtIndex(int(message_index))
        move_mouse_over_object(message_object_to_pin)
        pin_visible, _ = is_loaded_visible_and_enabled(CommunityScreenComponents.TOGGLE_PIN_MESSAGE_BUTTON.value, 100)
        if not pin_visible:
            self._retry_number += 1
            self._do_wait_for_pin_button(message_index)
             
    def _wait_for_pin_button(self, message_index: int):
        self._retry_number = 0
        self._do_wait_for_pin_button(message_index)
        
    def toggle_pin_message_at_index(self, message_index: int):
        self._wait_for_pin_button(message_index)
        
        click_obj_by_name(CommunityScreenComponents.TOGGLE_PIN_MESSAGE_BUTTON.value)

    def check_pin_count(self, wanted_pin_count: int):
        pin_text_obj = wait_and_get_obj(CommunityScreenComponents.PIN_TEXT.value)
        verify_equals(str(pin_text_obj.text), str(wanted_pin_count))

    def invite_user_to_community(self, user_name: str, message: str):
        click_obj_by_name(CommunityScreenComponents.ADD_MEMBERS_BUTTON.value)
        
        contacts_list = wait_and_get_obj(CommunityScreenComponents.EXISTING_CONTACTS_LISTVIEW.value)
        
        contact_item = None
        found = False
        for index in range(contacts_list.count):
            contact_item = contacts_list.itemAtIndex(index)
            if (contact_item.userName.toLower() == user_name.lower()):
                found = True
                break
        
        if not found:
            verify_failure("Contact with name " + user_name + " not found in the Existing Contacts list")
            
        click_obj(contact_item)
        click_obj_by_name(CommunityScreenComponents.INVITE_POPUP_NEXT_BUTTON.value)
        time.sleep(0.5)
        type(CommunityScreenComponents.INVITE_POPUP_MESSAGE_INPUT.value, message)
        click_obj_by_name(CommunityScreenComponents.INVITE_POPUP_SEND_BUTTON.value)

    def _get_member_obj(self, member_name: str):
        members_list = wait_and_get_obj(CommunitySettingsComponents.MEMBERS_TAB_MEMBERS_LISTVIEW.value)
        for index in range(members_list.count):
            member_item = members_list.itemAtIndex(index)
            if (member_item.userName.toLower() == member_name.lower()):
                return member_item
        return None

    def kick_member_from_community(self, member_name: str):
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_HEADER_BUTTON.value)
        click_obj_by_name(CommunitySettingsComponents.MEMBERS_BUTTON.value)
        
        member_item = self._get_member_obj(member_name)

        if member_item == None:
            verify_failure("Member with name " + member_name + " not found in the community member list")
            
        hover_obj(member_item)
        click_obj_by_name(CommunitySettingsComponents.MEMBER_KICK_BUTTON.value)
        click_obj_by_name(CommunitySettingsComponents.MEMBER_CONFIRM_KICK_BUTTON.value)
        
        time.sleep(1)
        verification_member_item = self._get_member_obj(member_name)
        verify_equal(verification_member_item, None, "Member with name " + member_name + " is still found in the community member list after being kicked")

    def verify_number_of_members(self, amount: int):
        header = get_obj(CommunityScreenComponents.COMMUNITY_HEADER_BUTTON.value)
        verify_values_equal(str(header.nbMembers), str(amount), "Number of members is not correct")
        
    