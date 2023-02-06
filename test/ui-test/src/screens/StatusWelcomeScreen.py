# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    StatusWelcomeScreen.py
# *
# * \date    May 2022
# * \brief   Sign Up and Login for new users to the app.
# *****************************************************************************/

from array import array
from enum import Enum
import sys
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from common.SeedUtils import *
import common.Common as common


class AgreementPopUp(Enum):
    OK_GOT_IT_BUTTON: str = "mainWindow_Ok_got_it_StatusBaseText"
    ACKNOWLEDGE_CHECKBOX: str = "acknowledge_checkbox"
    TERMS_OF_USE_CHECK_BOX: str = "termsOfUseCheckBox_StatusCheckBox"
    GET_STARTED_BUTTON: str = "getStartedStatusButton_StatusButton"

class SignUpComponents(Enum):
    NEW_TO_STATUS: str = "mainWindow_I_am_new_to_Status_StatusBaseText"
    GENERATE_NEW_KEYS: str = "keysMainView_PrimaryAction_Button"
    ADD_NEW_USER_MENU_ITEM: str = "accountsView_addNewUser_MenuItem"
    CHANGE_ACCOUNT_BTN = "loginView_changeAccountBtn"
    USERNAME_INPUT: str = "onboarding_DiplayName_Input"
    DETAILS_NEXT_BUTTON: str = "onboarding_DetailsView_NextButton"
    WELCOME_TO_STATUS: str = "mainWindow_Welcome_to_Status_StyledText"
    NEW_PASSWORD_BUTTON: str = "mainWindow_New_password_PlaceholderText"
    NEW_PSW_INPUT: str = "onboarding_newPsw_Input"
    CONFIRM_PSW_INPUT: str = "onboarding_confirmPsw_Input"
    CREATE_PSW_BUTTON: str = "onboarding_create_password_button"
    CONFIRM_PSW_AGAIN_INPUT: str = "onboarding_confirmPswAgain_Input"
    FINALIZE_PSW_BUTTON: str = "onboarding_finalise_password_button"
    PASSWORD_PREFERENCE: str = "mainWindow_I_prefer_to_use_my_password_StatusBaseText"
    PROFILE_IMAGE_CROP_WORKFLOW_ITEM: str = "mainWindow_WelcomeScreen_Image_Crop_Workflow_Item"
    PROFILE_IMAGE_CROPPER_ACCEPT_BUTTON: str = "mainWindow_WelcomeScreen_Image_Cropper_Accept_Button"
    WELCOME_SCREEN_USER_PROFILE_IMAGE: str = "mainWindow_WelcomeScreen_User_Profile_Image"
    WELCOME_SCREEN_CHAT_KEY_TEXT: str = "mainWindow_WelcomeScreen_ChatKeyText"
    BACK_BTN: str = "onboarding_back_button"
    
class SeedPhraseComponents(Enum):
    IMPORT_A_SEED_TEXT: str = "import_a_seed_phrase_StatusBaseText"
    INVALID_SEED_TEXT: str = "onboarding_InvalidSeed_Text"
    IMPORT_A_SEED_BUTTON: str = "keysMainView_PrimaryAction_Button"
    TWELVE_WORDS_BUTTON: str = "switchTabBar_12_words_Button"
    EIGHTEEN_WORDS_BUTTON: str = "switchTabBar_18_words_Button"
    TWENTY_FOUR_BUTTON: str = "switchTabBar_24_words_Button"
    SEEDS_WORDS_TEXTFIELD_template: str = "onboarding_SeedPhrase_Input_TextField_"
    SUBMIT_BUTTON: str = "seedPhraseView_Submit_Button"
    
class PasswordStrengthPossibilities(Enum):
    LOWER_VERY_WEAK = "lower_very_weak"
    UPPER_VERY_WEAK = "upper_very_weak"
    NUMBERS_VERY_WEAK = "numbers_very_weak"
    SYMBOLS_VERY_WEAK = "symbols_very_weak"
    NUMBERS_SYMBOLS_WEAK ="numbers_symbols_weak"
    NUMBERS_SYMBOLS_LOWER_SOSO = "numbers_symbols_lower_so-so"
    NUMBERS_SYMBOLS_LOWER_UPPER_GOOD = "numbers_symbols_lower_upper_good"
    NUMBERS_SYMBOLS_LOWER_UPPER_GREAT = "numbers_symbols_lower_upper_great"

class MainScreen(Enum):
    SETTINGS_BUTTON = "settings_navbar_settings_icon_StatusIcon"
    
class LoginView(Enum):
    LOGIN_VIEW_USER_IMAGE: str = "loginView_userImage"
    PASSWORD_INPUT = "loginView_passwordInput"
    SUBMIT_BTN = "loginView_submitBtn"

