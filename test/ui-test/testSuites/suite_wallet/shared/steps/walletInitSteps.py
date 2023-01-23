"""It defines wallet specific starting-up or driving-the-app-into-an-idle-state static methods outside bdd context
that can be reused in different `hooks` as well as in specific bdd steps files."""

import steps.commonInitSteps as init_steps
from screens.StatusMainScreen import StatusMainScreen
from screens.SettingsScreen import SettingsScreen
from screens.StatusWalletScreen import StatusWalletScreen
    
def the_user_accepts_the_signing_phrase():
    wallet_screen = StatusWalletScreen()
    wallet_screen.accept_signing_phrase()
    
def activate_and_open_wallet():
    init_steps.the_user_opens_app_settings_screen()
    init_steps.the_user_activates_wallet_and_opens_the_wallet_section()
    the_user_accepts_the_signing_phrase()
    
def the_user_opens_the_wallet_settings():
    settings_screen = SettingsScreen()
    settings_screen.open_wallet_settings()
       
def the_user_opens_wallet_screen():
    main_screen = StatusMainScreen()
    main_screen.open_wallet()       
    
def toggle_test_networks(): 
    the_user_opens_the_wallet_settings()
    init_steps.the_user_toggles_test_networks()
    the_user_opens_wallet_screen()
    the_user_accepts_the_signing_phrase()