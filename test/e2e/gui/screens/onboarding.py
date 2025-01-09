import logging
import pathlib
import time
import typing
from abc import abstractmethod

import allure

import configs
import constants.tesseract
from constants.onboarding import OnboardingScreensHeaders
import driver
from constants import ColorCodes
from driver.objects_access import walk_children
from gui.components.onboarding.keys_already_exist_popup import KeysAlreadyExistPopup
from gui.components.onboarding.share_usage_data_popup import ShareUsageDataPopup
from gui.components.os.open_file_dialogs import OpenFileDialog
from gui.components.picture_edit_popup import PictureEditPopup
from gui.components.splash_screen import SplashScreen
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import onboarding_names
from scripts.tools.image import Image
from scripts.utils.system_path import SystemPath

LOG = logging.getLogger(__name__)


class AllowNotificationsView(QObject):

    def __init__(self):
        super(AllowNotificationsView, self).__init__(onboarding_names.mainWindow_AllowNotificationsView)
        self._start_using_status_button = Button(onboarding_names.mainWindow_Start_using_Status_StatusButton)

    @allure.step("Start using Status")
    def start_using_status(self):
        # TODO https://github.com/status-im/status-desktop/issues/15345
        self._start_using_status_button.click(timeout=30)
        self.wait_until_hidden()


class WelcomeToStatusView(QObject):

    def __init__(self):
        super(WelcomeToStatusView, self).__init__(onboarding_names.mainWindow_WelcomeView)
        self._i_am_new_to_status_button = Button(onboarding_names.mainWindow_I_am_new_to_Status_StatusBaseText)
        self._i_already_use_status_button = Button(onboarding_names.mainWindow_I_already_use_Status_StatusFlatButton)

    @allure.step('Open Keys view')
    def get_keys(self) -> 'KeysView':
        self._i_am_new_to_status_button.click()
        time.sleep(1)
        ShareUsageDataPopup().skip()
        return KeysView().wait_until_appears()

    @allure.step('Open Sign by syncing form')
    def sync_existing_user(self) -> 'SignBySyncingView':
        self._i_already_use_status_button.click()
        time.sleep(1)
        ShareUsageDataPopup().skip()
        return SignBySyncingView().wait_until_appears()


class OnboardingView(QObject):

    def __init__(self, object_name):
        super(OnboardingView, self).__init__(object_name)
        self._back_button = Button(onboarding_names.mainWindow_onboardingBackButton_StatusRoundButton)


class KeysView(OnboardingView):

    def __init__(self):
        super(KeysView, self).__init__(onboarding_names.mainWindow_KeysMainView)
        self._generate_key_button = Button(onboarding_names.mainWindow_Generate_new_keys_StatusButton)
        self._generate_key_for_new_keycard_button = Button(
            onboarding_names.mainWindow_Generate_keys_for_new_Keycard_StatusBaseText)
        self._import_seed_phrase_button = Button(onboarding_names.mainWindow_Import_seed_phrase)

    @allure.step('Open Profile view')
    def generate_new_keys(self) -> 'YourProfileView':
        self._generate_key_button.click()
        return YourProfileView().verify_profile_view_present()

    @allure.step('Open Keycard Init view')
    def generate_key_for_new_keycard(self) -> 'KeycardInitView':
        self._generate_key_for_new_keycard_button.click()
        return KeycardInitView().wait_until_appears()

    @allure.step('Open Import Seed Phrase view')
    def open_import_seed_phrase_view(self) -> 'ImportSeedPhraseView':
        self._import_seed_phrase_button.click()
        return ImportSeedPhraseView().wait_until_appears()

    @allure.step('Open Enter Seed Phrase view')
    def open_enter_seed_phrase_view(self) -> 'ImportSeedPhraseView':
        self._import_seed_phrase_button.click()
        return SeedPhraseInputView().wait_until_appears(timeout_msec=10000)

    @allure.step('Go back')
    def back(self) -> WelcomeToStatusView:
        self._back_button.click()
        return WelcomeToStatusView().wait_until_appears()


