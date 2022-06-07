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


class ChatComponents(Enum):
    TYPE_A_MESSAGE_PLACE_HOLDER = "scrollView_Type_a_message_PlaceholderText"
    MESSAGE_INPUT = "scrollView_messageInputField_TextArea"


class StatusChatScreen:

    def __init__(self):
        verify_screen_is_loaded(ChatComponents.TYPE_A_MESSAGE_PLACE_HOLDER.value)

    def sendMessage(self, message):
        type(ChatComponents.MESSAGE_INPUT.value, message)
        press_enter(ChatComponents.MESSAGE_INPUT.value)
