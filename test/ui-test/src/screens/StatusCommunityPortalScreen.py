from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from utils.decorators import attempt

from .components.new_community_popup import NewCommunityPopup, NewCommunityFormPopup


class StatusCommunityPortalScreen(BaseElement):
    
    def __init__(self):
        super(StatusCommunityPortalScreen, self).__init__('mainWindow_communitiesPortalLayoutContainer_CommunitiesPortalLayout')
        self._create_community_button = Button('communitiesPortalLayoutContainer_createCommunityButton_StatusButton')

    @attempt(2)
    def open_create_community_popup(self):
        self._create_community_button.click()
        NewCommunityPopup().wait_until_appears()

    @attempt(2)
    def open_create_community_form_popup(self) -> NewCommunityFormPopup:
        return NewCommunityPopup().open_new_community_form()

    def create(self, name: str, description: str, intro: str, outro: str):
        self.open_create_community_popup()
        self.open_create_community_form_popup().create(name, description, intro, outro)
