# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    StatusWelcomeScreen.py
# *
# * \date    May 2022
# * \brief   Sign Up and Login for new users to the app.
# *****************************************************************************/

from enum import Enum
import sys
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


class AgreementPopUp(Enum):
    OK_GOT_IT_BUTTON: str = "mainWindow_Ok_got_it_StatusBaseText"
    ACKNOWLEDGE_CHECKBOX: str = "acknowledge_checkbox"
    TERMS_OF_USE_CHECK_BOX: str = "termsOfUseCheckBox_StatusCheckBox"
    GET_STARTED_BUTTON: str = "getStartedStatusButton_StatusButton"


class SignUpComponents(Enum):
    NEW_TO_STATUS: str = "mainWindow_I_am_new_to_Status_StatusBaseText"
    GENERATE_NEW_KEYS: str = "mainWindow_Generate_new_keys_StatusBaseText"
    USERNAME_INPUT: str = "mainWindow_edit_TextEdit"
    NEXT_BUTTON: str = "mainWindow_Next_StatusBaseText"
    WELCOME_TO_STATUS: str = "mainWindow_Welcome_to_Status_StyledText"
    NEXT_STATUS_BUTTON: str = "mainWindow_nextBtn_StatusButton"
    NEW_PASSWORD_BUTTON: str = "mainWindow_New_password_PlaceholderText"
    PASSWORD_INPUT: str = "loginView_passwordInput"
    CONFIRM_PASSWORD: str = "mainWindow_Confirm_password_PlaceholderText"
    PASSWORD_CONFIRM_INPUT: str = "mainWindow_Password_textField"
    CREATE_PASSWORD: str = "mainWindow_Create_password_StatusBaseText"
    CONFIRM_PASSWORD_AGAIN: str = "mainWindow_Confirm_you_password_again_PlaceholderText"
    FINALIZE_PASSWORD_STEP: str = "mainWindow_Finalise_Status_Password_Creation_StatusBaseText"
    PASSWORD_PREFERENCE: str = "mainWindow_I_prefer_to_use_my_password_StatusBaseText"

    
class SeedPhraseComponents(Enum):
    IMPORT_A_SEED_TEXT: str = "import_a_seed_phrase_StatusBaseText"
    IMPORT_A_SEED_BUTTON: str = "mainWindow_button_StatusButton"
    TWELVE_WORDS_BUTTON: str = "switchTabBar_12_words_StatusBaseText"
    EIGHTEEN_WORDS_BUTTON: str = "switchTabBar_18_words_StatusBaseText"
    TWENTY_FOUR_BUTTON: str = "switchTabBar_24_words_StatusBaseText"
    SEEDS_WORDS_TEXTFIELD: str = "mainWindow_placeholder_StatusBaseText"
    SUBMIT_BUTTON: str = "mainWindow_submitButton_StatusButton"


class StatusWelcomeScreen:

    def __init__(self):
        verify_screen(AgreementPopUp.OK_GOT_IT_BUTTON.value)

    def agree_terms_conditions_and_generate_new_key(self):
        self._agree_terms_and_conditions()
        click_obj_by_name(SignUpComponents.GENERATE_NEW_KEYS.value)
        
    def agree_terms_conditions_and_navigate_to_import_seed_phrase(self):
        self._agree_terms_and_conditions()
        click_obj_by_name(SeedPhraseComponents.IMPORT_A_SEED_TEXT.value)
        click_obj_by_name(SeedPhraseComponents.IMPORT_A_SEED_BUTTON.value)

    def input_seed_phrase(self, seed: str, words: str, occurrence: str):
        if words =='18':
            click_obj_by_name(SeedPhraseComponents.EIGHTEEN_WORDS_BUTTON.value)
        
        if words == '24':
            click_obj_by_name(SeedPhraseComponents.TWENTY_FOUR_BUTTON.value)
            
        if words == '12':
            click_obj_by_name(SeedPhraseComponents.TWELVE_WORDS_BUTTON.value)

        type(SeedPhraseComponents.SEEDS_WORDS_TEXTFIELD.value, seed)


    def input_username_and_password_and_finalize_sign_up(self, username: str, password: str):
        self.input_username(username)

        self.input_password(password)

        self.input_confirmation_password(password)

        self.input_password(password)
        click_obj_by_name(SignUpComponents.FINALIZE_PASSWORD_STEP.value)

        if sys.platform == "darwin":
            click_obj_by_name(SignUpComponents.PASSWORD_PREFERENCE.value)

    def input_username(self, username: str):
        type(SignUpComponents.USERNAME_INPUT.value, username)
        click_obj_by_name(SignUpComponents.NEXT_BUTTON.value)
        click_obj_by_name(SignUpComponents.NEXT_STATUS_BUTTON.value)

    def input_password(self, password: str):
        type(SignUpComponents.PASSWORD_INPUT.value, password)

    def input_confirmation_password(self, password: str):
        type(SignUpComponents.PASSWORD_CONFIRM_INPUT.value, password)
        click_obj_by_name(SignUpComponents.CREATE_PASSWORD.value)
        
    def _agree_terms_and_conditions(self):
        if sys.platform == "darwin":
            click_obj_by_name(AgreementPopUp.OK_GOT_IT_BUTTON.value)

        click_obj_by_name(AgreementPopUp.ACKNOWLEDGE_CHECKBOX.value)
        check_obj_by_name(AgreementPopUp.TERMS_OF_USE_CHECK_BOX.value)
        click_obj_by_name(AgreementPopUp.GET_STARTED_BUTTON.value)
        verify_text_matching(SignUpComponents.WELCOME_TO_STATUS.value, "Welcome to Status")
        click_obj_by_name(SignUpComponents.NEW_TO_STATUS.value)
        
