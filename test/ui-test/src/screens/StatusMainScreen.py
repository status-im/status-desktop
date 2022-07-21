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
    PUBLIC_CHAT_ICON = "mainWindow_public_chat_icon_StatusIcon"
    COMMUNITY_PORTAL_ICON = "communities_Portal_navbar_communities_icon_StatusIcon"
    JOIN_PUBLIC_CHAT = "join_public_chat_StatusMenuItemDelegate"
    SETTINGS_BUTTON = "settings_navbar_settings_icon_StatusIcon"
    WALLET_BUTTON = "wallet_navbar_wallet_icon_StatusIcon"
    START_CHAT_BTN = "mainWindow_startChat"
    CHAT_LIST = "chatList_Repeater"
    MARK_AS_READ_BUTTON = "mark_as_Read_StatusMenuItemDelegate"

class ChatNamePopUp(Enum):
    CHAT_NAME_TEXT = "chat_name_PlaceholderText"
    INPUT_ROOM_TOPIC_TEXT = "joinPublicChat_input"
    START_CHAT_BTN = "startChat_Btn"


class StatusMainScreen:

    def __init__(self):
        verify_screen(MainScreenComponents.PUBLIC_CHAT_ICON.value)

    def join_chat_room(self, room: str):
        click_obj_by_name(MainScreenComponents.PUBLIC_CHAT_ICON.value)
        #click_obj_by_name(MainScreenComponents.JOIN_PUBLIC_CHAT.value)
        type(ChatNamePopUp.INPUT_ROOM_TOPIC_TEXT.value, room)
        click_obj_by_name(ChatNamePopUp.START_CHAT_BTN.value)
        
    def open_community_portal(self):
        click_obj_by_name(MainScreenComponents.COMMUNITY_PORTAL_ICON.value)
    
    def open_settings(self):
        click_obj_by_name(MainScreenComponents.SETTINGS_BUTTON.value)
        
    def open_start_chat_view(self):
        click_obj_by_name(MainScreenComponents.START_CHAT_BTN.value)
        
    def open_chat(self, chatName: str):
        [loaded, chat_button] = self._find_chat(chatName)
        if loaded:
            click_obj(chat_button)
        verify(loaded, "Trying to get chat: " + chatName)
        
    def _find_chat(self, chatName: str):
        [loaded, chat_lists] = is_loaded(MainScreenComponents.CHAT_LIST.value)
        if loaded:
            for index in range(chat_lists.count):
                chat = chat_lists.itemAt(index)
                if(chat.objectName == chatName):
                    return True, chat        
        return False, None

    def mark_as_read(self, chatName: str):
        [loaded, chat_button] = self._find_chat(chatName)
        if loaded:
            right_click_obj(chat_button)
        
        click_obj_by_name(MainScreenComponents.MARK_AS_READ_BUTTON.value)

    def open_wallet(self):
        click_obj_by_name(MainScreenComponents.WALLET_BUTTON.value)
