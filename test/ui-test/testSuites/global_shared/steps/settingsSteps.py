import steps.startupSteps as common_init_steps
import steps.walletInitSteps as wallet_init_steps

from screens.StatusMainScreen import StatusMainScreen
from screens.SettingsScreen import SettingsScreen
from screens.StatusLanguageScreen import StatusLanguageScreen

_statusMain = StatusMainScreen()
_settingsScreen = SettingsScreen()
_languageScreen = StatusLanguageScreen()

#########################
### PRECONDITIONS region:
#########################

@Given("the user opens app settings screen")
def step(context: any):
    the_user_opens_app_settings_screen()
    
@Given("the user opens the messaging settings")
def step(context: any):
    the_user_opens_the_messaging_settings()
    
@Given("tenor GIFs preview is enabled")
def step(context: any):
    _settingsScreen.check_tenor_gif_preview_is_enabled()
    
@Given("the user activates wallet and opens the wallet section")
def step(context: any):
    wallet_init_steps.the_user_activates_wallet_and_opens_the_wallet_section()
    
@Given("the user toggles test networks")
def step(context: any):
    wallet_init_steps.the_user_toggles_test_networks()

@Given("the user activates wallet")
def step(context: any):
    the_user_activates_wallet() 

@Given("the user opens the wallet settings")
def step(context: any):
    the_user_opens_the_wallet_settings()
    
#########################
### ACTIONS region:
#########################

@When("the user opens app settings screen")
def step(context: any):
    the_user_opens_app_settings_screen()
    
@When("the user opens the messaging settings")
def step(context: any):
    the_user_opens_the_messaging_settings()

@When("the user activates link preview")
def step(context: any):
    _settingsScreen.activate_link_preview()

@When("the user activates image unfurling")
def step(context: any):
    _settingsScreen.activate_image_unfurling()

@When("the user activates wallet")
def step(context: any):
    the_user_activates_wallet() 

@When("the user opens the wallet settings")
def step(context: any):
    the_user_opens_the_wallet_settings()

@When("the user deletes the account \"|any|\"")
def step(context: any, account_name: str):
    _statusMain.open_settings()
    _settingsScreen.delete_account(account_name)

@When("the user selects the default account")
def step(context: any):
    _settingsScreen.select_default_account()

@When("the user edits default account to \"|any|\" name and \"|any|\" color")
def step(context: any, account_name: str,  account_color: str):
    _settingsScreen.edit_account(account_name, account_color)

@When("the user registers a random ens name with password \"|any|\"")
def step(context, password):
    _statusMain.open_settings()
    _settingsScreen.register_random_ens_name(password)
    
@When("the user clicks on Language & Currency")
def step(context):
    _settingsScreen.open_language_and_currency_settings() 
    _languageScreen.is_screen_loaded()
    
@When("the user opens the language selector")
def step(context):
    _languageScreen.open_language_combobox()
    
@When("the user selects the language |any|")
def step(context, native):
    _languageScreen.select_language(native)
    snooze(5) # TODO: Wait until language has changed
    
@When("the user searches the language |any|")
def step(context, native):
    _languageScreen.search_language(native)
    
@When("the user clicks on Sign out and Quit")
def step(context: any):
    ctx = currentApplicationContext()
    _settingsScreen.sign_out_and_quit_the_app(ctx.pid)
    
@When("the user opens the communities settings")
def step(context: any):
    _settingsScreen.open_communities_section()

@When("the user leaves the community")
def step(context: any):
    _settingsScreen.leave_community()

@When("the user opens the profile settings")
def step(context: any):
    _settingsScreen.open_profile_settings()

@When("the user sets display name to \"|any|\"")
def step(context, display_name):
    _settingsScreen.set_display_name(display_name)
    
@When("the user backs up the wallet seed phrase")
def step(context):
    _settingsScreen.check_backup_seed_phrase_workflow()
    
@When("the user sets display links to twitter: \"|any|\", personal site: \"|any|\", \"|any|\": \"|any|\"")
def step(context, twitter, personal_site, custom_link_name, custom_link):
    _settingsScreen.set_social_links(twitter, personal_site, custom_link_name, custom_link)
    
@When("the user sets bio to \"|any|\"")
def step(context, bio):
    _settingsScreen.set_bio(bio)
    
@When("the users switches state to offline")
def step(context: any):
    _statusMain.set_user_state_offline()
        
@When("the users switches state to online")
def step(context: any):
    _statusMain.set_user_state_online()
    
@When("the users switches state to automatic")
def step(context: any):
    _statusMain.set_user_state_to_automatic()
    
@When("the user opens own profile popup")
def step(context: any):
    _statusMain.open_own_profile_popup()
    
@When("in profile popup the user sets display name to \"|any|\"")
def step(context, display_name):
    _statusMain.set_profile_popup_display_name(display_name)

@When("the user changes the password from |any| to |any|")
def step(context: any, oldPassword: str, newPassword: str):
    _settingsScreen.change_user_password(oldPassword, newPassword)

#########################
### VERIFICATIONS region:
#########################
    
@Then("the address |any| is displayed in the wallet")
def step(context: any, address: str):
    _settingsScreen.verify_address(address)

@Then("the account \"|any|\" is not in the list of accounts")
def step(context: any, account_name):
    _settingsScreen.verify_no_account(account_name) 

@Then("the default account is updated to be named \"|any|\" with color \"|any|\"")
def step(context, new_name: str, new_color: str):
    _settingsScreen.verify_editedAccount(new_name, new_color)
    
@Then("the app is closed")
def step(context: any):
    _settingsScreen.verify_the_app_is_closed()

@Then("the user's display name should be \"|any|\"")
def step(context, display_name):
    _settingsScreen.verify_display_name(display_name)

@Then("the user's bio should be empty")
def step(context):
    _settingsScreen.verify_bio("")

@Then("the user's bio should be \"|any|\"")
def step(context, bio):
    _settingsScreen.verify_bio(bio)

@Then("the user's social links should be empty")
def step(context):
    _settingsScreen.verify_social_links("", "", "", "")

@Then("the user's social links should be: \"|any|\", personal site: \"|any|\", \"|any|\": \"|any|\"")
def step(context, twitter, personal_site, custom_link_name, custom_link):
    _settingsScreen.verify_social_links(twitter, personal_site, custom_link_name, custom_link)

@Then("the application displays |any| as the selected language")
def step(context, native):
    _languageScreen.verify_current_language(native)
    # TODO: Verify some texts have been changed in the application (not done now bc translations are inconsistent 
    # and not all expected languages have the same texts translated
    
@Then("the backup seed phrase indicator is not displayed")
def step(context):
    _settingsScreen.verify_seed_phrase_indicator_not_visible()
    
@Then("the user appears offline")
def step(context: any):
    _statusMain.user_is_offline()
        
@Then("the user appears online")
def step(context: any):
    _statusMain.user_is_online()
         
@Then("the user status is automatic")
def step(context: any):
    _statusMain.user_is_set_to_automatic()   

@Then("in profile popup the user's display name should be \"|any|\"")
def step(context, display_name):
    _statusMain.verify_profile_popup_display_name(display_name)
    
###########################################################################
### COMMON methods used in different steps given/when/then region:
########################################################################### 
    
def the_user_opens_app_settings_screen():
    common_init_steps.the_user_opens_app_settings_screen()
    
def the_user_opens_the_messaging_settings():
    _settingsScreen.open_messaging_settings()
    
def the_user_activates_wallet():
    wallet_init_steps.the_user_activates_wallet()
    
def the_user_opens_the_wallet_settings():
    wallet_init_steps.the_user_opens_the_wallet_settings()