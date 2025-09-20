import time
import typing

import allure

import configs.timeouts
import driver
from driver.objects_access import walk_children
from helpers.chat_helper import skip_message_backup_popup_if_visible
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.objects_map import names, activity_center_names
from scripts.tools.image import Image


class ContactRequest:

    def __init__(self, obj):
        self.object = obj
        self.contact_request: typing.Optional[str] = None
        self.accept_button: typing.Optional[Button] = None
        self.decline_button: typing.Optional[Button] = None
        self.more_button: typing.Optional[Button] = None
        self.notification_request_state: typing.Optional[str] = None
        self.init_ui()

    def __repr__(self):
        return self.contact_request

    def init_ui(self):
        self.accept_button = Button(activity_center_names.activityCenterContactRequestAcceptButton)
        self.decline_button = Button(activity_center_names.activityCenterContactRequestDeclineButton)
        self.more_button = Button(activity_center_names.activityCenterContactRequestMoreButton)

        # get header text
        try:
            header_obj = QObject(activity_center_names.activityCenterContactRequestHeader)
            self.contact_request = str(header_obj.object.primaryText) if hasattr(header_obj.object,
                                                                                 'primaryText') else None
        except Exception:
            self.contact_request = None

        for child in walk_children(self.object):
            if str(getattr(child, 'id', '')) == 'textItem':
                self.notification_request_state = str(child.text)
                break

    @allure.step('Accept request')
    def accept(self):
        assert self.accept_button is not None, 'Button not found'
        self.accept_button.click()
        skip_message_backup_popup_if_visible()

    @allure.step('Decline request')
    def decline(self):
        assert self.decline_button is not None, 'Button not found'
        self.decline_button.click()


class ActivityCenter(QObject):

    def __init__(self):
        super().__init__(activity_center_names.activityCenterLeftPanel)
        self.activity_center_button = Scroll(names.activityCenterStatusFlatButton)
        self.activity_center_contact_request = QObject(activity_center_names.activityCenterContactRequest)
        self.scroll = Scroll(activity_center_names.activityCenterScrollView)
        self.navigation_button = Button(activity_center_names.activityCenterNavigationButton)

    @property
    @allure.step('Get contact items')
    def contact_items(self) -> typing.List[ContactRequest]:
        return [ContactRequest(item) for item in driver.findAllObjects(self.activity_center_contact_request.real_name)]

    # TODO: navigation buttons are the same so its hard to click a certain button

    @allure.step('Click activity center button')
    def click_activity_center_button(self, text: str):
        started_at = time.monotonic()
        self.activity_center_button.real_name['text'] = text

        while not self.activity_center_button.is_visible:
            if time.monotonic() - started_at > 5:
                raise TimeoutError(f'Activity center button with text "{text}" not found after {5} seconds')
            self.navigation_button.click()
        self.activity_center_button.click()
        return self

    @allure.step('Find contact request')
    def find_contact_request_in_list(
            self, contact: str, timeout_sec: int = configs.timeouts.MESSAGING_TIMEOUT_SEC):
        started_at = time.monotonic()
        while time.monotonic() - started_at < timeout_sec:
            requests = self.contact_items
            for _request in requests:
                if _request.contact_request == contact:
                    return _request
        raise TimeoutError(f'Timed out after {timeout_sec} seconds: Contact request "{contact}" not found.')

    @allure.step('Accept contact request')
    def accept_contact_request(self, request):
        return request.accept()
