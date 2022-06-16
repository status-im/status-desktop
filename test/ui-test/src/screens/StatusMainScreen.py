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
    STATUS_ICON = "mainWindow_statusIcon_StatusIcon_2"
    PUBLIC_CHAT_ICON = "mainWindow_dropRectangle_Rectangle"
    JOIN_PUBLIC_CHAT = "join_public_chat_StatusMenuItemDelegate"


class ChatNamePopUp(Enum):
    CHAT_NAME_TEXT = "chat_name_PlaceholderText"
    INPUT_ROOM_TOPIC_TEXT = "inputValue_StyledTextField"
    START_CHAT = "start_chat_StatusBaseText"


class StatusMainScreen:

    def __init__(self):
        verify_screen(MainScreenComponents.STATUS_ICON.value)

    def joinChatRoom(self, room):
        click_obj_by_name(MainScreenComponents.STATUS_ICON.value)
        click_obj_by_name(MainScreenComponents.JOIN_PUBLIC_CHAT.value)
        type(ChatNamePopUp.INPUT_ROOM_TOPIC_TEXT.value, room)
        click_obj_by_name(ChatNamePopUp.START_CHAT.value)
