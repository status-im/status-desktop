import time
import typing

import allure
from allure_commons._allure import step

import configs
import driver
from constants import UserChannel, ColorCodes
from driver.objects_access import walk_children
from gui.components.community.community_category_popup import NewCategoryPopup, EditCategoryPopup, CategoryPopup
from gui.components.community.community_channel_popups import EditChannelPopup, NewChannelPopup
from gui.components.community.welcome_community import WelcomeCommunityPopup
from gui.components.context_menu import ContextMenu
from gui.components.delete_popup import DeletePopup, DeleteCategoryPopup
from gui.components.profile_popup import ProfilePopupFromMembers
from gui.elements.button import Button
from gui.elements.list import List
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names, communities_names, messaging_names
from gui.screens.community_settings import CommunitySettingsScreen
from scripts.tools.image import Image


class CommunityScreen(QObject):

    def __init__(self):
        super().__init__(communities_names.mainWindow_communityLoader_Loader)
        self.left_panel = LeftPanel()
        self.tool_bar = ToolBar()
        self.chat = Chat()
        self.right_panel = Members()

    @allure.step('Create channel')
    def create_channel(self, name: str, description: str, emoji: str = None):
        self.left_panel.open_create_channel_popup().create(name, description, emoji)

    @allure.step('Edit channel')
    def edit_channel(self, channel, name: str, description: str, emoji: str = None):
        self.left_panel.select_channel(channel)
        self.tool_bar.open_edit_channel_popup().edit(name, description, emoji)

    @allure.step('Delete channel')
    def delete_channel(self, name: str):
        self.left_panel.select_channel(name)
        self.tool_bar.open_delete_channel_popup().delete()

    @allure.step('Verify channel')
    def verify_channel(
            self, name: str, description: str, emoji):
        with step('Channel is correct in channels list'):
            channel = self.left_panel.get_channel_parameters(name)
            assert channel.name == name

        with step('Channel is correct in community toolbar'):
            assert self.tool_bar.channel_name == name
            assert self.tool_bar.channel_description == description
            if emoji is not None:
                assert self.tool_bar.channel_emoji == emoji

        with step('Verify channel in chat'):
            assert self.chat.channel_name == name
            if emoji is not None:
                assert self.chat.channel_emoji == emoji

    @allure.step('Create category')
    def create_category(self, name: str, general_checkbox: bool):
        self.left_panel.open_create_category_popup().create(name, general_checkbox)

    @allure.step('Delete category from the list')
    def delete_category(self):
        self.left_panel.open_more_options()
        self.left_panel.open_delete_category_popup().delete()

    @allure.step('Edit category')
    def edit_category(self):
        self.left_panel.open_more_options()
        self.left_panel.open_edit_category_popup()
        return EditCategoryPopup()

    @allure.step('Verify category in the list')
    def verify_category(self, category_name: str):
        category = self.left_panel.find_category_in_list(category_name)
        assert category.category_name == category_name


class ToolBar(QObject):

    def __init__(self):
        super().__init__(communities_names.mainWindow_statusToolBar_StatusToolBar)
        self._more_options_button = Button(communities_names.statusToolBar_chatToolbarMoreOptionsButton)
        self._options_list = List(names.o_StatusListView)
        self._edit_channel_context_item = QObject(communities_names.edit_Channel_StatusMenuItem)
        self._channel_icon = QObject(communities_names.statusToolBar_statusSmartIdenticonLetter_StatusLetterIdenticon)
        self._channel_name = TextLabel(
            communities_names.statusToolBar_statusChatInfoButtonNameText_TruncatedTextWithTooltip)
        self._channel_description = TextLabel(communities_names.statusToolBar_TruncatedTextWithTooltip)
        self._delete_channel_context_item = QObject(communities_names.delete_Channel_StatusMenuItem)
        self._channel_header = QObject(communities_names.statusToolBar_chatInfoBtnInHeader_StatusChatInfoButton)

    @property
    @allure.step('Get channel emoji')
    def channel_emoji(self):
        return self._channel_header.object.asset.emoji

    @property
    @allure.step('Get channel color')
    def channel_color(self) -> str:
        return str(self._channel_header.object.asset.color.name).lower()

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
        self.open_more_options_dropdown()
        self._edit_channel_context_item.click()
        return EditChannelPopup().wait_until_appears()

    @allure.step('Open delete channel popup')
    def open_delete_channel_popup(self):
        self.open_more_options_dropdown()
        self._delete_channel_context_item.click()
        return DeletePopup().wait_until_appears()

    @allure.step('Open more options dropdown')
    def open_more_options_dropdown(self):
        self._more_options_button.click()
        return ContextMenu()

    @allure.step('Get visibility state of edit item')
    def is_edit_item_visible(self) -> bool:
        return self._edit_channel_context_item.exists

    @allure.step('Get visibility state of delete item')
    def is_delete_item_visible(self) -> bool:
        return self._delete_channel_context_item.exists