class ImportSeedPhraseView(OnboardingView):

    def __init__(self):
        super(ImportSeedPhraseView, self).__init__(onboarding_names.mainWindow_KeysMainView)
        self._import_seed_phrase_button = Button(onboarding_names.keysMainView_PrimaryAction_Button)

    @allure.step('Open seed phrase input view')
    def open_seed_phrase_input_view(self):
        self._import_seed_phrase_button.click()
        return SeedPhraseInputView().wait_until_appears()

    @allure.step('Go back')
    def back(self) -> KeysView:
        self._back_button.click()
        return KeysView().wait_until_appears()


class SignBySyncingView(OnboardingView):

    def __init__(self):
        super(SignBySyncingView, self).__init__(onboarding_names.mainWindow_KeysMainView)
        self._scan_or_enter_sync_code_button = Button(onboarding_names.keysMainView_PrimaryAction_Button)
        self._i_dont_have_other_device_button = Button(
            onboarding_names.mainWindow_iDontHaveOtherDeviceButton_StatusBaseText)

    @allure.step('Open sync code view')
    def open_sync_code_view(self):
        self._scan_or_enter_sync_code_button.click()
        return SyncCodeView().wait_until_appears()

    @allure.step('Open keys view')
    def open_keys_view(self):
        self._i_dont_have_other_device_button.click()
        return KeysView().wait_until_appears()


class SyncCodeView(OnboardingView):

    def __init__(self):
        super(SyncCodeView, self).__init__(onboarding_names.mainWindow_SyncCodeView)
        self._enter_sync_code_button = Button(onboarding_names.switchTabBar_Enter_sync_code_StatusSwitchTabButton)
        self._paste_sync_code_button = Button(onboarding_names.mainWindow_Paste_StatusButton)
        self._syncing_enter_code_item = QObject(onboarding_names.mainWindow_syncingEnterCode_SyncingEnterCode)
        self.continue_button = Button(onboarding_names.mainWindow_nameInput_syncingEnterCode_Continue)

    @allure.step('Open enter sync code form')
    def open_enter_sync_code_form(self):
        self._enter_sync_code_button.click()
        return self

    @allure.step('Paste sync code')
    def click_paste_button(self):
        self._paste_sync_code_button.click()

    @property
    @allure.step('Get wrong sync code message')
    def sync_code_error_message(self) -> str:
        return self._syncing_enter_code_item.object.syncCodeErrorMessage


class SyncDeviceFoundView(OnboardingView):

    def __init__(self):
        super(SyncDeviceFoundView, self).__init__(onboarding_names.mainWindow_SyncingDeviceView_found)
        self._sync_text_item = QObject(onboarding_names.sync_text_item)

    @property
    @allure.step('Get device_found_notifications')
    def device_found_notifications(self) -> typing.List:
        device_found_notifications = []
        for obj in driver.findAllObjects(self._sync_text_item.real_name):
            device_found_notifications.append(str(obj.text))
        return device_found_notifications


class SyncResultView(OnboardingView):

    def __init__(self):
        super(SyncResultView, self).__init__(onboarding_names.mainWindow_SyncDeviceResult)
        self._sync_result = QObject(onboarding_names.mainWindow_SyncDeviceResult)
        self._sign_in_button = Button(onboarding_names.mainWindow_Sign_in_StatusButton)
        self._synced_text_item = QObject(onboarding_names.synced_StatusBaseText)

    @property
    @allure.step('Get device synced notifications')
    def device_synced_notifications(self) -> typing.List:
        device_synced_notifications = []
        for obj in driver.findAllObjects(self._synced_text_item.real_name):
            device_synced_notifications.append(str(obj.text))
        return device_synced_notifications

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = 10000):
        self._sign_in_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Sign in')
    def sign_in(self, attempts: int = 2):
        self._sign_in_button.click()
        try:
            return SplashScreen().wait_until_appears()
        except:
            assert attempts > 0, f'Next button was not clicked'
            self.sign_in(attempts - 1)


