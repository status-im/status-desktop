#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file    StatusAccount.py
# *
# * \date    February 2022
# * \brief   It defines a basic status account object.
# *****************************************************************************/

#It defines a basic status account object.

from typing import Optional

class StatusAccount():    
    __name = ""
    __password = None
    
    def __init__(self, name: str, password: Optional[str] = None):
        self.__name = name
        self.__password = password
        
    def get_name(self) -> str: 
        return self.__name
    
    def get_password(self) -> Optional[str]:
        return self.__password