class CategoryItem:

    def __init__(self, obj):
        self.object = obj
        self.category_name: typing.Optional[Image] = None
        self._add_category_button: typing.Optional[Button] = None
        self._more_button: typing.Optional[Button] = None
        self._arrow_button: typing.Optional[Button] = None
        self._arrow_icon: typing.Optional[QObject] = None
        self.init_ui()

    def __repr__(self):
        return self.category_name

    def init_ui(self):
        for child in walk_children(self.object):
            if str(getattr(child, 'id', '')) == 'statusChatListCategoryItem':
                self.category_name = str(child.text)
            elif str(getattr(child, 'id', '')) == 'addButton':
                self._add_channel_button = Button(real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'id', '')) == 'menuButton':
                self._more_button = Button(real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'id', '')) == 'toggleButton':
                self._arrow_button = Button(real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'objectName', '')) == 'chevron-down-icon':
                self._arrow_icon = QObject(real_name=driver.objectMap.realName(child))

    @allure.step('Click arrow button')
    def click_arrow_button(self):
        self._arrow_button.click()

    @allure.step('Get arrow button rotation value')
    def get_arrow_icon_rotation_value(self) -> int:
        return self._arrow_icon.object.rotation


class LeftPanel(QObject):

    def __init__(self):
        super().__init__(communities_names.mainWindow_communityColumnView_CommunityColumnView)
        self._community_info_button = Button(communities_names.mainWindow_communityHeaderButton_StatusChatInfoButton)
        self._community_logo = QObject(communities_names.mainWindow_identicon_StatusSmartIdenticon)
        self._name_text_label = TextLabel(
            communities_names.mainWindow_statusChatInfoButtonNameText_TruncatedTextWithTooltip)
        self._members_text_label = TextLabel(communities_names.mainWindow_Members_TruncatedTextWithTooltip)
        self._general_channel_item = QObject(communities_names.scrollView_general_StatusChatListItem)
        self._add_channels_button = Button(communities_names.add_channels_StatusButton)
        self._channel_list_item = QObject(communities_names.channel_listItem)
        self._channel_icon_template = QObject(communities_names.channel_identicon_StatusSmartIdenticon)
        self._channel_or_category_button = Button(
            communities_names.mainWindow_createChannelOrCategoryBtn_StatusBaseText)
        self._create_channel_menu_item = Button(communities_names.create_channel_StatusMenuItem)
        self._create_category_menu_item = Button(communities_names.create_category_StatusMenuItem)
        self._join_community_button = Button(communities_names.mainWindow_Join_Community_StatusButton)
        self._categories_items_list = List(communities_names.scrollView_chatListItems_StatusListView)
        self._category_list_item = QObject(communities_names.categoryItem_StatusChatListCategoryItem)
        self._create_category_button = Button(communities_names.add_categories_StatusFlatButton)
        self._delete_category_item = QObject(communities_names.delete_Category_StatusMenuItem)
        self._edit_category_item = QObject(communities_names.edit_Category_StatusMenuItem)
        self._add_channel_inside_category_item = QObject(
            communities_names.scrollView_addButton_StatusChatListCategoryItemButton)
        self._more_button = Button(communities_names.scrollView_menuButton_StatusChatListCategoryItemButton)
        self._arrow_button = Button(communities_names.scrollView_toggleButton_StatusChatListCategoryItemButton)

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
        return self._join_community_button.exists

    @property
    @allure.step('Get channels')
    def channels(self) -> typing.List[UserChannel]:
        time.sleep(0.5)
        channels_list = []
        for obj in driver.findAllObjects(self._channel_list_item.real_name):
            container = driver.objectMap.realName(obj)
            self._channel_icon_template.real_name['container'] = container
            channels_list.append(UserChannel(
                str(obj.objectName),
                obj.item.selected,
                obj.item.visible
            ))
        return channels_list

    @property
    @allure.step('Get categories')
    def categories_items(self) -> typing.List[CategoryItem]:
        return [CategoryItem(item) for item in self._categories_items_list.items]

    @allure.step('Get arrow button rotation value')
    def get_arrow_icon_rotation_value(self, category_name) -> int:
        category = self.find_category_in_list(category_name)
        return int(category.get_arrow_icon_rotation_value())

    @allure.step('Get channel params')
    def get_channel_parameters(self, name) -> UserChannel:
        for channel in self.channels:
            if channel.name == name:
                return channel
        raise LookupError(f'Channel not found in {self.channels}')

    @allure.step('Open community settings')
    def open_community_settings(self):
        self._community_info_button.click()
        return CommunitySettingsScreen().wait_until_appears()

    @allure.step('Open create channel popup')
    def open_create_channel_popup(self) -> NewChannelPopup:
        self._channel_or_category_button.click()
        self._create_channel_menu_item.click()
        return NewChannelPopup()

    @allure.step('Get presence state of create channel or category button')
    def does_create_channel_or_category_button_exist(self) -> bool:
        return self._channel_or_category_button.exists

    @allure.step('Get visibility state of add channels button')
    def is_add_channels_button_visible(self) -> bool:
        return self._add_channels_button.is_visible

    @allure.step('Get visibility state of add category button')
    def is_add_category_button_visible(self) -> bool:
        return self._create_category_button.is_visible

    @allure.step('Select channel')
    def select_channel(self, name: str):
        for obj in driver.findAllObjects(self._channel_list_item.real_name):
            if str(obj.objectName) == name:
                driver.mouseClick(obj)
                return obj
        raise LookupError('Channel not found')

    @allure.step('Open general channel context menu')
    def open_general_channel_context_menu(self):
        self._general_channel_item.right_click()
        return ContextMenu()

    @allure.step('Open category context menu')
    def open_category_context_menu(self):
        self._category_list_item.right_click()

    @allure.step('Open create category popup')
    def open_create_category_popup(self, attempts: int = 2) -> NewCategoryPopup:
        self._channel_or_category_button.click()
        try:
            self._create_category_menu_item.click()
            return NewCategoryPopup()
        except Exception as ex:
            if attempts:
                self.open_create_category_popup(attempts - 1)
            else:
                raise ex

    @allure.step('Open join community popup')
    def open_welcome_community_popup(self):
        self._join_community_button.click()
        return WelcomeCommunityPopup().wait_until_appears()

    @allure.step('Find category')
    def find_category_in_list(
            self, category_name: str, timeout_sec: int = configs.timeouts.MESSAGING_TIMEOUT_SEC):
        started_at = time.monotonic()
        category = None
        while category is None:
            categories = self.categories_items
            for _category in categories:
                if _category.category_name == category_name:
                    category = _category
            assert time.monotonic() - started_at < timeout_sec, f'Category: {category_name} not found in {categories}'
        return category

    def click_category(self, category_name: str):
        driver.mouseClick(self.find_category_in_list(category_name).object)

    @allure.step('Open more options')
    def open_more_options(self, attempts: int = 2):
        self._arrow_button.click()
        try:
            self._more_button.click()
        except LookupError as err:
            if attempts:
                return self._more_button.click(attempts - 1)
            else:
                raise err
        return self

    @allure.step('Get visibility state of delete item')
    def is_delete_item_visible(self) -> bool:
        return self._delete_category_item.is_visible

    @allure.step('Get visibility state of edit item')
    def is_edit_item_visible(self) -> bool:
        return self._edit_category_item.is_visible

    @allure.step('Open delete category popup')
    def open_delete_category_popup(self) -> DeleteCategoryPopup:
        self._delete_category_item.click()
        return DeleteCategoryPopup().wait_until_appears()

    @allure.step('Open edit category popup')
    def open_edit_category_popup(self) -> EditCategoryPopup:
        self._edit_category_item.click()
        return CategoryPopup().wait_until_appears()

    @allure.step('Open new channel popup inside category')
    def open_new_channel_popup_in_category(self) -> NewChannelPopup:
        self._arrow_button.click()
        self._add_channel_inside_category_item.click()
        return NewChannelPopup().wait_until_appears()

    @allure.step('Get channel or category index in the list')
    def get_channel_or_category_index(self, name: str) -> int:
        for child in walk_children(self._categories_items_list.object):
            if child.objectName == name:
                return child.visualIndex

    @allure.step('Right click on left panel')
    def right_click_on_panel(self):
        super(LeftPanel, self).right_click()


