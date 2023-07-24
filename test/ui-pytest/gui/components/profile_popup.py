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
    def user_name(self) -> str:
        return self._user_name_label.text

    @property
    def chat_key(self) -> str:
        return self._chat_key_text_label.text.split('https://status.app/u/')[1].strip()

    @property
    def emoji_hash(self) -> Image:
        return self._emoji_hash.image

    def is_user_image_contains(self, text: str):
        # To remove all artifacts, the image cropped.
        self._profile_image.image.crop(
            driver.UiTypes.ScreenRectangle(
                15, 15, self._profile_image.image.width-30, self._profile_image.image.height-30
            ))
        return self._profile_image.image.has_text(text, constants.tesseract.text_on_profile_image)
