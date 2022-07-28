# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    StatusChatScreen.py
# *
# * \date    June 2022
# * \brief   Chat Screen.
# *****************************************************************************/


from enum import Enum
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from drivers.SDKeyboardCommands import *


class ChatComponents(Enum):
    MESSAGE_INPUT = "chatView_messageInput"       
    TOOLBAR_INFO_BUTTON = "chatView_StatusChatInfoButton"
    CHAT_LOG = "chatView_log"    
    LAST_MESSAGE_TEXT = "chatView_lastChatText_Text"
    MEMBERS_LISTVIEW = "chatView_chatMembers_ListView"
    REPLY_TO_MESSAGE_BUTTON = "chatView_replyToMessageButton"

class ChatMessagesHistory(Enum):
    CHAT_CREATED_TEXT = 1
    HAS_ADDED_TEXT = 0

class StatusChatScreen:

    def __init__(self):
        verify_screen(ChatComponents.MESSAGE_INPUT.value)
        verify_screen(ChatComponents.TOOLBAR_INFO_BUTTON.value)

    # Screen actions region:
    def send_message(self, message: str):
        type(ChatComponents.MESSAGE_INPUT.value, message)
        press_enter(ChatComponents.MESSAGE_INPUT.value)
        
    # Verifications region:        
    def verify_last_message_sent(self, message: str):
        [loaded, last_message_obj] = is_loaded_visible_and_enabled(ChatComponents.LAST_MESSAGE_TEXT.value)
        verify(loaded, "Checking last message sent: " + message)
        verify_text_contains(str(last_message_obj.text), str(message))
        
    def verify_chat_title(self, title: str):
        info_btn = get_obj(ChatComponents.TOOLBAR_INFO_BUTTON.value)
        verify_text(str(info_btn.title), title)
        
    def verify_members_added(self, members):
        self.verify_total_members_is_displayed_in_toolbar(members)
        self.verify_added_members_message_is_displayed_in_history( members)
        self.verify_members_are_in_list_panel(members)                  

    def verify_members_are_in_list_panel(self, members):
        for row in members[0:]:
            verify(self.find_member_in_panel(row[0]), "Looking for member: " + row[0])
            
    def verify_total_members_is_displayed_in_toolbar(self, members):
        total_members = len(members) + 1 # + Admin
        info_btn_subtitle = str(get_obj(ChatComponents.TOOLBAR_INFO_BUTTON.value).subTitle)
        subtitle_substrings = info_btn_subtitle.split(' ')
        verify(int(subtitle_substrings[0]) == total_members, "Expected members are " + str(total_members) + "and they are displayed " + subtitle_substrings[0])
    
    # NOTE: It is expecting a specific log order and will succeed only just after the chat is created and no messages have been sent.
    # TODO: Improvement --> Iterate through the complete history, check all messages and verify the `createdTxt` is displayed.   
    def verify_added_members_message_is_displayed_in_history(self, members):
        chat_membersAdded_text_obj = get_obj(ChatComponents.CHAT_LOG.value).itemAtIndex(ChatMessagesHistory.HAS_ADDED_TEXT.value)        
        for member in members[0:]:
            verify_text_contains(str(chat_membersAdded_text_obj.message), member[0])
            
    # NOTE: It is expecting a specific log order and will succeed only just after the chat is created and no messages have been sent.
    # TODO: Improvement --> Iterate through the complete history, check all messages and verify the `createdTxt` is displayed.
    def verify_chat_created_message_is_displayed_in_history(self, createdTxt: str):
        chat_createChat_text_obj = get_obj(ChatComponents.CHAT_LOG.value).itemAtIndex(ChatMessagesHistory.CHAT_CREATED_TEXT.value)        
        verify_text_contains(str(chat_createChat_text_obj.message), createdTxt)
        
    def reply_to_message_at_index(self, index: int, message: str):
        message_object_to_reply_to = get_obj(ChatComponents.CHAT_LOG.value).itemAtIndex(int(index))
        hover_obj(message_object_to_reply_to)
        click_obj_by_name(ChatComponents.REPLY_TO_MESSAGE_BUTTON.value)
        self.send_message(message)
    
    # TODO: Find ADMIN
    def find_member_in_panel(self, member: str):
        found = False
        [is_loaded, membersList] = is_loaded_visible_and_enabled(ChatComponents.MEMBERS_LISTVIEW.value)
        if is_loaded:
            for index in range(membersList.count):
                user = membersList.itemAtIndex(index)
                if(user.userName == member):
                    found = True
                    break        
        return found