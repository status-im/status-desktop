import time
import typing

import allure

import configs
import driver
from driver.objects_access import walk_children
from gui.elements.qt.button import Button
from gui.elements.qt.list import List
from gui.elements.qt.object import QObject
from gui.elements.qt.scroll import Scroll
from gui.elements.qt.text_edit import TextEdit
from gui.screens.community import CommunityScreen
from scripts.tools.image import Image


class LeftPanel(QObject):

    def __init__(self):
        super().__init__('mainWindow_contactColumnLoader_Loader')
        self._start_chat_button = Button('mainWindow_startChatButton_StatusIconTabButton')
        self._search_text_edit = TextEdit('mainWindow_search_edit_TextEdit')
        self._scroll = Scroll('scrollView_Flickable')
        self._contacts_list = List('chatList_ListView')

    @property
    @allure.step('Get contacts')
    def contacts(self) -> typing.List[str]:
        return self._contacts_list.get_values('objectName')

    @allure.step('Open chat')
    def open_chat(self, contact: str):
        assert driver.waitFor(lambda: contact in self.contacts), f'Contact: {contact} not found in {self.contacts}'
        self._contacts_list.select(contact, 'objectName')
        return ChatView()


class ToolBar(QObject):

    def __init__(self):
        super().__init__('mainWindow_statusToolBar_StatusToolBar')


class Message:

    def __init__(self, obj):
        self.object = obj
        self.date: typing.Optional[str] = None
        self.time: typing.Optional[str] = None
        self.icon: typing.Optional[Image] = None
        self.from_user: typing.Optional[str] = None
        self.text: typing.Optional[str] = None
        self._join_community_button: typing.Optional[Button] = None
        self.community_invitation: dict = {}
        self.init_ui()

    def init_ui(self):
        for child in walk_children(self.object):
            if getattr(child, 'objectName', '') == 'StatusDateGroupLabel':
                self.date = str(child.text)
            elif getattr(child, 'objectName', '') == 'communityName':
                self.community_invitation['name'] = str(child.text)
            elif getattr(child, 'objectName', '') == 'communityDescription':
                self.community_invitation['description'] = str(child.text)
            elif getattr(child, 'objectName', '') == 'communityMembers':
                self.community_invitation['members'] = str(child.text)
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
                    case 'joinBtn':
                        self._join_community_button = Button(name='', real_name=driver.objectMap.realName(child))

    @allure.step('Join community')
    def join_community(self):
        assert self._join_community_button is not None, 'Join button not found'
        self._join_community_button.click()
        return CommunityScreen().wait_until_appears()


class ChatView(QObject):

    def __init__(self):
        super().__init__('mainWindow_ChatColumnView')
        self._message_list_item = QObject('chatLogView_chatMessageViewDelegate_MessageView')

    @property
    @allure.step('Get messages')
    def messages(self) -> typing.List[Message]:
        _messages = []
        for item in driver.findAllObjects(self._message_list_item.real_name):
            if getattr(item, 'isMessage', False):
                _messages.append(Message(item))
        return _messages

    @allure.step('Accept community invitation')
    def accept_community_invite(self, community: str) -> 'CommunityScreen':
        message = None
        started_at = time.monotonic()
        while message is None:
            for _message in self.messages:
                if _message.community_invitation.get('name', '') == community:
                    message = _message
                    break
            if time.monotonic() - started_at > configs.timeouts.MESSAGING_TIMEOUT_SEC:
                raise LookupError(f'Invitation not found')

        return message.join_community()


class MessagesScreen(QObject):

    def __init__(self):
        super().__init__('mainWindow_chatView_ChatView')
        self.left_panel = LeftPanel()
        self.tool_bar = ToolBar()
        self.chat = ChatView()
