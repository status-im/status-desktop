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
from .StatusMainScreen import MainScreenComponents

class SidebarComponents(Enum):
    ADVANCED_OPTION: str = "advanced_StatusBaseText"
    WALLET_ITEM: str = "wallet_AppMenu_StatusNavigationListItem"


class AdvancedOptionScreen(Enum):
    ACTIVATE_OR_DEACTIVATE_WALLET: str = "walletSettingsLineButton"
    I_UNDERSTAND_POP_UP: str = "i_understand_StatusBaseText"
    

class WalletSettingsScreen(Enum):
    TWELVE_SEED_PHRASE: str = "twelve_seed_phrase_address"
    EIGHTEEN_SEED_PHRASE: str = "eighteen_seed_phrase_address"
    TWENTY_FOUR_SEED_PHRASE: str = "twenty_four_seed_phrase_address"


class SettingsScreen:

    def __init__(self):
        verify_screen(SidebarComponents.ADVANCED_OPTION.value)

    def activate_open_wallet_settings(self):
        if not (is_Visible(SidebarComponents.WALLET_ITEM.value)) :
            click_obj_by_name(SidebarComponents.ADVANCED_OPTION.value)
            click_obj_by_name(AdvancedOptionScreen.ACTIVATE_OR_DEACTIVATE_WALLET.value)
            click_obj_by_name(AdvancedOptionScreen.I_UNDERSTAND_POP_UP.value)
            verify_object_enabled(SidebarComponents.WALLET_ITEM.value)
           
        click_obj_by_name(SidebarComponents.WALLET_ITEM.value)

    def activate_open_wallet_section(self):
        if not (is_Visible(SidebarComponents.WALLET_ITEM.value)):
            click_obj_by_name(SidebarComponents.ADVANCED_OPTION.value)
            click_obj_by_name(AdvancedOptionScreen.ACTIVATE_OR_DEACTIVATE_WALLET.value)
            click_obj_by_name(AdvancedOptionScreen.I_UNDERSTAND_POP_UP.value)
            verify_object_enabled(SidebarComponents.WALLET_ITEM.value)
           
        click_obj_by_name(MainScreenComponents.WALLET_BUTTON.value)
     
    def verify_address(self, phrase: str, address: str):
        if phrase =='18':
            verify_text_matching(WalletSettingsScreen.EIGHTEEN_SEED_PHRASE.value, address)
        
        if phrase == '24':
            verify_text_matching(WalletSettingsScreen.TWENTY_FOUR_SEED_PHRASE.value, address)
            
        if phrase == '12':
            verify_text_matching(WalletSettingsScreen.TWELVE_SEED_PHRASE.value, address)
              
        
