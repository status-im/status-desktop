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

class CommunityCreateMethods(Enum):
    BOTTOM_MENU = "bottom_menu"
    RIGHT_CLICK_MENU = "right_click_menu"

class CommunityScreenComponents(Enum):
    COMMUNITY_HEADER_BUTTON = "mainWindow_communityHeader_StatusChatInfoButton"
    COMMUNITY_HEADER_NAME_TEXT= "community_ChatInfo_Name_Text"
    COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON = "mainWindow_createChannelOrCategoryBtn_StatusBaseText"
    COMMUNITY_CREATE_CHANNEL_MENU_ITEM = "create_channel_StatusMenuItemDelegate"
    COMMUNITY_CREATE_CATEGORY_MENU_ITEM = "create_category_StatusMenuItemDelegate"
    COMMUNITY_EDIT_CATEGORY_MENU_ITEM = "edit_сategory_StatusMenuItemDelegate"
    COMMUNITY_DELETE_CATEGORY_MENU_ITEM = "delete_сategory_StatusMenuItemDelegate"
    COMMUNITY_CONFIRM_DELETE_CATEGORY_BUTTON = "confirmDeleteCategoryButton_StatusButton"
    CHAT_IDENTIFIER_CHANNEL_NAME = "msgDelegate_channelIdentifierNameText_StyledText"
    CHAT_IDENTIFIER_CHANNEL_ICON = "mainWindow_chatInfoBtnInHeader_StatusChatInfoButton"
    CHAT_MORE_OPTIONS_BUTTON = "chat_moreOptions_menuButton"
    EDIT_CHANNEL_MENU_ITEM = "edit_Channel_StatusMenuItemDelegate"
    COMMUNITY_COLUMN_VIEW = "mainWindow_communityColumnView_CommunityColumnView"
    DELETE_CHANNEL_MENU_ITEM = "delete_Channel_StatusMenuItemDelegate"
    DELETE_CHANNEL_CONFIRMATION_DIALOG_DELETE_BUTTON = "delete_Channel_ConfirmationDialog_DeleteButton"
    NOT_CATEGORIZED_CHAT_LIST = "mainWindow_communityColumnView_statusChatList"
    COMMUNITY_CHAT_LIST_CATEGORIES = "communityChatListCategories_Repeater"

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

class CommunityColorPanelComponents(Enum):
    HEX_COLOR_INPUT = "communitySettings_ColorPanel_HexColor_Input"
    SAVE_COLOR_BUTTON = "communitySettings_SaveColor_Button"

class CreateOrEditCommunityChannelPopup(Enum):
    COMMUNITY_CHANNEL_NAME_INPUT: str = "createOrEditCommunityChannelNameInput_TextEdit"
    COMMUNITY_CHANNEL_DESCRIPTION_INPUT: str = "createOrEditCommunityChannelDescriptionInput_TextEdit"
    COMMUNITY_CHANNEL_SAVE_OR_CREATE_BUTTON: str = "createOrEditCommunityChannelBtn_StatusButton"
    EMOJI_BUTTON: str = "createOrEditCommunityChannel_EmojiButton"
    EMOJI_SEARCH_TEXT_INPUT: str = "statusDesktop_mainWindow_AppMain_EmojiPopup_SearchTextInput"
    EMOJI_POPUP_EMOJI_PLACEHOLDER = "emojiPopup_Emoji_Button_Placeholder"

class CreateOrEditCommunityCategoryPopup(Enum):
    COMMUNITY_CATEGORY_NAME_INPUT: str = "createOrEditCommunityCategoryNameInput_TextEdit"
    COMMUNITY_CATEGORY_LIST: str = "createOrEditCommunityCategoryChannelList_ListView"
    COMMUNITY_CATEGORY_BUTTON: str = "createOrEditCommunityCategoryBtn_StatusButton"