class SeedPhraseInputView(OnboardingView):

    def __init__(self):
        super(SeedPhraseInputView, self).__init__(onboarding_names.mainWindow_SeedPhraseInputView)
        self._12_words_tab_button = Button(onboarding_names.switchTabBar_12_words_Button)
        self._18_words_tab_button = Button(onboarding_names.switchTabBar_18_words_Button)
        self._24_words_tab_button = Button(onboarding_names.switchTabBar_24_words_Button)
        self._seed_phrase_input_text_edit = TextEdit(onboarding_names.mainWindow_statusSeedPhraseInputField_TextEdit)
        self._import_button = Button(onboarding_names.mainWindow_Import_StatusButton)

    @property
    @allure.step('Get import button enabled state')
    def is_import_button_enabled(self) -> bool:
        return driver.waitForObjectExists(self._import_button.real_name,
                                          configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled

    @allure.step('Input seed phrase')
    def input_seed_phrase(self, seed_phrase: typing.List[str], autocomplete: bool):
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
            self._seed_phrase_input_text_edit.real_name['objectName'] = f'enterSeedPhraseInputField{index}'
            if autocomplete:
                word_to_put = word
                if len(word) > 4:
                    word_to_put = word[:-1]
                self._seed_phrase_input_text_edit.text = word_to_put
                driver.type(self._seed_phrase_input_text_edit.object, "<Return>")
            else:
                self._seed_phrase_input_text_edit.text = word

    @allure.step('Import seed phrase')
    def import_seed_phrase(self):
        self._import_button.click()
        return YourProfileView().wait_until_appears()

    @allure.step('Click import button')
    def click_import_seed_phrase_button(self):
        self._import_button.click()
        return KeysAlreadyExistPopup().wait_until_appears()


class KeycardInitView(OnboardingView):

    def __init__(self):
        super(KeycardInitView, self).__init__(onboarding_names.mainWindow_KeycardInitView)
        self._message = TextLabel(onboarding_names.mainWindow_Plug_in_Keycard_reader_StatusBaseText)

    @property
    def message(self) -> str:
        return self._message.text

    def back(self) -> KeysView:
        self._back_button.click()
        return KeysView().wait_until_appears()


class YourProfileView(OnboardingView):

    def __init__(self):
        super(YourProfileView, self).__init__(onboarding_names.mainWindow_InsertDetailsView)
        self._upload_picture_button = Button(onboarding_names.updatePicButton_StatusRoundButton)
        self._profile_image = QObject(onboarding_names.mainWindow_statusRoundImage_StatusRoundedImage)
        self._display_name_text_field = TextEdit(onboarding_names.mainWindow_statusBaseInput_StatusBaseInput)
        self._erros_text_label = TextLabel(onboarding_names.mainWindow_errorMessage_StatusBaseText)
        self._next_button = Button(onboarding_names.mainWindow_Next_StatusButton)
        self._login_input_object = QObject(onboarding_names.mainWindow_nameInput_StatusInput)
        self._clear_icon = QObject(onboarding_names.mainWindow_clear_icon_StatusIcon)
        self._identicon_ring = QObject(onboarding_names.mainWindow_IdenticonRing)
        self._view_header_title = TextLabel(onboarding_names.mainWindow_Header_Title)
        self._image_crop_workflow = QObject(onboarding_names.profileImageCropper)

    def verify_profile_view_present(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        driver.waitFor(lambda: self._view_header_title.exists, timeout_msec)
        assert (getattr(self._view_header_title.object, 'text') ==
                OnboardingScreensHeaders.YOUR_PROFILE_SCREEN_TITLE.value), \
            f"YourProfileView is not shown or has wrong title, \
            current screen title is {getattr(self._view_header_title.object, 'text')}"
        return self

    @property
    @allure.step('Get next button enabled state')
    def is_next_button_enabled(self) -> bool:
        return driver.waitForObjectExists(self._next_button.real_name, configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled

    @property
    @allure.step('Get profile image')
    def get_profile_image(self) -> Image:
        return self._profile_image.image

    @property
    @allure.step('Get error messages')
    def get_error_message(self) -> str:
        return self._erros_text_label.text if self._erros_text_label.is_visible else ''

    @allure.step('Set user display name')
    def set_display_name(self, value: str):
        self._display_name_text_field.clear().text = value
        return self

    @allure.step('Get user display name')
    def get_display_name(self) -> str:
        return str(self._display_name_text_field.object.text)

    @allure.step('Click clear button')
    def clear_field(self):
        self._clear_icon.click()
        return self

    @allure.step('Set profile picture without file upload dialog')
    def set_profile_picture(self, path) -> PictureEditPopup:
        image_cropper = driver.waitForObjectExists(self._image_crop_workflow.real_name)
        fileuri = pathlib.Path(str(path)).as_uri()
        image_cropper.cropImage(fileuri)
        return PictureEditPopup()

    @allure.step('Set profile picture with file dialog upload')
    def set_user_image(self, fp: SystemPath) -> PictureEditPopup:
        allure.attach(name='User image', body=fp.read_bytes(), attachment_type=allure.attachment_type.PNG)
        self._upload_picture_button.hover()
        self._upload_picture_button.click()
        file_dialog = OpenFileDialog().wait_until_appears()
        file_dialog.open_file(fp)
        return PictureEditPopup().wait_until_appears()

    @allure.step('Open Create Password View')
    def next(self, attempts: int = 2) -> 'CreatePasswordView':
        self._next_button.click()
        try:
            return CreatePasswordView()
        except Exception as err:
            if attempts:
                return self.next(attempts - 1)
            else:
                raise err

    @allure.step('Go back')
    def back(self):
        self._back_button.click()
        return KeysView().wait_until_appears()


class YourEmojihashAndIdenticonRingView(OnboardingView):

    def __init__(self):
        super(YourEmojihashAndIdenticonRingView, self).__init__(onboarding_names.mainWindow_InsertDetailsView)
        self._profile_image = QObject(onboarding_names.mainWindow_welcomeScreenUserProfileImage_StatusSmartIdenticon)
        self._chat_key_text_label = TextLabel(onboarding_names.mainWindow_insertDetailsViewChatKeyTxt_StyledText)
        self._next_button = Button(onboarding_names.mainWindow_Next_StatusButton)
        self._emoji_hash = QObject(onboarding_names.mainWindow_EmojiHash)
        self._identicon_ring = QObject(onboarding_names.mainWindow_userImageCopy_StatusSmartIdenticon)
        self._view_header_title = TextLabel(onboarding_names.mainWindow_Header_Title)

    def verify_emojihash_view_present(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        driver.waitFor(lambda: self._view_header_title.exists, timeout_msec)
        assert (getattr(self._view_header_title.object, 'text') ==
                OnboardingScreensHeaders.YOUR_EMOJIHASH_AND_IDENTICON_RING_SCREEN_TITLE.value), \
            f"YourEmojihashAndIdenticonRingView is not shown or has wrong title, \
            current screen title is {getattr(self._view_header_title.object, 'text')}"
        return self

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
    def get_chat_key(self) -> str:
        return self._chat_key_text_label.text.split(':')[1].strip()

    @property
    @allure.step('Get emoji hash image')
    def get_emoji_hash(self) -> str:
        return str(getattr(self._emoji_hash.object, 'publicKey'))

    @allure.step('Click next in your emojihash and identicon ring view')
    def next(self):
        # TODO https://github.com/status-im/status-desktop/issues/15345
        self._next_button.click(timeout=30)
        time.sleep(1)
        if configs.system.get_platform() == "Darwin":
            return AllowNotificationsView().wait_until_appears()

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
        super(CreatePasswordView, self).__init__(onboarding_names.mainWindow_CreatePasswordView)
        self._new_password_text_field = TextEdit(onboarding_names.mainWindow_passwordViewNewPassword)
        self._confirm_password_text_field = TextEdit(onboarding_names.mainWindow_passwordViewNewPasswordConfirm)
        self._create_button = Button(onboarding_names.mainWindow_Create_password_StatusButton)
        self._password_view_object = QObject(onboarding_names.mainWindow_view_PasswordView)
        self._strength_indicator = QObject(
            onboarding_names.mainWindow_strengthInditactor_StatusPasswordStrengthIndicator)
        self._indicator_panel_object = QObject(onboarding_names.mainWindow_RowLayout)
        self._show_icon = QObject(onboarding_names.mainWindow_show_icon_StatusIcon)
        self._hide_icon = QObject(onboarding_names.mainWindow_hide_icon_StatusIcon)

    @allure.step('Get password content from first field')
    def get_password_from_first_field(self) -> str:
        return str(self._new_password_text_field.object.displayText)

    @allure.step('Get password content from confirmation field')
    def get_password_from_confirmation_field(self) -> str:
        return str(self._confirm_password_text_field.object.displayText)

    @property
    @allure.step('Verify: Create password button enabled')
    def is_create_password_button_enabled(self) -> bool:
        return driver.waitForObjectExists(self._create_button.real_name,
                                          configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled

    @property
    @allure.step('Get strength indicator color')
    def strength_indicator_color(self) -> str:
        return self._strength_indicator.object.fillColor['name']

    @property
    @allure.step('Get strength indicator text')
    def strength_indicator_text(self) -> str:
        return self._strength_indicator.object.text

    @property
    @allure.step('Get indicator panel green messages')
    def green_indicator_messages(self) -> typing.List[str]:
        messages = []
        color = ColorCodes.GREEN.value

        for item in driver.findAllObjects(self._indicator_panel_object.real_name):
            if str(item.color.name) == color:
                messages.append(str(item.text))
        return messages

    @property
    @allure.step('Get password error message')
    def password_error_message(self) -> str:
        return self._password_view_object.object.errorMsgText

    @allure.step('Click show icon by index')
    def click_show_icon(self, index):
        show_icons = driver.findAllObjects(self._show_icon.real_name)
        driver.mouseClick(show_icons[index])

    @allure.step('Click hide icon by index')
    def click_hide_icon(self, index):
        hide_icons = driver.findAllObjects(self._hide_icon.real_name)
        driver.mouseClick(hide_icons[index])

    @allure.step('Set password in first field')
    def set_password_in_first_field(self, value: str):
        self._new_password_text_field.text = value

    @allure.step('Set password in confirmation field')
    def set_password_in_confirmation_field(self, value: str):
        self._confirm_password_text_field.text = value

    @allure.step('Set password and open Confirmation password view')
    def create_password(self, value: str) -> 'ConfirmPasswordView':
        self.set_password_in_first_field(value)
        self.set_password_in_confirmation_field(value)
        self.click_create_password()
        return ConfirmPasswordView().wait_until_appears()

    def click_create_password(self):
        self._create_button.click()
        time.sleep(1)
        return ConfirmPasswordView().wait_until_appears()

    @allure.step('Go back')
    def back(self):
        self._back_button.click()
        return YourEmojihashAndIdenticonRingView().wait_until_appears()


class ConfirmPasswordView(OnboardingView):

    def __init__(self):
        super(ConfirmPasswordView, self).__init__(onboarding_names.mainWindow_ConfirmPasswordView)
        self._confirm_password_text_field = TextEdit(onboarding_names.mainWindow_confirmAgainPasswordInput)
        self._confirm_button = Button(onboarding_names.mainWindow_Finalise_Status_Password_Creation_StatusButton)
        self._confirmation_password_view_object = QObject(
            onboarding_names.mainWindow_passwordView_PasswordConfirmationView)

    @property
    @allure.step('Get finalise password creation button enabled state')
    def is_confirm_password_button_enabled(self) -> bool:
        return driver.waitForObjectExists(self._confirm_button.real_name,
                                          configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled

    @property
    @allure.step('Get confirmation error message')
    def confirmation_error_message(self) -> str:
        for child in walk_children(self._confirmation_password_view_object.object):
            if getattr(child, 'id', '') == 'errorTxt':
                return str(child.text)

    @allure.step('Set password')
    def set_password(self, value: str):
        self._confirm_password_text_field.text = value

    @allure.step('Click confirm password')
    def click_confirm_password(self):
        self._confirm_button.click()

    @allure.step('Confirm password')
    def confirm_password(self, value: str):
        self.set_password(value)
        self._confirm_button.click()

    @allure.step('Go back')
    def back(self):
        self._back_button.click()
        return CreatePasswordView().wait_until_appears()

    @allure.step('Get password content from confirmation again field')
    def get_password_from_confirmation_again_field(self) -> str:
        return str(self._confirm_password_text_field.object.displayText)


class BiometricsView(OnboardingView):

    def __init__(self):
        super(BiometricsView, self).__init__(onboarding_names.mainWindow_TouchIDAuthView)
        self._yes_use_touch_id_button = Button(onboarding_names.mainWindow_touchIdYesUseTouchIDButton)
        self._prefer_password_button = Button(onboarding_names.mainWindow_touchIdIPreferToUseMyPasswordText)

    @allure.step('Select prefer password')
    def prefer_password(self):
        self._prefer_password_button.click()
        self.wait_until_hidden()

    @allure.step('Verify TouchID button')
    def is_touch_id_button_visible(self):
        return self._yes_use_touch_id_button.is_visible


class LoginView(QObject):

    def __init__(self):
        super(LoginView, self).__init__(onboarding_names.mainWindow_LoginView)
        self._password_text_edit = TextEdit(onboarding_names.loginView_passwordInput)
        self._arrow_right_button = Button(onboarding_names.loginView_submitBtn)
        self._current_user_name_label = TextLabel(onboarding_names.loginView_currentUserNameLabel)
        self._change_account_button = Button(onboarding_names.loginView_changeAccountBtn)
        self._accounts_combobox = QObject(onboarding_names.accountsView_accountListPanel)
        self._password_object = QObject(onboarding_names.mainWindow_txtPassword_Input)
        self._add_new_user_item = QObject(onboarding_names.loginView_addNewUserItem_AccountMenuItemPanel)
        self._add_existing_user_item = QObject(onboarding_names.loginView_addExistingUserItem_AccountMenuItemPanel)
        self._use_password_instead = QObject(onboarding_names.mainWindowUsePasswordInsteadStatusBaseText)

    @property
    @allure.step('Get login error message')
    def login_error_message(self) -> str:
        return str(self._password_object.object.validationError)

    @allure.step('Log in user')
    def log_in(self, account):
        if self._current_user_name_label.text != account.name:
            self._change_account_button.hover()
            self._change_account_button.click()
            self.select_user_name(account.name)

        if self._use_password_instead.is_visible:
            self._use_password_instead.click()

        self._password_text_edit.text = account.password
        self._arrow_right_button.click()

    @allure.step('Add existing user')
    def add_existing_status_user(self):
        self._current_user_name_label.click()
        self._add_existing_user_item.click()
        return SignBySyncingView().wait_until_appears()

    @allure.step('Select user')
    def select_user_name(self, user_name, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        onboarding_names = set()

        def _select_user() -> bool:
            for index in range(self._accounts_combobox.object.count):
                name_object = self._accounts_combobox.object.itemAt(index)
                name_label = str(name_object.label)
                onboarding_names.add(name_label)
                if name_label == user_name:
                    try:
                        driver.mouseClick(name_object)
                    except RuntimeError:
                        continue
                    return True
            return False

        assert driver.waitFor(lambda: _select_user(),
                              timeout_msec), f'User name: "{user_name}" not found in {onboarding_names}'
