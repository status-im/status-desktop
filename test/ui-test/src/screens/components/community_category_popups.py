import typing

import configs
from drivers.SquishDriver import *

from .base_popup import BasePopup


class CategoryPopup(BasePopup):

    def __init__(self):
        super(CategoryPopup, self).__init__()
        self._name_text_edit = TextEdit('createOrEditCommunityCategoryNameInput_TextEdit')
        self._channel_list_item = BaseElement('category_item_channel_StatusListItem')
        self._save_create_button = Button('createOrEditCommunityCategoryBtn_StatusButton')

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        self._name_text_edit.wait_until_appears(timeout_msec)
        return self

    def _get_and_verify_channel_list(self, names: typing.List[str]):
        channel_objects = get_objects(self._channel_list_item.symbolic_name)
        channel_names = [str(channel.title).split('#')[1] for channel in channel_objects]
        for name in names:
            assert name in channel_names, f'Channel "{name}" not found in {channel_names}'
        return channel_objects, channel_names


class NewCategoryPopup(CategoryPopup):

    def _select_channels(self, names: typing.List[str]):
        channel_objects, channel_names = self._get_and_verify_channel_list(names)

        for obj, channel in zip(channel_objects, channel_names):
            if channel in names:
                click_obj(obj)

    def create(self, name: str, channels: typing.List[str] = None):
        self._name_text_edit.text = name
        if channels is not None:
            self._select_channels(channels)
        self._save_create_button.click()
        self.wait_until_hidden()


class EditCategoryPopup(CategoryPopup):

    def _check(self, names: typing.List[str]):
        channel_objects, channel_names = self._get_and_verify_channel_list(names)

        for obj, channel in zip(channel_objects, channel_names):
            if channel in names and not obj.checked:
                click_obj(obj)
            elif channel not in channel_names and obj.checked:
                click_obj(obj)

    def _uncheck_all(self):
        channel_objects = get_objects(self._channel_list_item.symbolic_name)
        for obj in channel_objects:
            if obj.checked:
                click_obj(obj)

    def edit(self, name: str, channels: typing.List[str] = None):
        self._name_text_edit.text = name
        if channels is not None:
            if channels:
                self._check(channels)
            else:
                self._uncheck_all()
        self._save_create_button.click()
        self.wait_until_hidden()
