import configs
from gui.components.base_popup import BasePopup
from gui.components.emoji_popup import EmojiPopup
from gui.elements.qt.button import Button
from gui.elements.qt.text_edit import TextEdit


class ChannelPopup(BasePopup):

    def __init__(self):
        super(ChannelPopup, self).__init__()
        self._name_text_edit = TextEdit('createOrEditCommunityChannelNameInput_TextEdit')
        self._description_text_edit = TextEdit('createOrEditCommunityChannelDescriptionInput_TextEdit')
        self._save_create_button = Button('createOrEditCommunityChannelBtn_StatusButton')
        self._emoji_button = Button('createOrEditCommunityChannel_EmojiButton')

    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._name_text_edit.wait_until_appears(timeout_msec)
        return self


class NewChannelPopup(ChannelPopup):

    def create(self, name: str, description: str, emoji: str = None):
        self._name_text_edit.text = name
        self._description_text_edit.text = description
        if emoji is not None:
            self._emoji_button.click()
            EmojiPopup().wait_until_appears().select(emoji)
        self._save_create_button.click()
        self.wait_until_hidden()


class EditChannelPopup(ChannelPopup):

    def edit(self, name: str, description: str = None, emoji: str = None):
        self._name_text_edit.text = name
        if description is not None:
            self._description_text_edit.text = description
        if emoji is not None:
            self._emoji_button.click()
            EmojiPopup().wait_until_appears().select(emoji)
        self._save_create_button.click()
        self.wait_until_hidden()
