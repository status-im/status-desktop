import logging
import time
import typing
from abc import abstractmethod

import allure

import configs
import constants.tesseract
import driver
from gui.components.os.open_file_dialogs import OpenFileDialog
from gui.components.picture_edit_popup import PictureEditPopup
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


class WelcomeView(QObject):

    def __init__(self):
        super(WelcomeView, self).__init__('mainWindow_WelcomeView')
        self._new_user_button = Button('mainWindow_I_am_new_to_Status_StatusBaseText')
        self._existing_user_button = Button('mainWindow_I_already_use_Status_StatusBaseText')

    @allure.step('Open Keys view')
    def get_keys(self) -> 'KeysView':
        self._new_user_button.click()
        time.sleep(1)
        return KeysView().wait_until_appears()


class OnboardingView(QObject):

    def __init__(self, object_name):
        super(OnboardingView, self).__init__(object_name)
        self._back_button = Button('mainWindow_onboardingBackButton_StatusRoundButton')

    @abstractmethod
    def back(self):
        pass


class KeysView(OnboardingView):

    def __init__(self):
        super(KeysView, self).__init__('mainWindow_KeysMainView')
        self._generate_key_button = Button('mainWindow_Generate_new_keys_StatusButton')
        self._generate_key_for_new_keycard_button = Button('mainWindow_Generate_keys_for_new_Keycard_StatusBaseText')
        self._import_seed_phrase_button = Button('mainWindow_Import_seed_phrase')

    @allure.step('Open Profile view')
    def generate_new_keys(self) -> 'YourProfileView':
        self._generate_key_button.click()
        return YourProfileView().wait_until_appears()

    @allure.step('Open Keycard Init view')
    def generate_key_for_new_keycard(self) -> 'KeycardInitView':
        self._generate_key_for_new_keycard_button.click()
        return KeycardInitView().wait_until_appears()

    @allure.step('Open Import Seed Phrase view')
    def open_import_seed_phrase_view(self) -> 'ImportSeedPhraseView':
        self._import_seed_phrase_button.click()
        return ImportSeedPhraseView().wait_until_appears()

    @allure.step('Go back')
    def back(self) -> WelcomeView:
        self._back_button.click()
        return WelcomeView().wait_until_appears()


class ImportSeedPhraseView(OnboardingView):

    def __init__(self):
        super(ImportSeedPhraseView, self).__init__('mainWindow_KeysMainView')
        self._import_seed_phrase_button = Button('keysMainView_PrimaryAction_Button')

    @allure.step('Open seed phrase input view')
    def open_seed_phrase_input_view(self):
        self._import_seed_phrase_button.click()
        return SeedPhraseInputView().wait_until_appears()

    @allure.step('Go back')
    def back(self) -> KeysView:
        self._back_button.click()
        return KeysView().wait_until_appears()


class SeedPhraseInputView(OnboardingView):

    def __init__(self):
        super(SeedPhraseInputView, self).__init__('mainWindow_SeedPhraseInputView')
        self._12_words_tab_button = Button('switchTabBar_12_words_Button')
        self._18_words_tab_button = Button('switchTabBar_18_words_Button')
        self._24_words_tab_button = Button('switchTabBar_24_words_Button')
        self._seed_phrase_input_text_edit = TextEdit('mainWindow_statusSeedPhraseInputField_TextEdit')
        self._import_button = Button('mainWindow_Import_StatusButton')

    @allure.step('Input seed phrase')
    def input_seed_phrase(self, seed_phrase: typing.List[str]):
        if len(seed_phrase) == 12:
            if not self._12_words_tab_button.is_checked:
                self._12_words_tab_button.click()
        elif len(seed_phrase) == 18:
            if not self._18_words_tab_button.is_checked:
                self._18_words_tab_button.click()
        elif len(seed_phrase) == 24:
            if not self._24_words_tab_button.is_checked:
                self._24_words_tab_button.click()
        else:
            raise RuntimeError("Wrong amount of seed words", len(seed_phrase))

        for index, word in enumerate(seed_phrase, start=1):
            self._seed_phrase_input_text_edit.real_name['objectName'] = f'statusSeedPhraseInputField{index}'
            self._seed_phrase_input_text_edit.text = word

        self._import_button.click()
        return YourProfileView().wait_until_appears()


class KeycardInitView(OnboardingView):

    def __init__(self):
        super(KeycardInitView, self).__init__('mainWindow_KeycardInitView')
        self._message = TextLabel('mainWindow_Plug_in_Keycard_reader_StatusBaseText')

    @property
    def message(self) -> str:
        return self._message.text

    def back(self) -> KeysView:
        self._back_button.click()
        return KeysView().wait_until_appears()


class YourProfileView(OnboardingView):

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
    def set_user_image(self, fp: SystemPath) -> PictureEditPopup:
        allure.attach(name='User image', body=fp.read_bytes(), attachment_type=allure.attachment_type.PNG)
        self._upload_picture_button.hover()
        self._upload_picture_button.click()
        file_dialog = OpenFileDialog().wait_until_appears()
        file_dialog.open_file(fp)
        return PictureEditPopup().wait_until_appears()

    @allure.step('Open Emoji and Icon view')
    def next(self) -> 'EmojiAndIconView':
        self._next_button.click()
        time.sleep(1)
        return EmojiAndIconView()

    @allure.step('Go back')
    def back(self):
        self._back_button.click()
        return KeysView().wait_until_appears()


class EmojiAndIconView(OnboardingView):

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


class CreatePasswordView(OnboardingView):

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


class ConfirmPasswordView(OnboardingView):

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


class TouchIDAuthView(OnboardingView):

    def __init__(self):
        super(TouchIDAuthView, self).__init__('mainWindow_TouchIDAuthView')
        self._prefer_password_button = Button('mainWindow_touchIdIPreferToUseMyPasswordText')

    @allure.step('Select prefer password')
    def prefer_password(self):
        self._prefer_password_button.click()
        self.wait_until_hidden()


class LoginView(QObject):

    def __init__(self):
        super(LoginView, self).__init__('mainWindow_LoginView')
        self._password_text_edit = TextEdit('loginView_passwordInput')
        self._arrow_right_button = Button('loginView_submitBtn')
        self._current_user_name_label = TextLabel('loginView_currentUserNameLabel')
        self._change_account_button = Button('loginView_changeAccountBtn')
        self._accounts_combobox = QObject('accountsView_accountListPanel')

    @allure.step('Log in user')
    def log_in(self, account):
        if self._current_user_name_label.text != account.name:
            self._change_account_button.hover()
            self._change_account_button.click()
            self.select_user_name(account.name)

        self._password_text_edit.text = account.password
        self._arrow_right_button.click()
        self.wait_until_hidden()

    @allure.step('Select user')
    def select_user_name(self, user_name, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        names = set()

        def _select_user() -> bool:
            for index in range(self._accounts_combobox.object.count):
                name_object = self._accounts_combobox.object.itemAt(index)
                name_label = str(name_object.label)
                names.add(name_label)
                if name_label == user_name:
                    try:
                        driver.mouseClick(name_object)
                    except RuntimeError:
                        continue
                    return True
            return False

        assert driver.waitFor(lambda: _select_user(), timeout_msec), f'User name: "{user_name}" not found in {names}'
