import allure
import pyperclip

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class ReceivePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self.account_selector_text = QObject(names.textContent_StatusBaseText)
        self.copy_button = Button(names.greenCircleAroundIcon_Rectangle)
        self.qr_code = QObject(names.qrCodeImage_Image)

    @allure.step('Get current text in account selector')
    def get_text_from_account_selector(self) -> str:
        return str(self.account_selector_text.object.text)

    @allure.step('Copy address')
    def copy_address(self) -> str:
        self.copy_button.click()
        return str(pyperclip.paste())

