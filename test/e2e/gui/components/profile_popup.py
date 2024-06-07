import allure
import pyperclip

import configs
import constants
import driver
from gui.components.base_popup import BasePopup
from gui.components.settings.send_contact_request_popup import SendContactRequestFromProfile
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names
from gui.screens.settings_profile import ProfileSettingsView


class ProfilePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._profile_popup_content_item = QObject(names.ProfileContentItem)
        self._profile_image = QObject(names.ProfileHeader_userImage)
        self._user_name_label = TextLabel(names.ProfilePopup_displayName)
        self._edit_profile_button = Button(names.ProfilePopup_editButton)
        self._chat_key_text_label = TextLabel(names.https_status_app_StatusBaseText)
        self._emoji_hash = QObject(names.profileDialog_userEmojiHash_EmojiHash)
        self._chat_key_copy_button = Button(names.copy_icon_CopyButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._profile_popup_content_item.wait_until_appears(timeout_msec)
        return self

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
                15, 15, self._profile_image.image.width - 30, self._profile_image.image.height - 30
            ))
        return self._profile_image.image

    @property
    @allure.step('Get user name')
    def user_name(self) -> str:
        return self._user_name_label.text

    @property
    @allure.step('Get chat key')
    def get_chat_key_from_profile_link(self) -> str:
        chat_key = self._chat_key_text_label.text.split('https://status.app/u/')[1].strip()
        if '#' in chat_key:
            chat_key = chat_key.split('#')[1]
        return chat_key

    @property
    @allure.step('Get emoji hash image')
    def get_emoji_hash(self) -> str:
        return str(getattr(self._emoji_hash.object, 'publicKey'))

    @property
    @allure.step('Copy chat key')
    def copy_chat_key(self) -> str:
        self._chat_key_copy_button.click()
        return pyperclip.paste()

    @allure.step('Verify: user image contains text')
    def is_user_image_contains(self, text: str):
        # To remove all artifacts, the image cropped.
        crop = driver.UiTypes.ScreenRectangle(
            15, 15, self._profile_image.image.width - 30, self._profile_image.image.height - 30
        )
        return self.profile_image.has_text(text, constants.tesseract.text_on_profile_image, crop=crop)

    @allure.step('Click edit profile button')
    def edit_profile(self):
        self._edit_profile_button.click()
        return ProfileSettingsView()

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._emoji_hash.wait_until_appears(timeout_msec)
        return self


class ProfilePopupFromMembers(ProfilePopup):

    def __init__(self):
        super(ProfilePopupFromMembers, self).__init__()
        self._send_request_button = Button(names.send_contact_request_StatusButton)
        self._request_id_request_button = Button(names.request_ID_verification_StatusFlatButton)

    @allure.step('Click send request button')
    def send_request(self):
        self._send_request_button.click()
        return SendContactRequestFromProfile().wait_until_appears()

    @allure.step('Get request id button visibility state')
    def is_request_id_button_visible(self):
        return self._request_id_request_button.is_visible
