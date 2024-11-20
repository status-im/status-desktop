from allure_commons._allure import step

import configs._local
import configs.system

from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.splash_screen import SplashScreen
from gui.screens.onboarding import WelcomeToStatusView, BiometricsView, YourEmojihashAndIdenticonRingView

with step('Open Generate new keys view'):
    def open_generate_new_keys_view():
        BeforeStartedPopUp().get_started()
        keys_screen = WelcomeToStatusView().wait_until_appears().get_keys()
        return keys_screen


with step('Import seed phrase and open profile view'):
    def open_import_seed_view_and_do_import(keys_screen, seed_phrase, user_account):
        input_view = keys_screen.open_import_seed_phrase_view().open_seed_phrase_input_view()
        input_view.input_seed_phrase(seed_phrase.split(), True)
        profile_view = input_view.import_seed_phrase()
        profile_view.set_display_name(user_account.name)
        return profile_view


with step('Finalize onboarding and open main screen'):
    def finalize_onboarding_and_login(profile_view, user_account):
        create_password_view = profile_view.next()
        confirm_password_view = create_password_view.create_password(user_account.password)
        confirm_password_view.confirm_password(user_account.password)
        if configs.system.get_platform() == "Darwin":
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        next_view = YourEmojihashAndIdenticonRingView().verify_emojihash_view_present().next()
        if configs.system.get_platform() == "Darwin":
            next_view.start_using_status()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.system.TEST_MODE and not configs._local.DEV_BUILD:
            BetaConsentPopup().confirm()
        assert SigningPhrasePopup().ok_got_it_button.is_visible
        SigningPhrasePopup().confirm_phrase()