class StatusCommunityScreen:

    def __init__(self):
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
        # Wait for the channel list
        time.sleep(0.5)

        for channel_name in community_channel_names.split(", "):
            [loaded, channel] = self._find_channel_in_category_popup(channel_name)
            if loaded:
                click_obj(channel)
            else:
                verify_failure("Can't find channel " + channel_name)

    def open_edit_channel_popup(self):
        StatusMainScreen.wait_for_banner_to_disappear()

        click_obj_by_name(CommunityScreenComponents.CHAT_MORE_OPTIONS_BUTTON.value)
        click_obj_by_name(CommunityScreenComponents.EDIT_CHANNEL_MENU_ITEM.value)

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

    # TODO check if this function is needed, it seems to do the same as verify_chat_title in StatusChatScreen 
    def verify_channel_name(self, community_channel_name: str):
        verify_text_matching(CommunityScreenComponents.CHAT_IDENTIFIER_CHANNEL_NAME.value, community_channel_name)

    def edit_community_channel(self, new_community_channel_name: str):
        self.open_edit_channel_popup()

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
        verify(loaded, "Can't find category " + community_category_name)

        # For some reason it clicks on a first channel in category instead of category
        squish.mouseClick(category.parent, squish.Qt.RightButton)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_EDIT_CATEGORY_MENU_ITEM.value)

        # Select all text in the input before typing
        wait_for_object_and_type(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_NAME_INPUT.value, "<Ctrl+a>")
        type(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_NAME_INPUT.value, new_community_category_name)
        self._toggle_channels_in_category_popop(community_channel_names)
        click_obj_by_name(CreateOrEditCommunityCategoryPopup.COMMUNITY_CATEGORY_BUTTON.value)

    def delete_community_category(self, community_category_name):
        [loaded, category] = self._find_category_in_chat(community_category_name)
        verify(loaded, "Can't find category " + community_category_name)

        # For some reason it clicks on a first channel in category instead of category
        squish.mouseClick(category.parent, squish.Qt.RightButton)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_DELETE_CATEGORY_MENU_ITEM.value)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CONFIRM_DELETE_CATEGORY_BUTTON.value)

    def verify_category_name(self, community_category_name):
        [result, _] = self._find_category_in_chat(community_category_name)
        verify(result, "Can't find category " + community_category_name)

    def verify_category_name_missing(self, community_category_name):
        [result, _] = self._find_category_in_chat(community_category_name)
        verify_false(result, "Category " + community_category_name + " still exist")

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
        expectTrue(obj.color.name == new_community_color, "Community color was not changed correctly")

    def go_back_to_community(self):
        click_obj_by_name(CommunitySettingsComponents.BACK_TO_COMMUNITY_BUTTON.value)

    def delete_current_community_channel(self):
        StatusMainScreen.wait_for_banner_to_disappear()

        click_obj_by_name(CommunityScreenComponents.CHAT_MORE_OPTIONS_BUTTON.value)
        click_obj_by_name(CommunityScreenComponents.DELETE_CHANNEL_MENU_ITEM.value)
        click_obj_by_name(CommunityScreenComponents.DELETE_CHANNEL_CONFIRMATION_DIALOG_DELETE_BUTTON.value)

    def check_channel_count(self, count_to_check: int):
        chatListObj = get_obj(CommunityScreenComponents.NOT_CATEGORIZED_CHAT_LIST.value)
        # Squish doesn't follow the type hints when parsing gherkin values
        verify_equals(chatListObj.statusChatListItems.count, int(count_to_check))

    def search_and_change_community_channel_emoji(self, emoji_description: str):
        self.open_edit_channel_popup()

        click_obj_by_name(CreateOrEditCommunityChannelPopup.EMOJI_BUTTON.value)

        # Search emoji
        wait_for_object_and_type(CreateOrEditCommunityChannelPopup.EMOJI_SEARCH_TEXT_INPUT.value, emoji_description)
        # Click on the first found emoji button
        click_obj_by_wildcards_name(CreateOrEditCommunityChannelPopup.EMOJI_POPUP_EMOJI_PLACEHOLDER.value, "statusEmoji_*")
        # save changes
        click_obj_by_name(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_SAVE_OR_CREATE_BUTTON.value)

    def check_community_channel_emoji(self, emojiStr: str):
        obj = wait_and_get_obj(CommunityScreenComponents.CHAT_IDENTIFIER_CHANNEL_ICON.value)
        expectTrue(str(obj.icon.emoji).find(emojiStr) >= 0, "Same emoji check")