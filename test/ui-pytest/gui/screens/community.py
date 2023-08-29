import allure

from gui.elements.qt.button import Button
from gui.elements.qt.list import List
from gui.elements.qt.object import QObject
from gui.elements.qt.text_label import TextLabel
from gui.screens.community_settings import CommunitySettingsScreen
from scripts.tools.image import Image


class CommunityScreen(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityLoader_Loader')
        self.left_panel = LeftPanel()
        self._tool_bar = ToolBar()


class ToolBar(QObject):

    def __init__(self):
        super().__init__('mainWindow_statusToolBar_StatusToolBar')
        self._more_options_button = Button('statusToolBar_chatToolbarMoreOptionsButton')
        self._options_list = List('o_StatusListView')

    @allure.step('Open edit community popup')
    def open_edit_community_popup(self):
        self._more_options_button.click()
        self._options_list.select()


class LeftPanel(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityColumnView_CommunityColumnView')
        self._community_info_button = Button('mainWindow_communityHeaderButton_StatusChatInfoButton')
        self._community_logo = QObject('mainWindow_identicon_StatusSmartIdenticon')
        self._name_text_label = TextLabel('mainWindow_statusChatInfoButtonNameText_TruncatedTextWithTooltip')
        self._members_text_label = TextLabel('mainWindow_Members_TruncatedTextWithTooltip')

    @property
    @allure.step('Get community logo')
    def logo(self) -> Image:
        return self._community_logo.image

    @property
    @allure.step('Get community name')
    def name(self) -> str:
        return self._name_text_label.text

    @property
    @allure.step('Get community members label')
    def members(self) -> str:
        return self._members_text_label.text

    @allure.step('Open community settings')
    def open_community_settings(self):
        self._community_info_button.click()
        return CommunitySettingsScreen().wait_until_appears()
