import logging
import time
from abc import abstractmethod

import allure
import cv2

import configs.testpath
import constants.tesseract
import driver
from gui.components.os.open_file_dialogs import OpenFileDialog
from gui.components.profile_picture_popup import ProfilePicturePopup
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
from gui.elements.qt.text_edit import TextEdit
from gui.elements.qt.text_label import TextLabel
from scripts.tools.image import Image
from scripts.utils.system_path import SystemPath

_logger = logging.getLogger(__name__)


class AllowNotificationsView(QObject):

    def __init__(self):
        super(AllowNotificationsView, self).__init__('mainWindow_AllowNotificationsView')
        self._allow_button = Button('mainWindow_allowNotificationsOnboardingOkButton')

    @allure.step("Allow Notifications")
    def allow(self):
        self._allow_button.click()
        self.wait_until_hidden()


class WelcomeScreen(QObject):

    def __init__(self):
        super(WelcomeScreen, self).__init__('mainWindow_WelcomeView')
        self._new_user_button = Button('mainWindow_I_am_new_to_Status_StatusBaseText')
        self._existing_user_button = Button('mainWindow_I_already_use_Status_StatusBaseText')

    @allure.step('Open Keys view')
    def get_keys(self) -> 'KeysView':
        self._new_user_button.click()
        time.sleep(1)
        return KeysView().wait_until_appears()


class OnboardingScreen(QObject):

    def __init__(self, object_name):
        super(OnboardingScreen, self).__init__(object_name)
        self._back_button = Button('mainWindow_onboardingBackButton_StatusRoundButton')

    @abstractmethod
    def back(self):
        pass


class KeysView(OnboardingScreen):

    def __init__(self):
        super(KeysView, self).__init__('mainWindow_KeysMainView')
        self._generate_key_button = Button('mainWindow_Generate_new_keys_StatusButton')

    @allure.step('Open Profile view')
    def generate_new_keys(self) -> 'YourProfileView':
        self._generate_key_button.click()
        return YourProfileView().wait_until_appears()

    @allure.step('Go back')
    def back(self) -> WelcomeScreen:
        self._back_button.click()
        return WelcomeScreen().wait_until_appears()


class YourProfileView(OnboardingScreen):

    def __init__(self):
        super(YourProfileView, self).__init__('mainWindow_InsertDetailsView')
        self._upload_picture_button = Button('updatePicButton_StatusRoundButton')
        self._profile_image = QObject('mainWindow_CanvasItem')
        self._display_name_text_field = TextEdit('mainWindow_statusBaseInput_StatusBaseInput')
        self._erros_text_label = TextLabel('mainWindow_errorMessage_StatusBaseText')
        self._next_button = Button('mainWindow_Next_StatusButton')

    @property
    @allure.step('Get profile image')
    def profile_image(self) -> Image:
        return self._profile_image.image

    @property
    @allure.step('Get error messages')
    def error_message(self) -> str:
        return self._erros_text_label.text if self._erros_text_label.is_visible else ''

    @allure.step('Set user display name')
    def set_display_name(self, value: str):
        self._display_name_text_field.clear().text = value
        return self

    @allure.step('Set user image')
    def set_user_image(self, fp: SystemPath) -> ProfilePicturePopup:
        allure.attach(name='User image', body=fp.read_bytes(), attachment_type=allure.attachment_type.PNG)
        self._upload_picture_button.hover()
        self._upload_picture_button.click()
        file_dialog = OpenFileDialog().wait_until_appears()
        file_dialog.open_file(fp)
        return ProfilePicturePopup().wait_until_appears()

    @allure.step('Open Emoji and Icon view')
    def next(self) -> 'EmojiAndIconView':
        self._next_button.click()
        time.sleep(1)
        return EmojiAndIconView()

    @allure.step('Go back')
    def back(self):
        self._back_button.click()
        return KeysView().wait_until_appears()


