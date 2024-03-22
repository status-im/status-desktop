import time
import typing
from typing import List

import allure

import configs
import driver
from driver.objects_access import walk_children
from gui.components.activity_center import ActivityCenter
from gui.components.context_menu import ContextMenu
from gui.components.delete_popup import DeleteMessagePopup
from gui.components.emoji_popup import EmojiPopup
from gui.components.messaging.edit_group_name_and_image_popup import EditGroupNameAndImagePopup
from gui.components.messaging.leave_group_popup import LeaveGroupPopup
from gui.elements.button import Button
from gui.elements.list import List
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import messaging_names, communities_names
from gui.screens.community import CommunityScreen
from scripts.tools.image import Image


class LeftPanel(QObject):

    def __init__(self):
        super().__init__(messaging_names.mainWindow_contactColumnLoader_Loader)
        self._start_chat_button = Button(messaging_names.mainWindow_startChatButton_StatusIconTabButton)
        self._search_text_edit = TextEdit(messaging_names.mainWindow_search_edit_TextEdit)
        self._scroll = Scroll(messaging_names.scrollView_Flickable)
        self._contacts_list = List(messaging_names.chatList_ListView)
        self._contact_item = QObject(messaging_names.scrollView_StatusChatListItem)

    @property
    @allure.step('Get contacts')
    def contacts(self) -> typing.List[str]:
        return self._contacts_list.get_values('objectName')

    @allure.step('Open chat')
    def open_chat(self, contact: str):
        assert driver.waitFor(lambda: contact in self.contacts), f'Contact: {contact} not found in {self.contacts}'
        self._contacts_list.select(contact, 'objectName')
        return ChatView()

    @allure.step('Click start chat button')
    def start_chat(self):
        self._start_chat_button.click(x=1, y=1)
        return CreateChatView()

    @allure.step('Open context menu group chat')
    def _open_context_menu_for_chat(self, chat_name: str) -> ContextMenu:
        self._contact_item.real_name['objectName'] = chat_name
        self._contact_item.right_click()
        return ContextMenu().wait_until_appears()

    @allure.step('Open leave popup')
    def open_leave_group_popup(self, chat_name: str, attempt: int = 2) -> LeaveGroupPopup:
        try:
            self._open_context_menu_for_chat(chat_name).select('Leave group')
            return LeaveGroupPopup().wait_until_appears()
        except Exception as ex:
            if attempt:
                return self.open_leave_group_popup(chat_name, attempt - 1)
            else:
                raise ex


class ToolBar(QObject):

    def __init__(self):
        super().__init__(messaging_names.mainWindow_statusToolBar_StatusToolBar)
        self.pinned_message_tooltip = QObject(
            communities_names.statusToolBar_StatusChatInfo_pinText_TruncatedTextWithTooltip)
        self.confirm_button = Button(messaging_names.statusToolBar_Confirm_StatusButton)
        self.status_button = Button(messaging_names.statusToolBar_Cancel_StatusButton)
        self.contact_tag = QObject(messaging_names.statusToolBar_StatusTagItem)
        self.notifications_button = Button(messaging_names.statusToolBar_notificationButton_StatusActivityCenterButton)

    @property
    @allure.step('Get visibility of pin message tooltip')
    def is_pin_message_tooltip_visible(self) -> bool:
        return self.pinned_message_tooltip.is_visible

    @allure.step('Confirm action in toolbar')
    def confirm_action_in_toolbar(self):
        self.confirm_button.click()

    @allure.step('Remove member by clicking close icon on member tag')
    def click_contact_close_icon(self, member):
        for item in driver.findAllObjects(self.contact_tag.real_name):
            if str(getattr(item, 'text', '')) == str(member):
                for child in walk_children(item):
                    if getattr(child, 'objectName', '') == 'close-icon':
                        driver.mouseClick(child)
                        break

    @allure.step('Open activity center')
    def open_activity_center(self):
        self.notifications_button.click()
        return ActivityCenter().wait_until_appears()


