from enum import Enum
import time
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from drivers.SDKeyboardCommands import *


class CreateChatComponents(Enum):
    #MAIN_VIEW = "createChatView_view"
    CONTACTS_LIST = "createChatView_contactsList"
    CONFIRM_BTN = "createChatView_confirmBtn"

class StatusCreateChatScreen:

    def select_user(self, name):
        [found, user_obj] = self.__find_user(name)
        if found:
            return click_obj(user_obj)       
        return verify(found, "User not found: " + name)
        
    def create_chat(self, members):        
        # Select members:
        for member in members[0:]:
            time.sleep(0.2) # It is important bc the list changes its content after selecting a user so, it needs a while to be updated
            self.select_user(member[0])

        # Confirm creation:
        click_obj_by_name(CreateChatComponents.CONFIRM_BTN.value)
        
    def __find_user(self, name):
        [loaded, contactsList] = is_loaded(CreateChatComponents.CONTACTS_LIST.value)
        if loaded:
            for index in range(contactsList.count):
                user = contactsList.itemAtIndex(index)
                if(user.userName == name):
                    return True, user     
        return False, None

        
