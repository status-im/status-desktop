from enum import Enum
import time
import sys
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


class MainCommunityPortalScreen(Enum):
    CREATE_COMMUNITY_BUTTON: str = "communitiesPortalLayoutContainer_createCommunityButton_StatusButton"

    
class CreateCommunityPopup(Enum):
    COMMUNITY_NAME_INPUT: str = "createCommunityNameInput_TextEdit"
    COMMUNITY_DESCRIPTION_INPUT: str = "createCommunityDescriptionInput_TextEdit"
    NEXT_SCREEN_BUTTON: str = "createCommunityNextBtn_StatusButton"
    COMMUNITY_INTRO_MESSAGE_INPUT: str = "createCommunityIntroMessageInput_TextEdit"
    COMMUNITY_OUTRO_MESSAGE_INPUT: str = "createCommunityOutroMessageInput_TextEdit"
    DO_CREATE_COMMUNITY_BUTTON: str = "createCommunityFinalBtn_StatusButton"

class StatusCommunityPortalScreen:
    
    def __init__(self):
        verify_screen(MainCommunityPortalScreen.CREATE_COMMUNITY_BUTTON.value)

    
    def create_community(self, communityName: str, communityDescription: str, introMessage: str, outroMessage: str):
        click_obj_by_name(MainCommunityPortalScreen.CREATE_COMMUNITY_BUTTON.value)
        
        type(CreateCommunityPopup.COMMUNITY_NAME_INPUT.value, communityName)
        type(CreateCommunityPopup.COMMUNITY_DESCRIPTION_INPUT.value, communityDescription)
        click_obj_by_name(CreateCommunityPopup.NEXT_SCREEN_BUTTON.value)
        
        wait_for_object_and_type(CreateCommunityPopup.COMMUNITY_INTRO_MESSAGE_INPUT.value, introMessage)
        type(CreateCommunityPopup.COMMUNITY_OUTRO_MESSAGE_INPUT.value, outroMessage)
        click_obj_by_name(CreateCommunityPopup.DO_CREATE_COMMUNITY_BUTTON.value)
