import typing

import allure

from gui.components.base_popup import BasePopup
from gui.components.color_select_popup import ColorSelectPopup
from gui.components.community.tags_select_popup import TagsSelectPopup
from gui.components.os.open_file_dialogs import OpenFileDialog
from gui.components.picture_edit_popup import PictureEditPopup
from gui.elements.qt.button import Button
from gui.elements.qt.check_box import CheckBox
from gui.elements.qt.scroll import Scroll
from gui.elements.qt.text_edit import TextEdit
from gui.screens.community import CommunityScreen


class CreateCommunitiesBanner(BasePopup):

    def __init__(self):
        super().__init__()
        self._crete_community_button = Button('create_new_StatusButton')

    def open_create_community_popup(self) -> 'CreateCommunityPopup':
        self._crete_community_button.click()
        return CreateCommunityPopup().wait_until_appears()


class CreateCommunityPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._scroll = Scroll('o_Flickable')
        self._name_text_edit = TextEdit('createCommunityNameInput_TextEdit')
        self._description_text_edit = TextEdit('createCommunityDescriptionInput_TextEdit')
        self._add_logo_button = Button('addButton_StatusRoundButton2')
        self._add_banner_button = Button('addButton_StatusRoundButton')
        self._select_color_button = Button('StatusPickerButton')
        self._choose_tag_button = Button('choose_tags_StatusPickerButton')
        self._archive_support_checkbox = CheckBox('archiveSupportToggle_StatusCheckBox')
        self._request_to_join_checkbox = CheckBox('requestToJoinToggle_StatusCheckBox')
        self._pin_messages_checkbox = CheckBox('pinMessagesToggle_StatusCheckBox')
        self._next_button = Button('createCommunityNextBtn_StatusButton')
        self._intro_text_edit = TextEdit('createCommunityIntroMessageInput_TextEdit')
        self._outro_text_edit = TextEdit('createCommunityOutroMessageInput_TextEdit')
        self._create_community_button = Button('createCommunityFinalBtn_StatusButton')

    @property
    @allure.step('Get community name')
    def name(self) -> str:
        return self._name_text_edit.text

    @name.setter
    @allure.step('Set community name')
    def name(self, value: str):
        self._name_text_edit.text = value

    @property
    @allure.step('Get community description')
    def description(self) -> str:
        return self._description_text_edit.text

    @description.setter
    @allure.step('Set community name')
    def description(self, value: str):
        self._description_text_edit.text = value

    @property
    @allure.step('Get community logo')
    def logo(self):
        return NotImplementedError

    @logo.setter
    @allure.step('Set community logo')
    def logo(self, kwargs: dict):
        self._add_logo_button.click()
        OpenFileDialog().wait_until_appears().open_file(kwargs['fp'])
        PictureEditPopup().wait_until_appears().make_picture(kwargs.get('zoom', None), kwargs.get('shift', None))

    @property
    @allure.step('Get community banner')
    def banner(self):
        raise NotImplementedError

    @banner.setter
    @allure.step('Set community banner')
    def banner(self, kwargs: dict):
        self._add_banner_button.click()
        OpenFileDialog().wait_until_appears().open_file(kwargs['fp'])
        PictureEditPopup().wait_until_appears().make_picture(kwargs.get('zoom', None), kwargs.get('shift', None))

    @property
    @allure.step('Get community color')
    def color(self):
        raise NotImplementedError

    @color.setter
    @allure.step('Set community color')
    def color(self, value: str):
        self._scroll.vertical_scroll_to(self._select_color_button)
        self._select_color_button.click()
        ColorSelectPopup().wait_until_appears().select_color(value)

    @property
    @allure.step('Get community tags')
    def tags(self):
        raise NotImplementedError

    @tags.setter
    @allure.step('Set community tags')
    def tags(self, values: typing.List[str]):
        self._scroll.vertical_scroll_to(self._choose_tag_button)
        self._choose_tag_button.click()
        TagsSelectPopup().wait_until_appears().select_tags(values)

    @property
    @allure.step('Get community intro')
    def intro(self) -> str:
        return self._intro_text_edit.text

    @intro.setter
    @allure.step('Set community intro')
    def intro(self, value: str):
        self._intro_text_edit.text = value

    @property
    @allure.step('Get community outro')
    def outro(self) -> str:
        return self._outro_text_edit.text

    @outro.setter
    @allure.step('Set community outro')
    def outro(self, value: str):
        self._outro_text_edit.text = value

    @allure.step('Open intro/outro form')
    def open_next_form(self):
        self._next_button.click()

    @allure.step('Create community')
    def create(self, kwargs):
        for key in list(kwargs):
            if key in ['intro', 'outro'] and self._next_button.is_visible:
                self._next_button.click()
            setattr(self, key, kwargs.get(key))
        self._create_community_button.click()
        self.wait_until_hidden()
        return CommunityScreen().wait_until_appears()
