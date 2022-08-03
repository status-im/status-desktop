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


class AgreementPopUp(Enum):
    OK_GOT_IT_BUTTON: str = "mainWindow_Ok_got_it_StatusBaseText"
    ACKNOWLEDGE_CHECKBOX: str = "acknowledge_checkbox"
    TERMS_OF_USE_CHECK_BOX: str = "termsOfUseCheckBox_StatusCheckBox"
    GET_STARTED_BUTTON: str = "getStartedStatusButton_StatusButton"


class SignUpComponents(Enum):
    NEW_TO_STATUS: str = "mainWindow_I_am_new_to_Status_StatusBaseText"
    GENERATE_NEW_KEYS: str = "keysMainView_PrimaryAction_Button"
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

    
class SeedPhraseComponents(Enum):
    IMPORT_A_SEED_TEXT: str = "import_a_seed_phrase_StatusBaseText"
    INVALID_SEED_TEXT: str = "onboarding_InvalidSeed_Text"
    IMPORT_A_SEED_BUTTON: str = "keysMainView_PrimaryAction_Button"
    TWELVE_WORDS_BUTTON: str = "switchTabBar_12_words_Button"
    EIGHTEEN_WORDS_BUTTON: str = "switchTabBar_18_words_Button"
    TWENTY_FOUR_BUTTON: str = "switchTabBar_24_words_Button"
    SEEDS_WORDS_TEXTFIELD_template: str = "onboarding_SeedPhrase_Input_TextField_"
    SUBMIT_BUTTON: str = "seedPhraseView_Submit_Button"

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
            click_obj_by_name(SignUpComponents.PASSWORD_PREFERENCE.value)

    def input_username(self, username: str):
        type(SignUpComponents.USERNAME_INPUT.value, username)
        click_obj_by_name(SignUpComponents.DETAILS_NEXT_BUTTON.value)
        # There is another page with the same Next button
        click_obj_by_name(SignUpComponents.DETAILS_NEXT_BUTTON.value)

    def input_password(self, password: str):
        type(SignUpComponents.NEW_PSW_INPUT.value, password)
        type(SignUpComponents.CONFIRM_PSW_INPUT.value, password)
        click_obj_by_name(SignUpComponents.CREATE_PSW_BUTTON.value)
        
    def input_confirmation_password(self, password: str):
        type(SignUpComponents.CONFIRM_PSW_AGAIN_INPUT.value, password)
        click_obj_by_name(SignUpComponents.FINALIZE_PSW_BUTTON.value)
        
    def _agree_terms_and_conditions(self):
        if sys.platform == "darwin":
            click_obj_by_name(AgreementPopUp.OK_GOT_IT_BUTTON.value)

        click_obj_by_name(AgreementPopUp.ACKNOWLEDGE_CHECKBOX.value)
        check_obj_by_name(AgreementPopUp.TERMS_OF_USE_CHECK_BOX.value)
        click_obj_by_name(AgreementPopUp.GET_STARTED_BUTTON.value)
        verify_text_matching(SignUpComponents.WELCOME_TO_STATUS.value, "Welcome to Status")
        click_obj_by_name(SignUpComponents.NEW_TO_STATUS.value)
        
    def seed_phrase_visible(self):
        is_loaded_visible_and_enabled(SeedPhraseComponents.INVALID_SEED_TEXT.value)
        
