# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    StatusCommunityScreen.py
# *
# * \date    July 2022
# * \brief   Community Screen.
# *****************************************************************************/
import typing
from enum import Enum
import time
from unittest import TestSuite

from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from drivers.SDKeyboardCommands import *
from .StatusMainScreen import StatusMainScreen
from utils.FileManager import *
from screens.StatusChatScreen import MessageContentType
from screens.components.community_back_up_private_key_popup import BackUpCommunityPrivateKeyPopup
from utils.ObjectAccess import *

class CommunityCreateMethods(Enum):
    BOTTOM_MENU = "bottom_menu"
    RIGHT_CLICK_MENU = "right_click_menu"

class CommunityScreenComponents(Enum):
    CHAT_LOG = "chatView_log"  
    COMMUNITY_HEADER_BUTTON = "mainWindow_communityHeader_StatusChatInfoButton"
    COMMUNITY_HEADER_NAME_TEXT= "community_ChatInfo_Name_Text"
    COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON = "mainWindow_createChannelOrCategoryBtn_StatusBaseText"
    COMMUNITY_CREATE_CHANNEL_MENU_ITEM = "create_channel_StatusMenuItem"
    COMMUNITY_CREATE_CATEGORY_MENU_ITEM = "create_category_StatusMenuItem"
    COMMUNITY_EDIT_CATEGORY_MENU_ITEM = "edit_сategory_StatusMenuItem"
    COMMUNITY_DELETE_CATEGORY_MENU_ITEM = "delete_сategory_StatusMenuItem"
    COMMUNITY_CONFIRM_DELETE_CATEGORY_BUTTON = "confirmDeleteCategoryButton_StatusButton"
    CHAT_IDENTIFIER_CHANNEL_ICON = "mainWindow_chatInfoBtnInHeader_StatusChatInfoButton"
    CHAT_MORE_OPTIONS_BUTTON = "chat_moreOptions_menuButton"
    EDIT_CHANNEL_MENU_ITEM = "edit_Channel_StatusMenuItem"
    COMMUNITY_COLUMN_VIEW = "mainWindow_communityColumnView_CommunityColumnView"
    DELETE_CHANNEL_MENU_ITEM = "delete_Channel_StatusMenuItem"
    DELETE_CHANNEL_CONFIRMATION_DIALOG_DELETE_BUTTON = "delete_Channel_ConfirmationDialog_DeleteButton"
    NOT_CATEGORIZED_CHAT_LIST = "mainWindow_communityColumnView_statusChatList"
    CHAT_INPUT_ROOT = "chatInput_Root"
    TOGGLE_PIN_MESSAGE_BUTTON = "chatView_TogglePinMessageButton"
    REPLY_TO_MESSAGE_BUTTON = "chatView_ReplyToMessageButton"
    CHAT_LIST = "chatList_ListView"
    MARK_AS_READ_BUTTON = "mark_as_Read_StatusMenuItem"
    
    PIN_TEXT = "chatInfoButton_Pin_Text"
    WELCOME_ADD_MEMBERS_BUTTON = "community_AddMembers_Button"
    WELCOME_MANAGE_COMMUNITY = "community_ManageCommunity_Button"
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
    OVERVIEW_BUTTON = "communitySettingsView_NavigationListItem_Overview"
    MEMBERS_BUTTON = "communitySettings_Members_NavigationListItem"
    PERMISSIONS_BUTTON = "communitySettings_Permissions_NavigationListItem" 
    MINT_TOKENS_BUTTON = "communitySettingsView_NavigationListItem_Mint_Tokens"
    AIRDROPS_BUTTON = "communitySettingsView_NavigationListItem_Airdrops"   
    MEMBERS_TAB_MEMBERS_LISTVIEW = "communitySettings_MembersTab_Members_ListView"
    MEMBER_KICK_BUTTON = "communitySettings_MembersTab_Member_Kick_Button"
    MEMBER_CONFIRM_KICK_BUTTON = "communitySettings_KickModal_Kick_Button"

