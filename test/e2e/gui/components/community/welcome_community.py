import allure

from gui.components.base_popup import BasePopup
from gui.components.authenticate_popup import AuthenticatePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names
from scripts.tools.image import Image


class WelcomeCommunityPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._title_text_label = TextLabel(names.headerTitle_StatusBaseText)
        self._community_icon = QObject(names.image_StatusImage)
        self._intro_text_label = TextLabel(names.intro_StatusBaseText)
        self._select_address_button = Button(names.select_addresses_to_share_StatusFlatButton)
        self._join_button = Button(names.join_StatusButton)
        self._authenticate_button = Button(names.welcome_authenticate_StatusButton)
        self._share_address_button = Button(names.share_your_addresses_to_join_StatusButton)

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
        self._authenticate_button.click()
        return AuthenticatePopup().wait_until_appears()

    def share_address(self):
        self._share_address_button.click()
