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
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *

class MainUi(Enum):
    MODULE_WARNING_BANNER = "moduleWarning_Banner"

class CommunityCreateMethods(Enum):
    BOTTOM_MENU = "bottom_menu"
    RIGHT_CLICK_MENU = "right_click_menu"
    
class CommunityScreenComponents(Enum):
    COMMUNITY_HEADER_BUTTON = "mainWindow_communityHeader_StatusChatInfoButton"
    COMMUNITY_HEADER_NAME_TEXT= "community_ChatInfo_Name_Text"
    COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON = "mainWindow_createChannelOrCategoryBtn_StatusBaseText"
    COMMUNITY_CREATE_CHANNEL__MENU_ITEM = "create_channel_StatusMenuItemDelegate"
    COMMUNITY_CREATE_CATEGORY__MENU_ITEM = "create_category_StatusMenuItemDelegate"
    CHAT_IDENTIFIER_CHANNEL_NAME = "msgDelegate_channelIdentifierNameText_StyledText"
    CHAT_MORE_OPTIONS_BUTTON = "chat_moreOptions_menuButton"
    EDIT_CHANNEL_MENU_ITEM = "edit_Channel_StatusMenuItemDelegate"
    COMMUNITY_COLUMN_VIEW = "mainWindow_communityColumnView_CommunityColumnView"

class CommunitySettingsComponents(Enum):
    EDIT_COMMUNITY_SCROLL_VIEW = "communitySettings_EditCommunity_ScrollView"
    EDIT_COMMUNITY_BUTTON = "communitySettings_EditCommunity_Button"
    EDIT_COMMUNITY_NAME_INPUT = "communitySettings_EditCommunity_Name_Input"
    EDIT_COMMUNITY_DESCRIPTION_INPUT = "communitySettings_EditCommunity_Description_Input"
    EDIT_COMMUNITY_COLOR_PICKER_BUTTON = "communitySettings_EditCommunity_ColorPicker_Button"
    SAVE_BUTTON = "communitySettings_Save_Button"
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
    COMMUNITY_CHANNEL_BUTTON: str = "createOrEditCommunityChannelBtn_StatusButton"

class StatusCommunityScreen:

    def __init__(self):
        verify_screen(CommunityScreenComponents.COMMUNITY_HEADER_BUTTON.value) 
        
    def verify_community_name(self, communityName: str):
        verify_text_matching(CommunityScreenComponents.COMMUNITY_HEADER_NAME_TEXT.value, communityName)
    
    def create_community_channel(self, communityChannelName: str, communityChannelDescription: str, method: str):
        if (method == CommunityCreateMethods.BOTTOM_MENU.value):
            click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON.value)
        elif (method == CommunityCreateMethods.RIGHT_CLICK_MENU.value):
            right_click_obj_by_name(CommunityScreenComponents.COMMUNITY_COLUMN_VIEW.value)
        else:
            print("Unknown method to create a channel: ", method)
        
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL__MENU_ITEM.value)
        
        wait_for_object_and_type(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value, communityChannelName)
        type(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_DESCRIPTION_INPUT.value, communityChannelDescription)
        click_obj_by_name(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_BUTTON.value)
        
    # TODO check if this function is needed, it seems to do the same as verify_chat_title in StatusChatScreen 
    def verify_channel_name(self, community_channel_name: str):
        verify_text_matching(CommunityScreenComponents.CHAT_IDENTIFIER_CHANNEL_NAME.value, community_channel_name)
        
    def edit_community_channel(self, new_community_channel_name: str):
        [bannerLoaded, _] = is_loaded_visible_and_enabled(MainUi.MODULE_WARNING_BANNER.value)
        if (bannerLoaded):
            time.sleep(5) # Wait for the banner to disappear otherwise the click might land badly

        click_obj_by_name(CommunityScreenComponents.CHAT_MORE_OPTIONS_BUTTON.value)
        click_obj_by_name(CommunityScreenComponents.EDIT_CHANNEL_MENU_ITEM.value)

        # Select all text in the input before typing
        wait_for_object_and_type(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value, "<Ctrl+a>")
        type(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value, new_community_channel_name)
        click_obj_by_name(CreateOrEditCommunityChannelPopup.COMMUNITY_CHANNEL_BUTTON.value)
        time.sleep(0.5)

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
        test.verify(obj.color.name == new_community_color, "Community color was not changed correctly")

    def go_back_to_community(self):
        click_obj_by_name(CommunitySettingsComponents.BACK_TO_COMMUNITY_BUTTON.value)