class CommunityWelcomeScreenComponents(Enum):
    # Constants definitions:
    PERMISSIONS_OPTION = "Permissions"
    TOKENS_OPTION = "Tokens"
    AIRDROPS_OPTION = "Airdrops"
    WELCOME_SCREEN_TITLE_OPTION_AIRDROPS = "Airdrop community tokens"
    WELCOME_SCREEN_TITLE_OPTION_PERMISSIONS = "Permissions"
    WELCOME_SCREEN_TITLE_OPTION_TOKENS = "Community tokens"
    # Components
    WELCOME_SCREEN_IMAGE = "community_welcome_screen_image"
    WELCOME_SCREEN_TITLE = "community_welcome_screen_title"
    WELCOME_SCREEN_SUBTITLE = "community_welcome_screen_subtitle"
    WELCOME_SCREEN_CHECKLIST_ELEMENT1 = "community_welcome_screen_checkList_element1"
    WELCOME_SCREEN_CHECKLIST_ELEMENT2 = "community_welcome_screen_checkList_element2"
    WELCOME_SCREEN_CHECKLIST_ELEMENT3 = "community_welcome_screen_checkList_element3"
    ADD_NEW_ITEM_BUTTON = "community_welcome_screen_add_new_item"  

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
    MODAL_CLOSE_BUTTON = "modal_Close_Button"      