class StatusWelcomeScreen:

    def __init__(self):
        verify_screen(AgreementPopUp.OK_GOT_IT_BUTTON.value)

    def agree_terms_conditions_and_generate_new_key(self):
        self.agree_terms_and_conditions()
        time.sleep(1)
        click_obj_by_name(SignUpComponents.GENERATE_NEW_KEYS.value)

    def generate_new_key(self):
        self.open_accounts_selector_popup()
        click_obj_by_name(SignUpComponents.ADD_NEW_USER_MENU_ITEM.value)
        click_obj_by_name(SignUpComponents.GENERATE_NEW_KEYS.value)

    def open_accounts_selector_popup(self):
        return click_obj_by_name(SignUpComponents.CHANGE_ACCOUNT_BTN.value)

    def agree_terms_conditions_and_navigate_to_import_seed_phrase(self):
        self.agree_terms_and_conditions()
        click_obj_by_name(SeedPhraseComponents.IMPORT_A_SEED_TEXT.value)
        click_obj_by_name(SeedPhraseComponents.IMPORT_A_SEED_BUTTON.value)

    def input_seed_phrase(self, seed_phrase: str):
        words = seed_phrase.split()
        
        if len(words) == 12:
            click_obj_by_name(SeedPhraseComponents.TWELVE_WORDS_BUTTON.value)
        elif len(words) == 18:
            click_obj_by_name(SeedPhraseComponents.EIGHTEEN_WORDS_BUTTON.value)
        elif len(words) == 24:
            click_obj_by_name(SeedPhraseComponents.TWENTY_FOUR_BUTTON.value)
        else:
            test.fail("Wrong amount of seed words", len(words))

        input_seed_phrase(SeedPhraseComponents.SEEDS_WORDS_TEXTFIELD_template.value, words)

    def input_username_and_password_and_finalize_sign_up(self, username: str, password: str):
        self.input_username(username)

        self.input_password(password)

        self.input_confirmation_password(password)

        if sys.platform == "darwin":
            do_until_validation_with_timeout(
                do_fn = lambda: click_obj_by_name(SignUpComponents.PASSWORD_PREFERENCE.value),
                validation_fn = lambda: not is_loaded_visible_and_enabled(SignUpComponents.PASSWORD_PREFERENCE.value, 50)[0],
                message = 'Try clicking "I prefer to use password" until not visible and enabled (moved to the next screen)')

    def input_username(self, username: str):
        common.clear_input_text(SignUpComponents.USERNAME_INPUT.value) 
        type(SignUpComponents.USERNAME_INPUT.value, username)
        click_obj_by_name(SignUpComponents.DETAILS_NEXT_BUTTON.value)

        # The next click will move too fast sometime
        verify(is_loaded_visible_and_enabled(SignUpComponents.WELCOME_SCREEN_CHAT_KEY_TEXT.value, 10)[0], 'User Profile Chat Key is visible so the "next" press will jump to the right key')

        # There is another page with the same Next button
        do_until_validation_with_timeout(
            do_fn = lambda: click_obj_by_name(SignUpComponents.DETAILS_NEXT_BUTTON.value),
            validation_fn = lambda: is_loaded_visible_and_enabled(SignUpComponents.NEW_PSW_INPUT.value, 50)[0],
            message = 'Try clicking "Next" until new password screen is visible')

    def input_password(self, password: str):
        log("[input_password] - Before `NEW_PSW_INPUT` check")
        verify(is_loaded_visible_and_enabled(SignUpComponents.NEW_PSW_INPUT.value, 10)[0], 'New Password input is visible')
        log("[input_password] - After `NEW_PSW_INPUT` check")
        type(SignUpComponents.NEW_PSW_INPUT.value, password)
        log("[input_password] - After typing into `NEW_PSW_INPUT` password: " + password)
        type(SignUpComponents.CONFIRM_PSW_INPUT.value, password)
        log("[input_password] - After typing into `CONFIRM_PSW_INPUT` password: " + password)
        do_until_validation_with_timeout(
            do_fn = lambda: click_obj_by_name(SignUpComponents.CREATE_PSW_BUTTON.value),
            validation_fn = lambda: not is_loaded_visible_and_enabled(SignUpComponents.CREATE_PSW_BUTTON.value, 50)[0],
            message = 'Try clicking "Create Password" until button not visible (moved to the next screen)')

    def input_confirmation_password(self, password: str):
        log("[input_confirmation_password] - Before `CONFIRM_PSW_AGAIN_INPUT` check")
        verify(is_loaded_visible_and_enabled(SignUpComponents.CONFIRM_PSW_AGAIN_INPUT.value, 10)[0], 'Reconfirm password is visible')
        log("[input_confirmation_password] - After `CONFIRM_PSW_AGAIN_INPUT` check")
        type(SignUpComponents.CONFIRM_PSW_AGAIN_INPUT.value, password)
        log("[input_confirmation_password] - After typing into `CONFIRM_PSW_AGAIN_INPUT` password: " + password)
        do_until_validation_with_timeout(
            do_fn = lambda: click_obj_by_name(SignUpComponents.FINALIZE_PSW_BUTTON.value),
            validation_fn = lambda: not is_loaded_visible_and_enabled(SignUpComponents.FINALIZE_PSW_BUTTON.value, 50)[0],
            message = 'Try clicking "Finalize" until button not visible (moved to the next screen')

    def agree_terms_and_conditions(self):
        if sys.platform == "darwin":
            click_obj_by_name(AgreementPopUp.OK_GOT_IT_BUTTON.value)

        click_obj_by_name(AgreementPopUp.ACKNOWLEDGE_CHECKBOX.value)
        check_obj_by_name(AgreementPopUp.TERMS_OF_USE_CHECK_BOX.value)
        click_obj_by_name(AgreementPopUp.GET_STARTED_BUTTON.value)
        verify_text_matching(SignUpComponents.WELCOME_TO_STATUS.value, "Welcome to Status")
        click_obj_by_name(SignUpComponents.NEW_TO_STATUS.value)
        
    def seed_phrase_visible(self):
        is_loaded_visible_and_enabled(SeedPhraseComponents.INVALID_SEED_TEXT.value)
        
    # The following validation is based in screenshots comparison and is OS dependent:
    def validate_password_strength(self, strength: str):
        if sys.platform == "darwin":
            if strength == PasswordStrengthPossibilities.LOWER_VERY_WEAK.value:
                verify_screenshot("VP-PWStrength-lower_very_weak")

            elif strength == PasswordStrengthPossibilities.UPPER_VERY_WEAK.value:
                verify_screenshot("VP-PWStrength-upper_very_weak")

            elif strength == PasswordStrengthPossibilities.NUMBERS_VERY_WEAK.value:
                verify_screenshot("VP-PWStrength-numbers_very_weak")

            elif strength == PasswordStrengthPossibilities.SYMBOLS_VERY_WEAK.value:
                verify_screenshot("VP-PWStrength-symbols_very_weak")

            elif strength == PasswordStrengthPossibilities.NUMBERS_SYMBOLS_WEAK.value:
                verify_screenshot("VP-PWStrength-numbers_symbols_weak")

            elif strength == PasswordStrengthPossibilities.NUMBERS_SYMBOLS_LOWER_SOSO.value:
                verify_screenshot("VP-PWStrength-numbers_symbols_lower_so-so")

            elif strength == PasswordStrengthPossibilities.NUMBERS_SYMBOLS_LOWER_UPPER_GOOD.value:
                verify_screenshot("VP-PWStrength-numbers_symbols_lower_upper_good")

            elif strength == PasswordStrengthPossibilities.NUMBERS_SYMBOLS_LOWER_UPPER_GREAT.value:
                verify_screenshot("VP-PWStrength-numbers_symbols_lower_upper_great")
            
        # TODO: Get screenshots in Linux

    def input_profile_image(self, profileImageUrl: str):
        workflow = get_obj(SignUpComponents.PROFILE_IMAGE_CROP_WORKFLOW_ITEM.value)
        workflow.cropImage(profileImageUrl)        
        click_obj_by_name(SignUpComponents.PROFILE_IMAGE_CROPPER_ACCEPT_BUTTON.value)
        
    def input_username_and_grab_profile_image_sreenshot(self, username: str):
        type(SignUpComponents.USERNAME_INPUT.value, username)
        click_obj_by_name(SignUpComponents.DETAILS_NEXT_BUTTON.value)
        
        # take a screenshot of the profile image to compare it later with the main screen
        profileIcon = wait_and_get_obj(SignUpComponents.WELCOME_SCREEN_USER_PROFILE_IMAGE.value)
        grabScreenshot_and_save(profileIcon, "profiletestimage", 200)
        
        # There is another page with the same Next button
        click_obj_by_name(SignUpComponents.DETAILS_NEXT_BUTTON.value)

    def input_username_profileImage_password_and_finalize_sign_up(self, profileImageUrl: str, username: str, password: str):
        self.input_profile_image(profileImageUrl)

        self.input_username_and_grab_profile_image_sreenshot(username)        

        self.input_password(password)

        self.input_confirmation_password(password)

        if sys.platform == "darwin":
            click_obj_by_name(SignUpComponents.PASSWORD_PREFERENCE.value)
            
    def grab_screenshot(self):
        # take a screenshot of the profile image to compare it later with the main screen
        loginUserName = wait_and_get_obj(LoginView.LOGIN_VIEW_USER_IMAGE.value)
        grabScreenshot_and_save(loginUserName, "loginUserName", 200)
        
    def enter_password(self, password):
        click_obj_by_name(LoginView.PASSWORD_INPUT.value)
        type(LoginView.PASSWORD_INPUT.value, password)
        click_obj_by_name(LoginView.SUBMIT_BTN.value)   
        
    def navigate_back_to_user_profile_page(self):
        count = 0
        while not is_displayed(SignUpComponents.USERNAME_INPUT.value, 500):
            click_obj_by_name(SignUpComponents.BACK_BTN.value)
            count += 1
            if count > 5:
                verify_failure("Error during onboarding process navigating back to user profile page")
                break