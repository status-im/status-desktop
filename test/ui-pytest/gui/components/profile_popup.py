import allure

import constants
import driver
from gui.components.base_popup import BasePopup
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
from gui.elements.qt.text_label import TextLabel
from scripts.tools.image import Image


class ProfilePopup(BasePopup):

    def __init__(self):
        super(ProfilePopup, self).__init__()
        self._profile_image = QObject('ProfileHeader_userImage')
        self._user_name_label = TextLabel('ProfilePopup_displayName')
        self._edit_profile_button = Button('ProfilePopup_editButton')
        self._chat_key_text_label = TextLabel('https_status_app_StatusBaseText')
        self._emoji_hash = QObject('profileDialog_userEmojiHash_EmojiHash')

    @property
    @allure.step('Get profile image')
    def profile_image(self):
        return self._profile_image.image

    @property
    @allure.step('Get image without identicon_ring')
    def cropped_profile_image(self):
        # Profile image without identicon_ring
        self._profile_image.image.update_view()
        self._profile_image.image.crop(
            driver.UiTypes.ScreenRectangle(
                15, 15, self._profile_image.image.width-30, self._profile_image.image.height-30
            ))
        return self._profile_image.image

    @property
    @allure.step('Get user name')
    def user_name(self) -> str:
        return self._user_name_label.text

    @property
    @allure.step('Get chat key')
    def chat_key(self) -> str:
        chat_key = self._chat_key_text_label.text.split('https://status.app/u/')[1].strip()
        if '#' in chat_key:
            chat_key = chat_key.split('#')[1]
        return chat_key

    @property
    @allure.step('Get emoji hash image')
    def emoji_hash(self) -> Image:
        return self._emoji_hash.image

    @allure.step('Verify: user image contains text')
    def is_user_image_contains(self, text: str):
        # To remove all artifacts, the image cropped.
        crop = driver.UiTypes.ScreenRectangle(
            15, 15, self._profile_image.image.width - 30, self._profile_image.image.height - 30
        )
        return self.profile_image.has_text(text, constants.tesseract.text_on_profile_image, crop=crop)
