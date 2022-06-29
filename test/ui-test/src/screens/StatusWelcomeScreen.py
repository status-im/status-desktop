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
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


class AgreementPopUp(Enum):
    OK_GOT_IT_BUTTON = "mainWindow_Ok_got_it_StatusBaseText"
    ACKNOWLEDGE_CHECKBOX = "acknowledge_checkbox"
    TERMS_OF_USE_CHECK_BOX = "termsOfUseCheckBox_StatusCheckBox"
    GET_STARTED_BUTTON = "getStartedStatusButton_StatusButton"


class SignUpComponents(Enum):
    NEW_TO_STATUS = "mainWindow_I_am_new_to_Status_StatusBaseText"
    GENERATE_NEW_KEYS = "mainWindow_Generate_new_keys_StatusBaseText"
    USERNAME_INPUT = "mainWindow_edit_TextEdit"
    NEXT_BUTTON = "mainWindow_Next_StatusBaseText"
    NEXT_STATUS_BUTTON = "mainWindow_nextBtn_StatusButton"
    NEW_PASSWORD_BUTTON = "mainWindow_New_password_PlaceholderText"
    PASSWORD_INPUT = "loginView_passwordInput"
    CONFIRM_PASSWORD = "mainWindow_Confirm_password_PlaceholderText"
    PASSWORD_CONFIRM_INPUT = "mainWindow_inputValue_StyledTextField"
    CREATE_PASSWORD = "mainWindow_Create_password_StatusBaseText"
    CONFIRM_PASSWORD_AGAIN = "mainWindow_Confirm_you_password_again_PlaceholderText"
    FINALIZE_PASSWORD_STEP = "mainWindow_Finalise_Status_Password_Creation_StatusBaseText"
    PASSWORD_PREFERENCE = "mainWindow_I_prefer_to_use_my_password_StatusBaseText"

    
class SeedPhraseComponents(Enum):
    IMPORT_A_SEED_TEXT = "import_a_seed_phrase_StatusBaseText"
    IMPORT_A_SEED_BUTTON = "mainWindow_button_StatusButton"
    TWELVE_WORDS_BUTTON = "switchTabBar_12_words_StatusBaseText"
    EIGHTEEN_WORDS_BUTTON = "switchTabBar_18_words_StatusBaseText"
    TWENTY_FOUR_BUTTON = "switchTabBar_24_words_StatusBaseText"
    SEEDS_WORDS_TEXTFIELD = "mainWindow_placeholder_StatusBaseText"
    SUBMIT_BUTTON = "mainWindow_submitButton_StatusButton"


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

    def input_seed_phrase(self, seed, words, occurrences):
        if words =='18':
            click_obj_by_name(SeedPhraseComponents.EIGHTEEN_WORDS_BUTTON.value)
        
        if words == '24':
            click_obj_by_name(SeedPhraseComponents.TWENTY_FOUR_BUTTON.value)
            
        if words == '12':
            click_obj_by_name(SeedPhraseComponents.TWELVE_WORDS_BUTTON.value)
                
        
        type(SeedPhraseComponents.SEEDS_WORDS_TEXTFIELD.value, seed)
        
        

    def input_username_and_password_and_finalize_sign_up(self, username, password):
        self.input_username(username)

        self.input_password(password)

        self.input_confirmation_password(password)

        self.input_password(password)
        click_obj_by_name(SignUpComponents.FINALIZE_PASSWORD_STEP.value)

        click_obj_by_name(SignUpComponents.PASSWORD_PREFERENCE.value)

    def input_username(self, username):
        type(SignUpComponents.USERNAME_INPUT.value, username)
        click_obj_by_name(SignUpComponents.NEXT_BUTTON.value)
        click_obj_by_name(SignUpComponents.NEXT_STATUS_BUTTON.value)

    def input_password(self, password):
        type(SignUpComponents.PASSWORD_INPUT.value, password)

    def input_confirmation_password(self, password):
        type(SignUpComponents.PASSWORD_CONFIRM_INPUT.value, password)
        click_obj_by_name(SignUpComponents.CREATE_PASSWORD.value)
        
    def _agree_terms_and_conditions(self):
        click_obj_by_name(AgreementPopUp.OK_GOT_IT_BUTTON.value)
        click_obj_by_name(AgreementPopUp.ACKNOWLEDGE_CHECKBOX.value)
        check_obj_by_name(AgreementPopUp.TERMS_OF_USE_CHECK_BOX.value)
        click_obj_by_name(AgreementPopUp.GET_STARTED_BUTTON.value)
        click_obj_by_name(SignUpComponents.NEW_TO_STATUS.value)
        
