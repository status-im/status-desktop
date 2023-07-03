from drivers.SDKeyboardCommands import *
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from utils.FileManager import *
from utils.ObjectAccess import *


class LeftPanel():

    def __init__(self):
        self._overview_button = Button('communitySettingsView_NavigationListItem_Overview')

    def wait_until_appears(self):
        self._overview_button.wait_until_appears()
        return self

    def open_overview(self) -> 'OverviewView':
        self._overview_button.click()
        return OverviewView().wait_until_appears()

    def open_members(self) -> 'MembersView':
        pass

    def open_permissions(self) -> 'PermissionsView':
        pass

    def open_mint_tokens(self) -> 'MintTokensView':
        pass

    def open_airdrops(self) -> 'AirDropsView':
        pass


class OverviewView:

    def __init__(self):
        self._edit_community_button = Button('communitySettings_EditCommunity_Button')

    def wait_until_appears(self):
        self._edit_community_button.wait_until_appears()
        return self

    def open_edit_community_view(self) -> 'EditCommunityView':
        self._edit_community_button.click()
        return EditCommunityView().wait_until_appears()


class EditCommunityView:

    def __init__(self):
        self._name_text_edit = TextEdit('communitySettings_EditCommunity_Name_Input')
        self._description_text_edit = TextEdit('communitySettings_EditCommunity_Description_Input')
        self._save_button = Button('settingsSave_StatusButton')
        
    def edit(
            self,
            name: str = None,
            description: str = None,
    ):
        if name is not None:
            self._name_text_edit.text = name
        if description is not None:
            self._description_text_edit.text = description
        self._save_button.click()

    def wait_until_appears(self):
        self._name_text_edit.wait_until_appears()
        return self


class MembersView:

    def wait_until_appears(self):
        return self


class PermissionsView:

    def wait_until_appears(self):
        return self


class MintTokensView:

    def wait_until_appears(self):
        return self


class AirDropsView:

    def wait_until_appears(self):
        return self


class CommunitySettingsScreen(BaseElement):

    def __init__(self):
        super(CommunitySettingsScreen, self).__init__('mainWindow_StatusSectionLayout_ContentItem')
        self.left_panel = LeftPanel()

    def wait_until_appears(self):
        self.left_panel.wait_until_appears()
        return self
