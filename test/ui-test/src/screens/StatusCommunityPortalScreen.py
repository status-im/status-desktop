from enum import Enum
import time
import sys
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from utils.decorators import attempt

class MainCommunityPortalScreen(Enum):
    CREATE_COMMUNITY_BUTTON: str = "communitiesPortalLayoutContainer_createCommunityButton_StatusButton"
    CREATE_COMMUNITY_BANNER_BUTTON: str = "createCommunity_bannerButton"

    
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
    
    @attempt(2)
    def open_create_community_bunner(self):
        click_obj_by_name(MainCommunityPortalScreen.CREATE_COMMUNITY_BUTTON.value)
        BaseElement(MainCommunityPortalScreen.CREATE_COMMUNITY_BANNER_BUTTON.value).wait_until_appears()

    @attempt(2)
    def open_create_community_popup(self):
        click_obj_by_name(MainCommunityPortalScreen.CREATE_COMMUNITY_BANNER_BUTTON.value)
        BaseElement(CreateCommunityPopup.COMMUNITY_NAME_INPUT.value).wait_until_appears()

    def create_community(self, communityName: str, communityDescription: str, introMessage: str, outroMessage: str):
        self.open_create_community_bunner()
        self.open_create_community_popup()
        
        type_text(CreateCommunityPopup.COMMUNITY_NAME_INPUT.value, communityName)
        type_text(CreateCommunityPopup.COMMUNITY_DESCRIPTION_INPUT.value, communityDescription)
        click_obj_by_name(CreateCommunityPopup.NEXT_SCREEN_BUTTON.value)
        
        wait_for_object_and_type(CreateCommunityPopup.COMMUNITY_INTRO_MESSAGE_INPUT.value, introMessage)
        type_text(CreateCommunityPopup.COMMUNITY_OUTRO_MESSAGE_INPUT.value, outroMessage)
        click_obj_by_name(CreateCommunityPopup.DO_CREATE_COMMUNITY_BUTTON.value)
