import time
import typing

import allure

import configs.timeouts
import driver
from driver.objects_access import walk_children
from gui.components.settings.send_contact_request_popup import SendContactRequest

from gui.elements.button import Button
from gui.elements.list import List
from gui.screens.messages import MessagesScreen
from scripts.tools.image import Image
from gui.screens.settings import *


class MessagingSettingsView(QObject):

    def __init__(self):
        super().__init__('mainWindow_MessagingView')
        self._contacts_button = Button('contactsListItem_btn_StatusContactRequestsIndicatorListItem')

    @allure.step('Open contacts settings')
    def open_contacts_settings(self) -> 'ContactsSettingsView':
        self._contacts_button.click()
        return ContactsSettingsView().wait_until_appears()


class PendingRequest:

    def __init__(self, obj):
        self.object = obj
        self.icon: typing.Optional[Image] = None
        self.contact: typing.Optional[Image] = None
        self._accept_button: typing.Optional[Button] = None
        self._reject_button: typing.Optional[Button] = None
        self._open_canvas_button: typing.Optional[Button] = None
        self.init_ui()

    def __repr__(self):
        return self.contact

    def init_ui(self):
        for child in walk_children(self.object):
            if str(getattr(child, 'id', '')) == 'iconOrImage':
                self.icon = Image(driver.objectMap.realName(child))
            elif str(getattr(child, 'id', '')) == 'menuButton':
                self._open_canvas_button = Button(name='', real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'objectName', '')) == 'checkmark-circle-icon':
                self._accept_button = Button(name='', real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'objectName', '')) == 'close-circle-icon':
                self._reject_button = Button(name='', real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'id', '')) == 'statusListItemTitle':
                self.contact = str(child.text)

    def accept(self) -> MessagesScreen:
        assert self._accept_button is not None, 'Button not found'
        self._accept_button.click()
        return MessagesScreen().wait_until_appears()


class ContactsSettingsView(QObject):

    def __init__(self):
        super().__init__('mainWindow_ContactsView')
        self._contact_request_button = Button('mainWindow_Send_contact_request_to_chat_key_StatusButton')
        self._pending_request_tab = Button('contactsTabBar_Pending_Requests_StatusTabButton')
        self._pending_requests_list = List('settingsContentBaseScrollView_ContactListPanel')

    @property
    @allure.step('Get all pending requests')
    def pending_requests(self) -> typing.List[PendingRequest]:
        self._pending_request_tab.click()
        return [PendingRequest(item) for item in self._pending_requests_list.items]

    @allure.step('Open contacts request form')
    def open_contact_request_form(self) -> SendContactRequest:
        self._contact_request_button.click()
        return SendContactRequest().wait_until_appears()

    @allure.step('Open contacts request form')
    def send_contacts_request(self):
        LeftPanel().open_messaging_settings().open_contacts_settings().open_contact_request_form()

    @allure.step('Accept contact request')
    def accept_contact_request(
            self, contact: str, timeout_sec: int = configs.timeouts.MESSAGING_TIMEOUT_SEC) -> MessagesScreen:
        self._pending_request_tab.click()
        started_at = time.monotonic()
        request = None
        while request is None:
            requests = self.pending_requests
            for _request in requests:
                if _request.contact == contact:
                    request = _request
            assert time.monotonic() - started_at < timeout_sec, f'Contact: {contact} not found in {requests}'
        return request.accept()