class StatusCommunityScreen:

    def __init__(self):
        self._retry_number = 0
        verify_screen(CommunityScreenComponents.COMMUNITY_HEADER_BUTTON.value)

    def _find_channel_in_category_popup(self, community_channel_name: str):
        listView = get_obj(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_LIST.value)

        for index in range(listView.count):
            listItem = listView.itemAtIndex(index)
            name = listItem.objectName.toLower()
            if (listItem.item.objectName.toLower() == "category_item_name_" + community_channel_name.lower()):
                return True, listItem
        return False, None

    def _find_category_in_chat(self, community_category_name: str):
        chat_and_category_list = get_obj(CommunityScreenComponents.CHAT_LIST.value)
        for i in range(chat_and_category_list.count):
            chat_or_cat_loader = chat_and_category_list.itemAtIndex(i)
            if not chat_or_cat_loader or chat_or_cat_loader.item.objectName != "categoryItem":
                continue
            if str(chat_or_cat_loader.item.text).lower() == community_category_name.lower():
                return True, chat_or_cat_loader.item

        return False, None

    def _toggle_channels_in_category_popup(self, community_channel_names: str):
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
            listItemLoader = listView.itemAtIndex(index)
            if (listItemLoader.item.checked):
                result.append(listItemLoader.item.objectName.toLower())

        return result

    def _open_edit_channel_popup(self, attempt: int = 2):
        click_obj_by_name(CommunityScreenComponents.CHAT_MORE_OPTIONS_BUTTON.value)
        click_obj_by_name(CommunityScreenComponents.EDIT_CHANNEL_MENU_ITEM.value)
        try:
            TextEdit(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value).wait_until_appears()
        except:
            if attempt:
                self._open_edit_channel_popup(attempt-1)
            else:
                raise err

    def _open_category_edit_popup(self, category):
        # For some reason it clicks on a first channel in category instead of category
        click_obj(category)
        right_click_obj(category)
        sleep_test(0.1)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_EDIT_CATEGORY_MENU_ITEM.value)

    def verify_community_name(self, communityName: str):
        verify_text_matching(CommunityScreenComponents.COMMUNITY_HEADER_NAME_TEXT.value, communityName)   
        
    def verify_community_overview_name(self, communityName: str):
        verify_text_matching(CommunitySettingsComponents.COMMUNITY_NAME_TEXT.value, communityName)
    
    def verify_community_overview_description(self, communityDescription: str):
        verify_text_matching(CommunitySettingsComponents.COMMUNITY_DESCRIPTION_TEXT.value, communityDescription) 
        
    def create_community_channel(self, communityChannelName: str, communityChannelDescription: str, method: str):
        if (method == CommunityCreateMethods.BOTTOM_MENU.value):
            click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON.value)
        elif (method == CommunityCreateMethods.RIGHT_CLICK_MENU.value):
            right_click_obj_by_name(CommunityScreenComponents.COMMUNITY_COLUMN_VIEW.value)
        else:
            print("Unknown method to create a channel: ", method)
        # Without that sleep, the click sometimes lands next to the context menu, closing it and making the rest of the test fail
        # The sleep seems to help wait for the context menu to be loaded completely
        sleep_test(0.1)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL_MENU_ITEM.value)

        wait_for_object_and_type(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value, communityChannelName)
        type_text(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_DESCRIPTION_INPUT.value, communityChannelDescription)

        click_obj_by_name(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_SAVE_OR_CREATE_BUTTON.value)

    def edit_community_channel(self, new_community_channel_name: str):
        self._open_edit_channel_popup()

        # Select all text in the input before typing
        TextEdit(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value).text = new_community_channel_name
        click_obj_by_name(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_SAVE_OR_CREATE_BUTTON.value)
        time.sleep(0.5)

    def create_community_category(self, community_category_name, community_channel_names, method):
        if (method == CommunityCreateMethods.BOTTOM_MENU.value):
            click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON.value)
        elif (method == CommunityCreateMethods.RIGHT_CLICK_MENU.value):
            right_click_obj_by_name(CommunityScreenComponents.COMMUNITY_COLUMN_VIEW.value)
        else:
            verify_failure("Unknown method to create a category: ", method)

        # Without that sleep, the click sometimes lands next to the context menu, closing it and making the rest of the test fail
        # The sleep seems to help wait for the context menu to be loaded completely
        sleep_test(0.1)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CATEGORY_MENU_ITEM.value)

        wait_for_object_and_type(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_NAME_INPUT.value, community_category_name)
        self._toggle_channels_in_category_popup(community_channel_names)
        click_obj_by_name(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_BUTTON.value)

    def edit_community_category(self, community_category_name, new_community_category_name, community_channel_names):
        [loaded, category] = self._find_category_in_chat(community_category_name)
        verify(loaded, "Finding category: " + community_category_name)

        self._open_category_edit_popup(category)

        # Select all text in the input before typing
        wait_for_object_and_type(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_NAME_INPUT.value, "<Ctrl+a>")
        type_text(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_NAME_INPUT.value, new_community_category_name)
        self._toggle_channels_in_category_popup(community_channel_names)
        click_obj_by_name(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_BUTTON.value)

    def delete_community_category(self, community_category_name):
        [loaded, category] = self._find_category_in_chat(community_category_name)
        verify(loaded, "Finding category: " + community_category_name)

        # For some reason it clicks on a first channel in category instead of category
        click_obj(category)
        right_click_obj(category)

        click_obj_by_name(CommunityScreenComponents.COMMUNITY_DELETE_CATEGORY_MENU_ITEM.value)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CONFIRM_DELETE_CATEGORY_BUTTON.value)

    def verify_category_name_missing(self, community_category_name):
        # Make sure the event was propagated
        time.sleep(0.2)
        [result, _] = self._find_category_in_chat(community_category_name)
        verify_false(result, "Category " + community_category_name + " still exist")

    def verify_category_contains_channels(self, community_category_name, community_channel_names):
        [loaded, category] = self._find_category_in_chat(community_category_name)
        verify(loaded, "Finding category: " + community_category_name)

        self._open_category_edit_popup(category)

        community_channel_names_list = community_channel_names.split(", ")

        checked_channel_names = self._get_checked_channel_names_in_category_popup(community_channel_names_list[0])
        
        # Close popup before checking the lists as we want the state to be clean whether it's a success or failure
        click_obj_by_name(CreateOrEditCommunityCategoryPopup.MODAL_CLOSE_BUTTON.value)
        
        for community_channel_name in community_channel_names_list:
            if "category_item_name_" + community_channel_name in checked_channel_names:
                checked_channel_names.remove("category_item_name_" + community_channel_name)
            else:
                verify_failure("Channel " + community_channel_name + " should be checked in category " + community_category_name)
        comma = ", "
        verify(len(checked_channel_names) == 0, "Channel(s) " + comma.join(checked_channel_names) + " should not be checked in category " + community_category_name)
    
    def open_edit_community_by_community_header(self):
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_HEADER_BUTTON.value)
        verify(is_loaded_visible_and_enabled(CommunitySettingsComponents.EDIT_COMMUNITY_BUTTON.value), "Edit community button is visible and enabled")
        click_obj_by_name(CommunitySettingsComponents.EDIT_COMMUNITY_BUTTON.value)
        
    def change_community_name(self, new_community_name: str):
        # Select all text in the input before typing
        wait_for_object_and_type(CommunitySettingsComponents.EDIT_COMMUNITY_NAME_INPUT.value, "<Ctrl+a>")
        type_text(CommunitySettingsComponents.EDIT_COMMUNITY_NAME_INPUT.value, new_community_name)
        
    def change_community_description(self, new_community_description: str):
        wait_for_object_and_type(CommunitySettingsComponents.EDIT_COMMUNITY_DESCRIPTION_INPUT.value, "<Ctrl+a>")
        type_text(CommunitySettingsComponents.EDIT_COMMUNITY_DESCRIPTION_INPUT.value, new_community_description)

    def change_community_color(self, new_community_color: str):
        # TODO: fix scroll to the color component on Mac https://github.com/status-im/desktop-qa-automation/issues/57
        scroll_obj_by_name(CommunitySettingsComponents.EDIT_COMMUNITY_SCROLL_VIEW.value)
        scroll_obj_by_name(CommunitySettingsComponents.EDIT_COMMUNITY_SCROLL_VIEW.value)
        scroll_obj_by_name(CommunitySettingsComponents.EDIT_COMMUNITY_SCROLL_VIEW.value)

        click_obj_by_name(CommunitySettingsComponents.EDIT_COMMUNITY_COLOR_PICKER_BUTTON.value)
        wait_for_object_and_type(CommunityColorPanelComponents.HEX_COLOR_INPUT.value, "<Ctrl+a>")
        type_text(CommunityColorPanelComponents.HEX_COLOR_INPUT.value, new_community_color)
        click_obj_by_name(CommunityColorPanelComponents.SAVE_COLOR_BUTTON.value)
    
    def save_community_changes(self):
        click_obj_by_name(CommunitySettingsComponents.SAVE_BUTTON.value)
    
    def edit_community(self, new_community_name: str, new_community_description: str, new_community_color: str):
        self.open_edit_community_by_community_header()
        self.change_community_name(new_community_name)
        self.change_community_description(new_community_description)
        self.change_community_color(new_community_color)
        self.save_community_changes()

    def go_back_to_community(self):
        click_obj_by_name(CommunitySettingsComponents.BACK_TO_COMMUNITY_BUTTON.value)

    def delete_current_community_channel(self, attempt: int = 2):
        try:
            BaseElement(CommunityScreenComponents.CHAT_MORE_OPTIONS_BUTTON.value).click()
            BaseElement(CommunityScreenComponents.DELETE_CHANNEL_MENU_ITEM.value).click()
            BaseElement(CommunityScreenComponents.DELETE_CHANNEL_CONFIRMATION_DIALOG_DELETE_BUTTON.value).click()
        except:
            if attempt:
                delete_current_community_channel(attempt-1)
            else:
                raise

    def check_channel_count(self, count_to_check: int):
        chatListObj = get_obj(CommunityScreenComponents.NOT_CATEGORIZED_CHAT_LIST.value)
        verify_equals(chatListObj.statusChatListItems.count, int(count_to_check))

    def check_channel_is_uncategorized(self, channel_name: str):
        chatListObj = get_obj(CommunityScreenComponents.NOT_CATEGORIZED_CHAT_LIST.value)
        for i in range(chatListObj.statusChatListItems.count):
            channelObj = chatListObj.statusChatListItems.itemAtIndex(i)
            if channelObj.objectName == channel_name:
                return
        verify_failure("No channel matches " + channel_name)

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

    def _do_wait_for_msg_action_button(self, message_index: int, btn_name: str):
        if (self._retry_number > 3):
            verify_failure("Cannot find the action button after hovering the message")
        
        message_object_to_action = wait_and_get_obj(CommunityScreenComponents.CHAT_LOG.value).itemAtIndex(int(message_index))
        move_mouse_over_object(message_object_to_action)
        btn_visible, _ = is_loaded_visible_and_enabled(btn_name, 100)
        if not btn_visible:
            self._retry_number += 1
            self._do_wait_for_msg_action_button(message_index, btn_name)
             
    def _wait_for_msg_action_button(self, message_index: int, btn_name: str):
        self._retry_number = 0
        self._do_wait_for_msg_action_button(message_index, btn_name)
    
    def _click_msg_action_button(self, message_index: int, btn_name: str):
        self._wait_for_msg_action_button(message_index, btn_name)
        click_obj_by_name(btn_name)
            
    def toggle_pin_message_at_index(self, message_index: int):
        self._click_msg_action_button(message_index, CommunityScreenComponents.TOGGLE_PIN_MESSAGE_BUTTON.value)

    def check_pin_count(self, wanted_pin_count: int):
        pin_text_obj = wait_and_get_obj(CommunityScreenComponents.PIN_TEXT.value)
        verify_equals(str(pin_text_obj.text), str(wanted_pin_count))

    def invite_user_to_community(self, user_name: str, message: str):
        click_obj_by_name(CommunityScreenComponents.WELCOME_ADD_MEMBERS_BUTTON.value)
        
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
        type_text(CommunityScreenComponents.INVITE_POPUP_MESSAGE_INPUT.value, message)
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
        
    def toggle_reply_message_at_index(self, message_index: int):
        self._click_msg_action_button(message_index, CommunityScreenComponents.REPLY_TO_MESSAGE_BUTTON.value)
        
    def mark_as_read(self, chatName: str):
        chat_lists = get_obj(CommunityScreenComponents.CHAT_LIST.value)
        found = False
        verify(chat_lists.count > 0, "At least one chat exists")
        for i in range(chat_lists.count):
            draggable_item = chat_lists.itemAtIndex(i)
            chat = draggable_item.item
            if chat != None:
                if draggable_item.objectName == chatName:
                    right_click_obj(draggable_item)
                    found = True
                    break

        if not found:
            test.fail("Chat is not loaded")
        
        click_obj_by_name(CommunityScreenComponents.MARK_AS_READ_BUTTON.value)
        
    def click_sidebar_option(self, community_sidebar_option:str):
        #TODO Make compatible with other sidebar options
        if community_sidebar_option == "Manage Community":
            click_obj_by_name(CommunityScreenComponents.WELCOME_MANAGE_COMMUNITY.value)    
            
    def verify_option_exists(self, list:list):
        options_list = []
        options_list.append(get_obj(CommunitySettingsComponents.OVERVIEW_BUTTON.value).title)
        options_list.append(get_obj(CommunitySettingsComponents.MEMBERS_BUTTON.value).title)
        options_list.append(get_obj(CommunitySettingsComponents.PERMISSIONS_BUTTON.value).title)
        options_list.append(get_obj(CommunitySettingsComponents.MINT_TOKENS_BUTTON.value).title)
        options_list.append(get_obj(CommunitySettingsComponents.AIRDROPS_BUTTON.value).title)
        
        # Check if the lists are of equal length
        if len(options_list) != len(list):
            return False
        
        # Check if the lists have the same elements in the same order
        for i in range(len(options_list)):
            if options_list[i] != list[i]:
                return False
                         
              
    def select_community_settings_option(self, option:str):
        if option==CommunityWelcomeScreenComponents.PERMISSIONS_OPTION.value:
            click_obj_by_name(CommunitySettingsComponents.PERMISSIONS_BUTTON.value)
        elif option==CommunityWelcomeScreenComponents.TOKENS_OPTION.value:
            click_obj_by_name(CommunitySettingsComponents.MINT_TOKENS_BUTTON.value)
        elif option==CommunityWelcomeScreenComponents.AIRDROPS_OPTION.value:
            click_obj_by_name(CommunitySettingsComponents.AIRDROPS_BUTTON.value)    
             
    def verify_welcome_image(self, option:str):
        path = get_obj(CommunityWelcomeScreenComponents.WELCOME_SCREEN_IMAGE.value).source.path       
        if option==CommunityWelcomeScreenComponents.PERMISSIONS_OPTION.value:         
            verify_text_contains(str(path), "permissions2_3")
        elif option==CommunityWelcomeScreenComponents.TOKENS_OPTION.value:
            verify_text_contains(str(path), "mint2_1")
        elif option==CommunityWelcomeScreenComponents.AIRDROPS_OPTION.value:
            verify_text_contains(str(path), "airdrops8_1")    
    
    def verify_welcome_title(self, option:str):
        title = get_obj(CommunityWelcomeScreenComponents.WELCOME_SCREEN_TITLE.value).text
        if option==CommunityWelcomeScreenComponents.PERMISSIONS_OPTION.value:
            verify_equals(title, CommunityWelcomeScreenComponents.WELCOME_SCREEN_TITLE_OPTION_PERMISSIONS.value)    
        elif option==CommunityWelcomeScreenComponents.TOKENS_OPTION.value:
            verify_equals(title, CommunityWelcomeScreenComponents.WELCOME_SCREEN_TITLE_OPTION_TOKENS.value)    
        elif option==CommunityWelcomeScreenComponents.AIRDROPS_OPTION.value:
            verify_equals(title, CommunityWelcomeScreenComponents.WELCOME_SCREEN_TITLE_OPTION_AIRDROPS.value)    
    
    def verify_welcome_subtitle(self, option:str):
        subtitle = get_obj(CommunityWelcomeScreenComponents.WELCOME_SCREEN_SUBTITLE.value).text
        if option==CommunityWelcomeScreenComponents.PERMISSIONS_OPTION.value:
            verify_equals(subtitle, "You can manage your community by creating and issuing membership and access permissions")
        elif option==CommunityWelcomeScreenComponents.TOKENS_OPTION.value:
            verify_equals(subtitle, "You can mint custom tokens and import tokens for your community")
        elif option==CommunityWelcomeScreenComponents.AIRDROPS_OPTION.value:
            verify_equals(subtitle, "You can mint custom tokens and collectibles for your community")            
        
    def verify_welcome_settings_checklist(self, option:str, list: list):
        checklist = []
        checklist.append(get_obj(CommunityWelcomeScreenComponents.WELCOME_SCREEN_CHECKLIST_ELEMENT1.value).text)
        checklist.append(get_obj(CommunityWelcomeScreenComponents.WELCOME_SCREEN_CHECKLIST_ELEMENT2.value).text)
        checklist.append(get_obj(CommunityWelcomeScreenComponents.WELCOME_SCREEN_CHECKLIST_ELEMENT3.value).text)
        
        # Check if the lists are of equal length
        if len(checklist) != len(list):
            return False
        
        # Check if the lists have the same elements in the same order
        for i in range(len(checklist)):
            if checklist[i] != list[i]:
                return False
            
    
    def verify_action_button_present(self, option:str, enabled: bool): 
        button = BaseElement(str(CommunityWelcomeScreenComponents.ADD_NEW_ITEM_BUTTON.value))
        if enabled:
            assert button.is_enabled
        else:
            assert button.is_disabled
        button_title = get_obj(CommunityWelcomeScreenComponents.ADD_NEW_ITEM_BUTTON.value).text
        verify_equals(option, str(button_title))

