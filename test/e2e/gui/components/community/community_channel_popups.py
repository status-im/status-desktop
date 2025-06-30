import configs
from gui.components.community.new_permission_popup import NewPermissionPopup
from gui.components.emoji_popup import EmojiPopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class ChannelPopup(QObject):

    def __init__(self):
        super().__init__(names.newChannelnewCategoryPopup)
        self._name_text_edit = TextEdit(names.createOrEditCommunityChannelNameInput_TextEdit)
        self._description_text_edit = TextEdit(names.createOrEditCommunityChannelDescriptionInput_TextEdit)
        self.save_create_button = Button(names.createOrEditCommunityChannelBtn_StatusButton)
        self._emoji_button = Button(names.createOrEditCommunityChannel_EmojiButton)
        self._add_permission_button = Button(names.add_permission_StatusButton)
        self._hide_channel_checkbox = CheckBox(names.hide_channel_checkbox)

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
        return self

    def add_permission(self):
        self._add_permission_button.click()
        return NewPermissionPopup().wait_until_appears()

    def hide_permission(self, value: bool, attempt: int = 2):
        try:
            return self._hide_channel_checkbox.set(value)
        except AssertionError as err:
            if attempt:
                self.hide_permission(True, attempt - 1)
            else:
                raise err


class EditChannelPopup(ChannelPopup):

    def edit(self, name: str, description: str = None, emoji: str = None):
        self._name_text_edit.text = name
        if description is not None:
            self._description_text_edit.text = description
        if emoji is not None:
            self._emoji_button.click()
            EmojiPopup().wait_until_appears().select(emoji)
        self.save_create_button.click()
        self.wait_until_hidden()
