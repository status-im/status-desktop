import typing

import allure
from allure_commons._allure import step

import driver
from constants import UserChannel
from gui.components.community.community_channel_popups import EditChannelPopup, NewChannelPopup
from gui.components.community.welcome_community import WelcomeCommunityPopup
from gui.components.delete_popup import DeletePopup
from gui.elements.qt.button import Button
from gui.elements.qt.list import List
from gui.elements.qt.object import QObject
from gui.elements.qt.text_label import TextLabel
from gui.screens.community_settings import CommunitySettingsScreen
from scripts.tools import image
from scripts.tools.image import Image


class CommunityScreen(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityLoader_Loader')
        self.left_panel = LeftPanel()
        self.tool_bar = ToolBar()
        self.chat = Chat()
        self.right_panel = Members()

    @allure.step('Create channel')
    def create_channel(self, name: str, description: str, emoji: str = None):
        self.left_panel.open_create_channel_popup().create(name, description, emoji)

    @allure.step('Create channel')
    def edit_channel(self, channel, name: str, description: str, emoji: str = None):
        self.left_panel.select_channel(channel)
        self.tool_bar.open_edit_channel_popup().edit(name, description, emoji)

    @allure.step('Delete channel')
    def delete_channel(self, name: str):
        self.left_panel.select_channel(name)
        self.tool_bar.open_delete_channel_popup().delete()

    @allure.step('Verify channel')
    def verify_channel(
            self, name: str, description: str, icon_in_list: str, icon_in_toolbar: str, icon_in_chat: str):
        with step('Channel is correct in channels list'):
            channel = self.left_panel.get_channel_parameters(name)
            image.compare(channel.image, icon_in_list, timout_sec=5)
            assert channel.name == name
            assert channel.selected

        with step('Channel is correct in community toolbar'):
            assert self.tool_bar.channel_name == name
            assert self.tool_bar.channel_description == description
            image.compare(self.tool_bar.channel_icon, icon_in_toolbar, timout_sec=5)

        with step('Verify channel in chat'):
            assert self.chat.channel_name == name
            image.compare(self.chat.channel_icon, icon_in_chat, timout_sec=5)


class ToolBar(QObject):

    def __init__(self):
        super().__init__('mainWindow_statusToolBar_StatusToolBar')
        self._more_options_button = Button('statusToolBar_chatToolbarMoreOptionsButton')
        self._options_list = List('o_StatusListView')
        self._edit_channel_context_item = QObject('edit_Channel_StatusMenuItem')
        self._channel_icon = QObject('statusToolBar_statusSmartIdenticonLetter_StatusLetterIdenticon')
        self._channel_name = TextLabel('statusToolBar_statusChatInfoButtonNameText_TruncatedTextWithTooltip')
        self._channel_description = TextLabel('statusToolBar_TruncatedTextWithTooltip')
        self._delete_channel_context_item = QObject('delete_Channel_StatusMenuItem')

    @property
    @allure.step('Get channel icon')
    def channel_icon(self) -> Image:
        return self._channel_icon.image

    @property
    @allure.step('Get channel name')
    def channel_name(self) -> str:
        return self._channel_name.text

    @property
    @allure.step('Get channel description')
    def channel_description(self) -> str:
        return self._channel_description.text

    @allure.step('Open edit channel popup')
    def open_edit_channel_popup(self):
        self._more_options_button.click()
        self._edit_channel_context_item.click()
        return EditChannelPopup().wait_until_appears()

    @allure.step('Open delete channel popup')
    def open_delete_channel_popup(self):
        self._more_options_button.click()
        self._delete_channel_context_item.click()
        return DeletePopup().wait_until_appears()


class LeftPanel(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityColumnView_CommunityColumnView')
        self._community_info_button = Button('mainWindow_communityHeaderButton_StatusChatInfoButton')
        self._community_logo = QObject('mainWindow_identicon_StatusSmartIdenticon')
        self._name_text_label = TextLabel('mainWindow_statusChatInfoButtonNameText_TruncatedTextWithTooltip')
        self._members_text_label = TextLabel('mainWindow_Members_TruncatedTextWithTooltip')
        self._channel_list_item = QObject('channel_listItem')
        self._channel_icon_template = QObject('channel_identicon_StatusSmartIdenticon')
        self._channel_or_category_button = Button('mainWindow_createChannelOrCategoryBtn_StatusBaseText')
        self._create_channel_menu_item = Button('create_channel_StatusMenuItem')
        self._join_community_button = Button('mainWindow_Join_Community_StatusButton')

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

    @property
    @allure.step('Get Join button visible attribute')
    def is_join_community_visible(self) -> bool:
        return self._join_community_button.is_visible

    @property
    @allure.step('Get channels')
    def channels(self) -> typing.List[UserChannel]:
        channels_list = []
        for obj in driver.findAllObjects(self._channel_list_item.real_name):
            container = driver.objectMap.realName(obj)
            self._channel_icon_template.real_name['container'] = container
            channels_list.append(UserChannel(
                str(obj.objectName),
                self._channel_icon_template.image,
                obj.item.selected
            ))
        return channels_list

    @allure.step('Get channel params')
    def get_channel_parameters(self, name) -> UserChannel:
        for channal in self.channels:
            if channal.name == name:
                return channal
        raise LookupError(f'Channel not found in {self.channels}')

    @allure.step('Open community settings')
    def open_community_settings(self):
        self._community_info_button.click()
        return CommunitySettingsScreen().wait_until_appears()

    @allure.step('Open create channel popup')
    def open_create_channel_popup(self) -> NewChannelPopup:
        self._channel_or_category_button.click()
        self._create_channel_menu_item.click()
        return NewChannelPopup().wait_until_appears()

    @allure.step('Select channel')
    def select_channel(self, name: str):
        for obj in driver.findAllObjects(self._channel_list_item.real_name):
            if str(obj.objectName) == name:
                driver.mouseClick(obj)
                return
        raise LookupError('Channel not found')

    @allure.step('Open join community popup')
    def open_welcome_community_popup(self):
        self._join_community_button.click()
        return WelcomeCommunityPopup().wait_until_appears()


class Chat(QObject):

    def __init__(self):
        super().__init__('mainWindow_ChatColumnView')
        self._channel_icon = QObject('chatMessageViewDelegate_channelIdentifierSmartIdenticon_StatusSmartIdenticon')
        self._channel_name_label = TextLabel('chatMessageViewDelegate_channelIdentifierNameText_StyledText')
        self._channel_welcome_label = TextLabel('chatMessageViewDelegate_Welcome')

    @property
    @allure.step('Get channel icon')
    def channel_icon(self) -> Image:
        return self._channel_icon.image

    @property
    @allure.step('Get channel name')
    def channel_name(self) -> str:
        return self._channel_name_label.text

    @property
    @allure.step('Get channel welcome note')
    def channel_welcome_note(self) -> str:
        return self._channel_welcome_label.text


class Members(QObject):

    def __init__(self):
        super().__init__('mainWindow_UserListPanel')
        self._member_item = QObject('userListPanel_StatusMemberListItem')

    @property
    @allure.step('Get all members')
    def members(self) -> typing.List[str]:
        return [str(member.statusListItemTitle.text) for member in driver.findAllObjects(self._member_item.real_name)]
