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
class StatusAccount():    
    __name = None
    __password = None
    
    def __init__(self, name, password = None):
        self.__name = name
        self.__password = password
        
    def get_name(self): 
        return self.__name
    
    def get_password(self):
        return self.__password