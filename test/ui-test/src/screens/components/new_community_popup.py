import configs
from drivers.SquishDriver import *

from .base_popup import BasePopup


class NewCommunityPopup(BasePopup):

    def __init__(self):
        super(NewCommunityPopup, self).__init__()
        self._create_button = Button('create_new_StatusButton')

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        self._create_button.wait_until_appears(timeout_msec)
        return self

    def open_new_community_form(self):
        self._create_button.click()
        return NewCommunityFormPopup().wait_until_appears()


class NewCommunityFormPopup(BasePopup):

    def __init__(self):
        super(NewCommunityFormPopup, self).__init__()
        self._name_text_edit = TextEdit('createCommunityNameInput_TextEdit')
        self._description_text_edit = TextEdit('createCommunityDescriptionInput_TextEdit')
        self._next_button = Button('createCommunityNextBtn_StatusButton')
        self._intro_text_edit = TextEdit('createCommunityIntroMessageInput_TextEdit')
        self._outro_text_edit = TextEdit('createCommunityOutroMessageInput_TextEdit')
        self._create_button = Button('createCommunityFinalBtn_StatusButton')

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        self._name_text_edit.wait_until_appears(timeout_msec)
        return self

    def create(self, name: str, description: str, intro: str, outro: str):
        self._name_text_edit.text = name
        self._description_text_edit.text = description
        self._next_button.click()
        self._intro_text_edit.wait_until_appears()
        self._intro_text_edit.text = intro
        self._outro_text_edit.text = outro
        self._create_button.click()
        self.wait_until_hidden()