class Message:

    def __init__(self, obj):
        self.object = obj
        self.date: typing.Optional[str] = None
        self.time: typing.Optional[str] = None
        self.icon: typing.Optional[Image] = None
        self.from_user: typing.Optional[str] = None
        self.text: typing.Optional[str] = None
        self.delegate_button: typing.Optional[Button] = None
        self.community_invitation: dict = {}
        self.init_ui()

    def init_ui(self):
        for child in walk_children(self.object):
            if getattr(child, 'objectName', '') == 'StatusDateGroupLabel':
                self.date = str(child.text)
            elif getattr(child, 'id', '') == 'title':
                self.community_invitation['name'] = str(child.text)
            elif getattr(child, 'id', '') == 'description':
                self.community_invitation['description'] = str(child.text)
            else:
                match getattr(child, 'id', ''):
                    case 'profileImage':
                        self.icon = Image(driver.objectMap.realName(child))
                    case 'primaryDisplayName':
                        self.from_user = str(child.text)
                    case 'timestampText':
                        self.time = str(child.text)
                    case 'chatText':
                        self.text = str(child.text)
                    case 'delegate':
                        self.delegate_button = Button(real_name=driver.objectMap.realName(child))

    @allure.step('Open community invitation')
    def open_community_invitation(self):
        driver.waitFor(lambda: self.delegate_button.is_visible, configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        self.delegate_button.click()
        return CommunityScreen().wait_until_appears()

    @allure.step('Hover message')
    def hover_message(self):
        self.delegate_button.hover()
        return MessageQuickActions()

    @allure.step('Get color of message background')
    def get_message_color(self) -> str:
        return self.delegate_button.object.background.color.name

    @property
    @allure.step('Get user name in pinned message details')
    def user_name_in_pinned_message(self) -> str:
        return str(self.delegate_button.object.pinnedBy)

    @property
    @allure.step('Get info text in pinned message details')
    def pinned_info_text(self) -> str:
        return str(self.delegate_button.object.pinnedMsgInfoText)

    @property
    @allure.step('Get message pinned state')
    def message_is_pinned(self) -> bool:
        return self.delegate_button.object.isPinned


class ChatView(QObject):

    def __init__(self):
        super().__init__(messaging_names.mainWindow_ChatColumnView)
        self._message_list_item = QObject(messaging_names.chatLogView_chatMessageViewDelegate_MessageView)

    @allure.step('Get messages')
    def messages(self, index: int) -> typing.List[Message]:
        _messages = []
        time.sleep(1)
        # message_list_item has different indexes if we run multiple instances, so we pass index
        self._message_list_item.real_name['index'] = index
        for item in driver.findAllObjects(self._message_list_item.real_name):
            if getattr(item, 'isMessage', False):
                _messages.append(Message(item))
        return _messages

    def find_message_by_text(self, message_text: str, index: int):
        message = None
        started_at = time.monotonic()
        while message is None:
            for _message in self.messages(index):
                if message_text in _message.text:
                    message = _message
                    break
            if time.monotonic() - started_at > configs.timeouts.MESSAGING_TIMEOUT_SEC:
                raise LookupError(f'Message not found')
        return message

    @allure.step('Accept community invitation')
    def accept_community_invite(self, community: str, index: bool) -> 'CommunityScreen':
        message = None
        started_at = time.monotonic()
        while message is None:
            for _message in self.messages(index):
                if _message.community_invitation.get('name', '') == community:
                    message = _message
                    break
            if time.monotonic() - started_at > configs.timeouts.MESSAGING_TIMEOUT_SEC:
                raise LookupError(f'Invitation not found')

        return message.open_community_invitation()


class CreateChatView(QObject):

    def __init__(self):
        super().__init__(messaging_names.mainWindow_CreateChatView)
        self._confirm_button = Button(messaging_names.createChatView_confirmBtn)
        self._cancel_button = Button(messaging_names.mainWindow_Cancel_StatusButton)
        self._create_chat_contacts_list = List(messaging_names.createChatView_contactsList)

    @property
    @allure.step('Get contacts')
    def contacts(self) -> typing.List[str]:
        return self._create_chat_contacts_list.get_values('title')

    @allure.step('Select contact in the list')
    def select_contact(self, contact: str):
        assert driver.waitFor(lambda: contact in self.contacts), f'Contact: {contact} not found in {self.contacts}'
        self._create_chat_contacts_list.select(contact, 'title')

    @allure.step('Create chat by adding contacts from contact list')
    def create_chat(self, members):
        for member in members[0:]:
            time.sleep(0.2)
            self.select_contact(member)
        self._confirm_button.click()
        return ChatMessagesView().wait_until_appears()


class ChatMessagesView(QObject):

    def __init__(self):
        super().__init__(messaging_names.mainWindow_ChatMessagesView)
        self._group_chat_message_item = TextLabel(messaging_names.chatLogView_Item)
        self._group_name_label = TextLabel(messaging_names.statusChatInfoButton)
        self._more_button = Button(messaging_names.moreOptionsButton_StatusFlatRoundButton)
        self._edit_menu_item = QObject(messaging_names.edit_name_and_image_StatusMenuItem)
        self._leave_group_item = QObject(messaging_names.leave_group_StatusMenuItem)
        self._add_remove_item = QObject(messaging_names.add_remove_from_group_StatusMenuItem)
        self._message_input_area = QObject(messaging_names.inputScrollView_messageInputField_TextArea)
        self._message_field = TextEdit(messaging_names.inputScrollView_Message_PlaceholderText)
        self._emoji_button = Button(messaging_names.mainWindow_statusChatInputEmojiButton_StatusFlatRoundButton)

    @property
    @allure.step('Get group name')
    def group_name(self) -> str:
        return self._group_name_label.text

    @property
    @allure.step('Get group welcome message')
    def group_welcome_message(self) -> str:
        for delegate in walk_children(self._group_chat_message_item.object):
            if getattr(delegate, 'id', '') == 'msgDelegate':
                for item in walk_children(delegate):
                    if getattr(item, 'id', '') == 'descText':
                        return str(item.text)

    @property
    @allure.step('Get gray text from message area')
    def gray_text_from_message_area(self) -> str:
        return driver.waitForObjectExists(self._message_input_area.real_name,
                                          configs.timeouts.UI_LOAD_TIMEOUT_MSEC).placeholderText

    @property
    @allure.step('Get enabled state of message area')
    def is_message_area_enabled(self) -> bool:
        return driver.waitForObjectExists(self._message_input_area.real_name,
                                          configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled

    @allure.step('Click more options button')
    def open_more_options(self):
        self._more_button.click()

    @allure.step('Choose edit group name option')
    def open_edit_group_name_form(self):
        time.sleep(2)
        self.open_more_options()
        time.sleep(2)
        self._edit_menu_item.click()
        return EditGroupNameAndImagePopup().wait_until_appears()

    @allure.step('Choose leave group option')
    def leave_group(self):
        time.sleep(2)
        self.open_more_options()
        time.sleep(2)
        self._leave_group_item.click()
        return LeaveGroupPopup().wait_until_appears()

    @allure.step('Send message to group chat')
    def send_message_to_group_chat(self, message: str):
        self._message_field.type_text(message)
        for i in range(2):
            driver.nativeType('<Return>')

    @allure.step('Send emoji to chat')
    def send_emoji_to_chat(self, emoji: str):
        self._emoji_button.click()
        EmojiPopup().wait_until_appears().select(emoji)
        for i in range(2):
            driver.nativeType('<Return>')

    @allure.step('Remove member from chat')
    def remove_member_from_chat(self, member):
        time.sleep(2)
        self.open_more_options()
        time.sleep(2)
        self._add_remove_item.click()
        tool_bar = ToolBar().wait_until_appears()
        tool_bar.click_contact_close_icon(member)
        time.sleep(1)
        tool_bar.confirm_action_in_toolbar()
        time.sleep(1)


class MessageQuickActions(QObject):
    def __init__(self):
        super().__init__(messaging_names.chatMessageViewDelegate_StatusMessageQuickActions)
        self._pin_button = Button(
            messaging_names.chatMessageViewDelegate_MessageView_toggleMessagePin_StatusFlatRoundButton)
        self._edit_button = Button(messaging_names.chatMessageViewDelegate_editMessageButton_StatusFlatRoundButton)
        self._delete_button = Button(
            messaging_names.chatMessageViewDelegate_chatDeleteMessageButton_StatusFlatRoundButton)
        self._edit_message_field = TextEdit(messaging_names.edit_inputScrollView_messageInputField_TextArea)
        self._save_text_button = Button(messaging_names.chatMessageViewDelegate_Save_StatusButton)

    @allure.step('Toggle pin button')
    def toggle_pin(self):
        self._pin_button.click()

    @allure.step('Edit message and save changes')
    def edit_message(self, text: str):
        self._edit_button.click()
        self._edit_message_field.type_text(text)
        self._save_text_button.click()

    @allure.step('Delete message')
    def delete_message(self):
        self._delete_button.click()
        DeleteMessagePopup().delete()

    @allure.step('Delete button is visible')
    def is_delete_button_visible(self) -> bool:
        return self._delete_button.is_visible


class Members(QObject):

    def __init__(self):
        super().__init__(messaging_names.mainWindow_userListPanel_StatusListView)
        self._member_item = QObject(messaging_names.groupUserListPanel_StatusMemberListItem)

    @property
    @allure.step('Get group members')
    def members(self) -> typing.List[str]:
        return [str(member.title) for member in driver.findAllObjects(self._member_item.real_name)]


class MessagesScreen(QObject):

    def __init__(self):
        super().__init__(messaging_names.mainWindow_chatView_ChatView)
        self.left_panel = LeftPanel()
        self.tool_bar = ToolBar()
        self.chat = ChatView()
        self.right_panel = Members()
        self.group_chat = ChatMessagesView()