class Chat(QObject):

    def __init__(self):
        super().__init__(communities_names.mainWindow_ChatColumnView)
        self._channel_icon = QObject(
            communities_names.chatMessageViewDelegate_channelIdentifierSmartIdenticon_StatusSmartIdenticon)
        self._channel_name_label = TextLabel(
            communities_names.chatMessageViewDelegate_channelIdentifierNameText_StyledText)
        self._channel_welcome_label = TextLabel(communities_names.chatMessageViewDelegate_Welcome)
        self._channel_identifier_view = QObject(messaging_names.chatMessageViewDelegate_ChannelIdentifierView)

    @property
    @allure.step('Get channel emoji')
    def channel_emoji(self):
        return self._channel_identifier_view.object.chatEmoji

    @property
    @allure.step('Get channel color')
    def channel_color(self) -> str:
        return str(self._channel_identifier_view.object.chatColor).lower()

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
        super().__init__(communities_names.mainWindow_userListPanel_StatusListView)
        self._member_item = QObject(communities_names.userListPanel_StatusMemberListItem)
        self._user_badge_color = QObject(communities_names.statusBadge_StatusBadge)

    @property
    @allure.step('Get all members')
    def members(self) -> typing.List[str]:
        return [str(member.statusListItemTitle.text) for member in driver.findAllObjects(self._member_item.real_name)]

    @allure.step('Click member by name')
    def click_member(self, member_name: str):
        for member in driver.findAllObjects(self._member_item.real_name):
            if getattr(member, 'title', '') == member_name:
                driver.mouseClick(member)
                break
        return ProfilePopupFromMembers().wait_until_appears()

    @allure.step('Verify member is offline by index')
    def member_is_offline(self, index: int) -> bool:
        self._member_item.real_name['index'] = index
        return self._user_badge_color.object.color.name == ColorCodes.GRAY.value

    @allure.step('Verify member is online by index')
    def member_is_online(self, index: int) -> bool:
        self._member_item.real_name['index'] = index
        return self._user_badge_color.object.color.name == ColorCodes.GREEN.value
