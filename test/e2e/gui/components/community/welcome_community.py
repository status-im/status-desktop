import allure

from gui.components.base_popup import BasePopup
from gui.components.community.authenticate_popup import AuthenticatePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from scripts.tools.image import Image


class WelcomeCommunityPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._title_text_label = TextLabel('headerTitle_StatusBaseText')
        self._community_icon = QObject('image_StatusImage')
        self._intro_text_label = TextLabel('intro_StatusBaseText')
        self._select_address_button = Button('select_addresses_to_share_StatusFlatButton')
        self._join_button = Button('join_StatusButton')

    @property
    @allure.step('Get title')
    def title(self) -> str:
        return self._title_text_label.text

    @property
    @allure.step('Get community icon')
    def community_icon(self) -> Image:
        return self._community_icon.image

    @property
    @allure.step('Get community intro')
    def intro(self) -> str:
        return self._intro_text_label.text

    @allure.step('Join community')
    def join(self) -> AuthenticatePopup:
        self._join_button.click()
        return AuthenticatePopup().wait_until_appears()
