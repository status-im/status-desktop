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
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *

class CommunityScreenComponents(Enum):
    COMMUNITY_HEADER_BUTTON = "mainWindow_communityHeader_StatusChatInfoButton"
    COMMUNITY_HEADER_NAME_TEXT= "community_ChatInfo_Name_Text"
    COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON = "mainWindow_createChannelOrCategoryBtn_StatusBaseText"
    COMMUNITY_CREATE_CHANNEL__MENU_ITEM = "create_channel_StatusMenuItemDelegate"
    COMMUNITY_CREATE_CATEGORY__MENU_ITEM = "create_category_StatusMenuItemDelegate"
    CHAT_IDENTIFIER_CHANNEL_NAME = "msgDelegate_channelIdentifierNameText_StyledText"

class CreateCommunityChannelPopup(Enum):
    COMMUNITY_CHANNEL_NAME_INPUT: str = "createCommunityChannelNameInput_TextEdit"
    COMMUNITY_CHANNEL_DESCRIPTION_INPUT: str = "createCommunityChannelDescriptionInput_TextEdit"
    COMMUNITY_CHANNEL_BUTTON: str = "createCommunityChannelBtn_StatusButton"

class StatusCommunityScreen:

    def __init__(self):
        verify_screen(CommunityScreenComponents.COMMUNITY_HEADER_BUTTON.value) 
        
    def verify_community_name(self, communityName: str):
        verify_text_matching(CommunityScreenComponents.COMMUNITY_HEADER_NAME_TEXT.value, communityName)
    
    def create_community_channel(self, communityChannelName: str, communityChannelDescription: str):
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL_OR_CAT_BUTTON.value)
        click_obj_by_name(CommunityScreenComponents.COMMUNITY_CREATE_CHANNEL__MENU_ITEM.value)
        
        type(CreateCommunityChannelPopup.COMMUNITY_CHANNEL_NAME_INPUT.value, communityChannelName)
        type(CreateCommunityChannelPopup.COMMUNITY_CHANNEL_DESCRIPTION_INPUT.value, communityChannelDescription)
        click_obj_by_name(CreateCommunityChannelPopup.COMMUNITY_CHANNEL_BUTTON.value)
        
    def verify_channel_name(self, communityChannelName: str):
        verify_text_matching(CommunityScreenComponents.CHAT_IDENTIFIER_CHANNEL_NAME.value, communityChannelName)
        
        