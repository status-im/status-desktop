# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    SettingsScreen.py
# *
# * \date    June 2022
# * \brief   Home Screen.
# *****************************************************************************/


from enum import Enum
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


class MainScreenComponents(Enum):
    ADVANCED_OPTION = "advanced_StatusBaseText"


class AdvancedOptionScreen(Enum):
    ACTIVATE_OR_DEACTIVATE_WALLET = "o_StatusSettingsLineButton"
    I_UNDERSTAND_POP_UP = "i_understand_StatusBaseText"


class SettingsScreen:

    def __init__(self):
        verify_screen(MainScreenComponents.ADVANCED_OPTION.value)

    def activate_wallet(self):
        click_obj_by_name(MainScreenComponents.ADVANCED_OPTION.value)
        click_obj_by_name(AdvancedOptionScreen.ACTIVATE_OR_DEACTIVATE_WALLET.value)
        click_obj_by_name(AdvancedOptionScreen.I_UNDERSTAND_POP_UP.value)
