# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    StatusMainScreen.py
# *
# * \date    June 2022
# * \brief   Home Screen.
# *****************************************************************************/


from enum import Enum
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


class MainScreenComponents(Enum):
    PUBLIC_CHAT_ICON = "mainWindow_public_chat_icon_StatusIcon"
    SETTINGS_BUTTON = "settings_navbar_settings_icon_StatusIcon"


class ChatNamePopUp(Enum):
    INPUT_ROOM_TOPIC_TEXT = "inputValue_StyledTextField"
    START_CHAT = "start_chat_StatusBaseText"


class StatusMainScreen:

    def __init__(self):
        verify_screen(MainScreenComponents.PUBLIC_CHAT_ICON.value)

    def joinChatRoom(self, room: str):
        click_obj_by_name(MainScreenComponents.PUBLIC_CHAT_ICON.value)
        type(ChatNamePopUp.INPUT_ROOM_TOPIC_TEXT.value, room)
        click_obj_by_name(ChatNamePopUp.START_CHAT.value)
        
    
    
    def open_settings(self):
        click_obj_by_name(MainScreenComponents.SETTINGS_BUTTON.value)