class EmojiAndIconView(OnboardingScreen):

    def __init__(self):
        super(EmojiAndIconView, self).__init__('mainWindow_InsertDetailsView')
        self._profile_image = QObject('mainWindow_welcomeScreenUserProfileImage_StatusSmartIdenticon')
        self._chat_key_text_label = TextLabel('mainWindow_insertDetailsViewChatKeyTxt_StyledText')
        self._next_button = Button('mainWindow_Next_StatusButton')
        self._emoji_hash = QObject('mainWindow_EmojiHash')
        self._identicon_ring = QObject('mainWindow_userImageCopy_StatusSmartIdenticon')

    @property
    @allure.step('Get profile image icon')
    def profile_image(self) -> Image:
        self._profile_image.image.update_view()
        return self._profile_image.image

    @property
    @allure.step('Get profile image icon without identicon ring')
    def cropped_profile_image(self) -> Image:
        # Profile image without identicon_ring
        self._profile_image.image.update_view()
        self._profile_image.image.crop(
            driver.UiTypes.ScreenRectangle(
                20, 20, self._profile_image.image.width - 40, self._profile_image.image.height - 40
            ))
        return self._profile_image.image

    @property
    @allure.step('Get chat key')
    def chat_key(self) -> str:
        return self._chat_key_text_label.text.split(':')[1].strip()

    @property
    @allure.step('Get emoji hash image')
    def emoji_hash(self) -> Image:
        return self._emoji_hash.image

    @property
    @allure.step('Verify: Identicon ring visible')
    def is_identicon_ring_visible(self):
        return self._identicon_ring.is_visible

    @allure.step('Open Create password view')
    def next(self) -> 'CreatePasswordView':
        self._next_button.click()
        time.sleep(1)
        return CreatePasswordView().wait_until_appears()

    @allure.step('Go back')
    def back(self):
        self._back_button.click()
        return YourProfileView().wait_until_appears()

    @allure.step
    @allure.step('Verify: User image contains text')
    def is_user_image_contains(self, text: str):
        crop = driver.UiTypes.ScreenRectangle(
                20, 20, self._profile_image.image.width - 40, self._profile_image.image.height - 40
            )
        return self.profile_image.has_text(text, constants.tesseract.text_on_profile_image, crop=crop)

    @allure.step
    @allure.step('Verify: User image background color')
    def is_user_image_background_white(self):
        crop = driver.UiTypes.ScreenRectangle(
                20, 20, self._profile_image.image.width - 40, self._profile_image.image.height - 40
            )
        return self.profile_image.has_color(constants.Color.WHITE, crop=crop)


class CreatePasswordView(OnboardingScreen):

    def __init__(self):
        super(CreatePasswordView, self).__init__('mainWindow_CreatePasswordView')
        self._new_password_text_field = TextEdit('mainWindow_passwordViewNewPassword')
        self._confirm_password_text_field = TextEdit('mainWindow_passwordViewNewPasswordConfirm')
        self._create_button = Button('mainWindow_Create_password_StatusButton')

    @property
    @allure.step('Verify: Create password button enabled')
    def is_create_password_button_enabled(self) -> bool:
        # Verification is_enable can not be used
        # LookupError, because of "Enable: True" in object real name, if button disabled
        return self._create_button.is_visible

    @allure.step('Set password and open Confirmation password view')
    def create_password(self, value: str) -> 'ConfirmPasswordView':
        self._new_password_text_field.clear().text = value
        self._confirm_password_text_field.clear().text = value
        self._create_button.click()
        time.sleep(1)
        return ConfirmPasswordView().wait_until_appears()

    @allure.step('Go back')
    def back(self):
        self._back_button.click()
        return EmojiAndIconView().wait_until_appears()


class ConfirmPasswordView(OnboardingScreen):

    def __init__(self):
        super(ConfirmPasswordView, self).__init__('mainWindow_ConfirmPasswordView')
        self._confirm_password_text_field = TextEdit('mainWindow_confirmAgainPasswordInput')
        self._confirm_button = Button('mainWindow_Finalise_Status_Password_Creation_StatusButton')

    @allure.step('Confirm password')
    def confirm_password(self, value: str):
        self._confirm_password_text_field.text = value
        self._confirm_button.click()

    @allure.step('Go back')
    def back(self):
        self._back_button.click()
        return CreatePasswordView().wait_until_appears()


class TouchIDAuthView(OnboardingScreen):

    def __init__(self):
        super(TouchIDAuthView, self).__init__('mainWindow_TouchIDAuthView')
        self._prefer_password_button = Button('mainWindow_touchIdIPreferToUseMyPasswordText')

    @allure.step('Select prefer password')
    def prefer_password(self):
        self._prefer_password_button.click()
        self.wait_until_hidden()
