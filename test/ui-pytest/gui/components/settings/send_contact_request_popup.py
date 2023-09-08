import allure

from gui.components.base_popup import BasePopup
from gui.elements.qt.button import Button
from gui.elements.qt.text_edit import TextEdit


class SendContactRequest(BasePopup):

    def __init__(self):
        super().__init__()
        self._chat_key_text_edit = TextEdit('sendContactRequestModal_ChatKey_Input_TextEdit')
        self._message_text_edit = TextEdit('sendContactRequestModal_SayWhoYouAre_Input_TextEdit')
        self._send_button = Button('send_Contact_Request_StatusButton')

    @allure.step('Send contact request')
    def send(self, chat_key: str, message: str):
        self._chat_key_text_edit.text = chat_key
        self._message_text_edit.text = message
        self._send_button.click()
        self.wait_until_hidden()
