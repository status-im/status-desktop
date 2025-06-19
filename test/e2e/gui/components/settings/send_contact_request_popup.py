import time

import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class SendContactRequest(BasePopup):

    def __init__(self):
        super().__init__()
        self._chat_key_text_edit = TextEdit(names.sendContactRequestModal_ChatKey_Input_TextEdit)
        self._message_text_edit = TextEdit(names.sendContactRequestModal_SayWhoYouAre_Input_TextEdit)
        self._send_button = Button(names.send_Contact_Request_StatusButton)

    @allure.step('Send contact request')
    def send(self, chat_key: str, message: str):
        self._chat_key_text_edit.text = chat_key
        self._message_text_edit.text = message
        self._send_button.click()
        self.wait_until_hidden()


class SendContactRequestFromProfile(BasePopup):

    def __init__(self):
        super().__init__()
        self._message_text_edit = TextEdit(names.profileSendContactRequestModal_sayWhoYouAreInput_TextEdit)
        self._send_button = Button(names.send_contact_request_StatusButton_2)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._message_text_edit.wait_until_appears(timeout_msec)
        return self

    @allure.step('Send contact request')
    def send(self, message: str):
        self._message_text_edit.text = message
        self._send_button.click()
