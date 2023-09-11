import typing

import allure

import driver
from gui.components.color_select_popup import ColorSelectPopup
from gui.components.community.tags_select_popup import TagsSelectPopup
from gui.components.os.open_file_dialogs import OpenFileDialog
from gui.components.picture_edit_popup import PictureEditPopup
from gui.elements.qt.button import Button
from gui.elements.qt.check_box import CheckBox
from gui.elements.qt.object import QObject
from gui.elements.qt.scroll import Scroll
from gui.elements.qt.text_edit import TextEdit
from gui.elements.qt.text_label import TextLabel
from scripts.tools.image import Image


class CommunitySettingsScreen(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityLoader_Loader')
        self.left_panel = LeftPanel()


class LeftPanel(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityColumnView_CommunityColumnView')
        self._back_to_community_button = Button('mainWindow_communitySettingsBackToCommunityButton_StatusBaseText')
        self._overview_button = Button('overview_StatusNavigationListItem')
        self._members_button = Button('members_StatusNavigationListItem')

    @allure.step('Open community main view')
    def back_to_community(self):
        self._back_to_community_button.click()

    @allure.step('Open community overview')
    def open_overview(self) -> 'OverviewView':
        if not self._overview_button.is_selected:
            self._overview_button.click()
        return OverviewView().wait_until_appears()

    @allure.step('Open community members')
    def open_members(self) -> 'MembersView':
        if not self._members_button.is_selected:
            self._members_button.click()
        return MembersView().wait_until_appears()


class OverviewView(QObject):

    def __init__(self):
        super().__init__('mainWindow_OverviewSettingsPanel')
        self._name_text_label = TextLabel('communityOverviewSettingsCommunityName_StatusBaseText')
        self._description_text_label = TextLabel('communityOverviewSettingsCommunityDescription_StatusBaseText')
        self._edit_button = Button('mainWindow_Edit_Community_StatusButton')

    @property
    @allure.step('Get community name')
    def name(self) -> str:
        return self._name_text_label.text

    @property
    @allure.step('Get community description')
    def description(self) -> str:
        return self._description_text_label.text

    @allure.step('Open edit community view')
    def open_edit_community_view(self) -> 'EditCommunityView':
        self._edit_button.click()
        return EditCommunityView().wait_until_appears()


class EditCommunityView(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityEditPanelScrollView_EditSettingsPanel')
        self._scroll = Scroll('communityEditPanelScrollView_Flickable')
        self._name_text_edit = TextEdit('communityEditPanelScrollView_communityNameInput_TextEdit')
        self._description_text_edit = TextEdit('communityEditPanelScrollView_communityDescriptionInput_TextEdit')
        self._logo = QObject('communityEditPanelScrollView_image_StatusImage')
        self._add_logo_button = Button('communityEditPanelScrollView_editButton_StatusRoundButton')
        self._banner = QObject('communityEditPanelScrollView_image_StatusImage_2')
        self._add_banner_button = Button('communityEditPanelScrollView_editButton_StatusRoundButton_2')
        self._select_color_button = Button('communityEditPanelScrollView_StatusPickerButton')
        self._choose_tag_button = Button('communityEditPanelScrollView_Choose_StatusPickerButton')
        self._tag_item = QObject('communityEditPanelScrollView_StatusCommunityTag')
        self._archive_support_checkbox = CheckBox('communityEditPanelScrollView_archiveSupportToggle_StatusCheckBox')
        self._request_to_join_checkbox = CheckBox('communityEditPanelScrollView_requestToJoinToggle_StatusCheckBox')
        self._pin_messages_checkbox = CheckBox('communityEditPanelScrollView_pinMessagesToggle_StatusCheckBox')
        self._intro_text_edit = TextEdit('communityEditPanelScrollView_editCommunityIntroInput_TextEdit')
        self._outro_text_edit = TextEdit('communityEditPanelScrollView_editCommunityOutroInput_TextEdit')
        self._save_changes_button = Button('mainWindow_Save_changes_StatusButton')

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
    @allure.step('Set community description')
    def description(self, value: str):
        self._description_text_edit.text = value

    @property
    @allure.step('Get community logo')
    def logo(self) -> Image:
        return self._logo.image

    @logo.setter
    @allure.step('Set community description')
    def logo(self, kwargs: dict):
        self._add_logo_button.click()
        OpenFileDialog().wait_until_appears().open_file(kwargs['fp'])
        PictureEditPopup().wait_until_appears().make_picture(kwargs.get('zoom', None), kwargs.get('shift', None))

    @property
    @allure.step('Get community banner')
    def banner(self) -> Image:
        return self._banner.image

    @banner.setter
    @allure.step('Set community description')
    def banner(self, kwargs: dict):
        self._add_banner_button.click()
        OpenFileDialog().wait_until_appears().open_file(kwargs['fp'])
        PictureEditPopup().wait_until_appears().make_picture(kwargs.get('zoom', None), kwargs.get('shift', None))

    @property
    @allure.step('Get community color')
    def color(self) -> str:
        return str(self._select_color_button.object.text)

    @color.setter
    @allure.step('Set community color')
    def color(self, value: str):
        self._scroll.vertical_scroll_to(self._select_color_button)
        self._select_color_button.click()
        ColorSelectPopup().wait_until_appears().select_color(value)

    @property
    @allure.step('Get community tags')
    def tags(self):
        self._scroll.vertical_scroll_to(self._choose_tag_button)
        return [str(tag.title) for tag in driver.fiandAllObjects(self._tag_item.real_name)]

    @tags.setter
    @allure.step('Set community tags')
    def tags(self, values: typing.List[str]):
        self._scroll.vertical_scroll_to(self._choose_tag_button)
        self._choose_tag_button.click()
        TagsSelectPopup().wait_until_appears().select_tags(values)

    @property
    @allure.step('Get community intro')
    def intro(self) -> str:
        self._scroll.vertical_scroll_to(self._intro_text_edit)
        return self._intro_text_edit.text

    @intro.setter
    @allure.step('Set community intro')
    def intro(self, value: str):
        self._scroll.vertical_scroll_to(self._intro_text_edit)
        self._intro_text_edit.text = value

    @property
    @allure.step('Get community outro')
    def outro(self) -> str:
        self._scroll.vertical_scroll_to(self._outro_text_edit)
        return self._outro_text_edit.text

    @outro.setter
    @allure.step('Set community outro')
    def outro(self, value: str):
        self._scroll.vertical_scroll_to(self._outro_text_edit)
        self._outro_text_edit.text = value

    @allure.step('Edit community')
    def edit(self, kwargs):
        for key in list(kwargs):
            setattr(self, key, kwargs.get(key))
        self._save_changes_button.click()
        self.wait_until_hidden()


class MembersView(QObject):

    def __init__(self):
        super().__init__('mainWindow_MembersSettingsPanel')
        self._member_list_item = QObject('memberItem_StatusMemberListItem')

    @property
    @allure.step('Get community members')
    def members(self) -> typing.List[str]:
        return [str(member.title) for member in driver.findAllObjects(self._member_list_item.real_name)]
