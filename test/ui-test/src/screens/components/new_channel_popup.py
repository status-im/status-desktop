import configs
from drivers.SquishDriver import *

from .base_popup import BasePopup


class NewChannelPopup(BasePopup):

    def __init__(self):
        super(NewChannelPopup, self).__init__()
        self._name_text_edit = TextEdit('createOrEditCommunityChannelNameInput_TextEdit')
        self._description_text_sdit = TextEdit('createOrEditCommunityChannelDescriptionInput_TextEdit')
        self._save_create_button = Button('createOrEditCommunityChannelBtn_StatusButton')
        self._emoji_button = Button('createOrEditCommunityChannel_EmojiButton')

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        self._name_text_edit.wait_until_appears(timeout_msec)
        return self

    def create(self, name: str, description: str):
        self._name_text_edit.text = name
        self._description_text_sdit.text = description
        self._save_create_button.click()
        self.wait_until_hidden()
