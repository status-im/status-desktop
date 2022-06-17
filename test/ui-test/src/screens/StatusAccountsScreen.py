#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file    AccountsPopup.py
# *
# * \date    February 2022
# * \brief   It defines the status accounts popup behavior and properties.
# *****************************************************************************/

from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *

# It defines the identifier for each Account View component:
class SAccountsComponents(Enum):
    ACCOUNTS_POPUP                = "accountsView_accountListPanel"

#It defines the status accounts popup behavior and properties.
class StatusAccountsScreen():

    
    def __init__(self):
        verify_screen(SAccountsComponents.ACCOUNTS_POPUP.value)

    def find_account(self, account):
        [found, account_obj] = self.__find_account(account)
        return found
    
    def select_account(self, account):
        [found, account_obj] = self.__find_account(account)
        if found:
            return click_obj(account_obj)       
        return found
    
    def __find_account(self, account):
        found = False
        account_obj = None
        __is_loaded = False
        __accountsList = None
        [__is_loaded, __accountsList] = is_loaded_visible_and_enabled(SAccountsComponents.ACCOUNTS_POPUP.value)
        for index in range(__accountsList.count):
            a = __accountsList.itemAtIndex(index)
            if(a.username == account):
                account_obj = a
                found = True
                break        
        return found, account_obj