class PermissionsView(BaseElement):
    def __init__(self):
        super(PermissionsView, self).__init__('mainWindow_editPermissionView_EditPermissionView')
        self._add_new_permission_button = Button('community_welcome_screen_add_new_item')
        self._who_holds_checkbox = CheckBox('editPermissionView_whoHoldsSwitch_StatusSwitch')
        self._who_holds_asset_field = TextEdit('edit_TextEdit')
        self._who_holds_amount_field = TextEdit('inputValue_StyledTextField')
        self._asset_item = BaseElement('o_TokenItem')
        self._is_allowed_to_option_button = Button('CustomPermissionListItem')
        self._in_general_button = Button('communityItem_CommunityListItem')
        self._hide_permission_checkbox = CheckBox('editPermissionView_switchItem_StatusSwitch')
        self._create_permission_button = Button('editPermissionView_Create_permission_StatusButton')
        self._add_button = Button('add_StatusButton')
        self._who_holds_list_item = BaseElement('editPermissionView_Who_holds_StatusItemSelector')
        self._is_allowed_to_list_item = BaseElement('editPermissionView_Is_allowed_to_StatusFlowSelector')
        self._in_list_item = BaseElement('editPermissionView_In_StatusItemSelector')
        self._tag_item = BaseElement('o_StatusListItemTag')

    @property
    def tags(self) -> typing.List[str]:
        _tags = get_objects(self._tag_item.symbolic_name)
        return [str(getattr(tag, 'title', '')) for tag in _tags]

    def add_new_permission(self):
        self._add_new_permission_button.click()
        return PermissionsView().wait_until_appears()

    def set_who_holds_checkbox_state(self, state):
        if state == 'Off':
            self._who_holds_checkbox.set(False)

    def set_who_holds_asset_and_amount(self, asset: str, amount: str):
        if asset != 'No':
            self.open_who_holds_context_menu()
            self._who_holds_asset_field.clear().text = asset
            self._asset_item.click()
            self._who_holds_asset_field.wait_until_hidden()
            self._who_holds_amount_field.text = amount
            self._add_button.click()
            self._who_holds_amount_field.wait_until_hidden()

    def set_is_allowed_to(self, name):
        self.open_is_allowed_to_context_menu()
        self._is_allowed_to_option_button.object_name['objectName'] = name
        self._is_allowed_to_option_button.wait_until_appears().click()
        self._add_button.click()
        self._add_button.wait_until_hidden()

    def set_in_community(self, in_general):
        if in_general == '#general':
            self.open_in_context_menu()
            self._in_general_button.wait_until_appears().click()
            self._add_button.click()
            self._add_button.wait_until_hidden()

    def create_permission(self):
        self._create_permission_button.click()
        self._create_permission_button.wait_until_hidden()

    def open_who_holds_context_menu(self):
        for child in walk_children(self._who_holds_list_item.object):
            if getattr(child, 'id', '') == 'addItemButton':
                click_obj(child)
                return
        raise LookupError('Add button for who holds not found ')

    def open_is_allowed_to_context_menu(self):
        for child in walk_children(self._is_allowed_to_list_item.object):
            if getattr(child, 'id', '') == 'addItemButton':
                click_obj(child)
                return
        raise LookupError('Add button for allowed to not found ')

    def open_in_context_menu(self):
        for child in walk_children(self._in_list_item.object):
            if getattr(child, 'id', '') == 'addItemButton':
                click_obj(child)
                return
        raise LookupError('Add button for in not found ')
