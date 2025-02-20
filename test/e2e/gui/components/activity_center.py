import time
import typing

import allure

import configs.timeouts
import driver
from driver.objects_access import walk_children
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.list import List
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.objects_map import names
from scripts.tools.image import Image


class ContactRequest:

    def __init__(self, obj):
        self.object = obj
        self.contact_request: typing.Optional[Image] = None
        self._accept_button: typing.Optional[Button] = None
        self._decline_button: typing.Optional[Button] = None
        self._notification_request_state: typing.Optional[Image] = None
        self.init_ui()

    def __repr__(self):
        return self.contact_request

    def init_ui(self):
        for child in walk_children(self.object):
            if str(getattr(child, 'objectName', '')) == 'acceptBtn':
                self._accept_button = Button(real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'objectName', '')) == 'declineBtn':
                self._decline_button = Button(real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'objectName', '')) == 'StatusMessageHeader_DisplayName':
                self.contact_request = str(child.text)
            elif str(getattr(child, 'id', '')) == 'textItem':
                self._notification_request_state = str(child.text)

    @allure.step('Accept request')
    def accept(self):
        assert self._accept_button is not None, 'Button not found'
        self._accept_button.click()

    @allure.step('Decline request')
    def decline(self):
        assert self._decline_button is not None, 'Button not found'
        self._decline_button.click()


class ActivityCenter(BasePopup):

    def __init__(self):
        super(ActivityCenter, self).__init__()
        self._activity_center_button = Scroll(names.activityCenterStatusFlatButton)
        self._notification_contact_request = QObject(names.o_ActivityNotificationContactRequest)
        self._activity_center_panel = QObject(names.activityCenterTopBar_ActivityCenterPopupTopBarPanel)
        self._contact_request_list = List(names.statusListView)

    @property
    @allure.step('Get contact items')
    def contact_items(self) -> typing.List[ContactRequest]:
        return [ContactRequest(item) for item in self._contact_request_list.items]

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._activity_center_panel.wait_until_appears(timeout_msec)
        return self

    @allure.step('Click activity center button')
    def click_activity_center_button(self, text: str):
        for button in driver.findAllObjects(self._activity_center_button.real_name):
            if str(getattr(button, 'text', '')) == str(text):
                driver.mouseClick(button)
                break
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
