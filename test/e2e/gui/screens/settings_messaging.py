import time
import typing

import allure

import configs.timeouts
import driver
from driver.objects_access import walk_children
from gui.components.settings.respond_to_id_request_popup import RespondToIDRequestPopup
from gui.components.settings.send_contact_request_popup import SendContactRequest
from gui.components.settings.verify_identity_popup import VerifyIdentityPopup

from gui.elements.button import Button
from gui.elements.list import List
from gui.screens.messages import MessagesScreen
from scripts.tools.image import Image
from gui.screens.settings import *


class MessagingSettingsView(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_MessagingView)
        self._contacts_button = Button(names.contactsListItem_btn_StatusContactRequestsIndicatorListItem)
        self._always_ask_button = Button(names.always_ask_radioButton_StatusRadioButton)
        self._always_show_button = Button(names.always_show_radioButton_StatusRadioButton)
        self._never_ask_button = Button(names.never_show_radioButton_StatusRadioButton)

    @allure.step('Open contacts settings')
    def open_contacts_settings(self) -> 'ContactsSettingsView':
        self._contacts_button.click()
        return ContactsSettingsView()

    @allure.step('Choose always show previews from website links preview options')
    def click_always_show(self):
        self._always_show_button.click()


class ContactItem:

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
                self._open_canvas_button = Button(real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'objectName', '')) == 'checkmark-circle-icon':
                self._accept_button = Button(real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'objectName', '')) == 'close-circle-icon':
                self._reject_button = Button(real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'id', '')) == 'statusListItemTitle':
                self.contact = str(child.text)
            elif str(getattr(child, 'objectName', '')) == 'chat-icon':
                self._chat_button = Button(real_name=driver.objectMap.realName(child))

    @allure.step('Accept request')
    def accept(self) -> MessagesScreen:
        assert self._accept_button is not None, 'Button not found'
        self._accept_button.click()
        return MessagesScreen().wait_until_appears()

    @allure.step('Reject request')
    def reject(self):
        assert self._reject_button is not None, 'Button not found'
        self._reject_button.click()

    @allure.step('Open more options popup')
    def open_more_options_popup(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC, attempt: int = 2):
        try:
            self._open_canvas_button.click()
            driver.waitFor(lambda: ContactsSettingsView()._view_profile_item.is_visible, timeout_msec)
            return self
        except:
            if attempt:
                self._open_canvas_button.click(attempt - 1)
                return self
            else:
                raise LookupError(f"Popup didn't appear")


class ContactsSettingsView(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_ContactsView)
        self._contact_request_button = Button(names.mainWindow_Send_contact_request_to_chat_key_StatusButton)
        self._pending_request_tab = Button(names.contactsTabBar_Pending_Requests_StatusTabButton)
        self._contacts_tab = Button(names.contactsTabBar_Contacts_StatusTabButton)
        self._contacts_items_list = List(names.settingsContentBaseScrollView_ContactListPanel)
        self._pending_request_sent_panel = QObject(names.settingsContentBaseScrollView_sentRequests_ContactsListPanel)
        self._pending_request_received_panel = QObject(
            names.settingsContentBaseScrollView_receivedRequests_ContactsListPanel)
        self._contacts_panel = QObject(names.settingsContentBaseScrollView_mutualContacts_ContactsListPanel)
        self._invite_friends_button = QObject(names.settingsContentBaseScrollView_Invite_friends_StatusButton)
        self._no_friends_item = QObject(names.settingsContentBaseScrollView_NoFriendsRectangle)
        # more options on contact
        self._verify_identity_item = QObject(names.verify_Identity_StatusMenuItem)
        self._respond_to_id_request_item = QObject(names.respond_to_ID_Request_StatusMenuItem)
        self._view_profile_item = QObject(names.view_Profile_StatusMenuItem)
        self._respond_to_id_request_button = Button(
            names.settingsContentBaseScrollView_Respond_to_ID_Request_StatusFlatButton)

    @property
    @allure.step('Get contact items')
    def contact_items(self) -> typing.List[ContactItem]:
        try:
            contact_items = []
            for i in range(2):
                contact_items = [ContactItem(item) for item in self._contacts_items_list.items]
            if len(contact_items) != 0:
                return contact_items
        except LookupError as err:
            raise err

    @property
    @allure.step('Get title of list with sent pending requests')
    def pending_request_sent_list_title(self) -> str:
        return self._pending_request_sent_panel.object.title

    @property
    @allure.step('Get title of list with received pending requests')
    def pending_request_received_list_title(self) -> str:
        return self._pending_request_received_panel.object.title

    @property
    @allure.step('Get title of list with contacts')
    def contacts_list_title(self) -> str:
        return self._contacts_panel.object.title

    @property
    @allure.step('Get title of no friends item')
    def no_friends_item_text(self) -> str:
        return self._no_friends_item.object.text

    @property
    @allure.step('Get state of invite friends button')
    def is_invite_friends_button_visible(self) -> bool:
        return self._invite_friends_button.is_visible

    @allure.step('Open pending requests tab')
    def open_pending_requests(self):
        self._pending_request_tab.click()
        return self

    @allure.step('Open contacts tab')
    def open_contacts(self):
        self._contacts_tab.click()
        return self

    @allure.step('Open contacts request form')
    def open_contact_request_form(self) -> SendContactRequest:
        self._contact_request_button.click()
        return SendContactRequest().wait_until_appears()

    @allure.step('Open contacts request form')
    def send_contacts_request(self):
        LeftPanel().open_messaging_settings().open_contacts_settings().open_contact_request_form()

    @allure.step('Accept contact request')
    def find_contact_in_list(
            self, contact: str, timeout_sec: int = configs.timeouts.MESSAGING_TIMEOUT_SEC):
        started_at = time.monotonic()
        request = None
        while request is None:
            requests = self.contact_items
            for _request in requests:
                if _request.contact == contact:
                    request = _request
            assert time.monotonic() - started_at < timeout_sec, f'Contact: {contact} not found in {requests}'
        return request

    @allure.step('Accept contact request')
    def accept_contact_request(self, contact: str,
                               timeout_sec: int = configs.timeouts.MESSAGING_TIMEOUT_SEC) -> MessagesScreen:
        self.open_pending_requests()
        request = self.find_contact_in_list(contact, timeout_sec)
        return request.accept()

    @allure.step('Reject contact request')
    def reject_contact_request(
            self, contact: str, timeout_sec: int = configs.timeouts.MESSAGING_TIMEOUT_SEC):
        self.open_pending_requests()
        request = self.find_contact_in_list(contact, timeout_sec)
        request.reject()

    @allure.step('Open verify identity popup')
    def open_more_options_popup(
            self, contact: str, timeout_sec: int = configs.timeouts.MESSAGING_TIMEOUT_SEC):
        request = self.find_contact_in_list(contact, timeout_sec)
        request.open_more_options_popup()
        return self

    def verify_identity(self):
        self._verify_identity_item.click()
        return VerifyIdentityPopup().wait_until_appears()

    def is_respond_to_id_request_visible(self) -> bool:
        return self._respond_to_id_request_item.is_visible

    def respond_to_id_request(self):
        self._respond_to_id_request_item.click()
        return RespondToIDRequestPopup().wait_until_appears()
