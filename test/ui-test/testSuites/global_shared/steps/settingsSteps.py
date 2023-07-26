import steps.commonInitSteps as init_steps
from screens.SettingsScreen import SettingsScreen
from screens.StatusLanguageScreen import StatusLanguageScreen
from screens.StatusMainScreen import StatusMainScreen

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

@Given("the user opens the wallet section")
def step(context: any):
    init_steps.the_user_opens_the_wallet_section()

@Given("the user toggles test networks")
def step(context: any):
    init_steps.the_user_toggles_test_networks()

@Given("the user opens the wallet settings")
def step(context: any):
    the_user_opens_the_wallet_settings()

@Given("the user opens the profile settings")
def step(context: any):
    the_user_opens_the_profile_settings()

@Given("the user's display name is \"|any|\"")
def step(context, display_name: str):
    if "popup" in context.userData["scenario_name"]:
        the_user_display_name_in_profile_popup_is(display_name)
    else:
        the_user_display_name_is(display_name)

@Given("the user's bio is empty")
def step(context):
    _settingsScreen.profile_settings.verify_bio("")

@Given("the user's social links are empty")
def step(context):
    _settingsScreen.profile_settings.verify_social_no_links()

@Given("the user opens own profile popup")
def step(context: any):
    the_user_opens_own_profile_popup()

@Given("Application Settings \"|any|\" is open")
def step(context: any, settings_type:str):
    #TODO: Implement parameters for settings
    _settingsScreen.open_advanced_settings()

@Given("\"|any|\" is toggled on under Experimental features")
def step(context: any, settings_type:str):
    _settingsScreen.toggle_experimental_feature(settings_type)

@Given("the user opens the community named \"|any|\"")
def step(context, community_name:str):
    _settingsScreen.open_community(community_name)    
    
#########################
### ACTIONS region:
#########################

@When("the user activates the link preview if it is deactivated")
def step(context: any):
    _settingsScreen.activate_link_preview_if_dectivated()

@When("the user activates tenor GIFs preview")
def step(context: any):
    _settingsScreen.the_user_activates_tenor_gif_preview()

@When("the user opens app settings screen")
def step(context: any):
    the_user_opens_app_settings_screen()

@When("the user opens the messaging settings")
def step(context: any):
    the_user_opens_the_messaging_settings()

@When("the user opens the contacts settings")
def step(context: any):
    the_user_opens_the_contact_settings()

@When("the user activates image unfurling")
def step(context: any):
    _settingsScreen.activate_image_unfurling()

@When("the user opens the wallet settings")
def step(context: any):
    the_user_opens_the_wallet_settings()

@When("the user adds a generated account with \"|any|\" color \"|any|\" and emoji \"|any|\" in Settings")
def step(context, name, color, emoji):
    account_popup = _settingsScreen.open_add_new_account_popup()
    account_popup.set_name(name).set_emoji(emoji).set_color(color).save()
    AuthenticatePopup().wait_until_appears().authenticate()
    account_popup.wait_until_hidden()
    
@Then("the account is present with \"|any|\" and \"|any|\" and emoji unicode \"|any|\" in the accounts list in Settings")
def step(context: any, account_name, color, emoji):
    _settingsScreen._find_account_index(account_name)


@When("the user deletes the account \"|any|\" with password \"|any|\"")
def step(context: any, account_name: str, password: str):
    _statusMain.open_settings()
    _settingsScreen.delete_account(account_name, password)

@When("the user selects the default Status account")
def step(context: any):
    _settingsScreen.select_default_account()

@When("the user edits default Status account to \"|any|\" name and \"|any|\" color")
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
    _settingsScreen.menu.sign_out_and_quit()

@Given("the user opens the communities settings")
@When("the user opens the communities settings")
def step(context: any):
    _settingsScreen.open_communities_section()

@When("the user leaves \"|any|\" community")
def step(context: any, communityName):
    _settingsScreen.leave_community(communityName)

@When("the user opens the profile settings")
def step(context: any):
    the_user_opens_the_profile_settings()

@When("the user sets display name to \"|any|\"")
def step(context, display_name):
    _settingsScreen.profile_settings.display_name = display_name

@When("the user backs up the wallet seed phrase")
def step(context):
    _settingsScreen.check_backup_seed_phrase_workflow()


@When("the user sets social links to:")
def step(context):
    profile_settings = _settingsScreen.profile_settings
    profile_settings.social_links = context.table
    profile_settings.save_changes()

@When("the user sets bio to \"|any|\"")
def step(context, bio):
    _settingsScreen.profile_settings.bio = bio

@When("the users switches state to offline")
def step(context: any):
    _statusMain.set_user_state_offline()

@When("the users switches state to online")
def step(context: any):
    _statusMain.set_user_state_online()

@When("the users switches state to automatic")
def step(context: any):
    _statusMain.set_user_state_to_automatic()

@When("the user changes the password from |any| to |any|")
def step(context: any, oldPassword: str, newPassword: str):
    _settingsScreen.profile_settings.open_change_password_popup().change_password(oldPassword, newPassword)

@When("the user sends a contact request to the chat key \"|any|\" with the reason \"|any|\"")
def step(context: any, chat_key: str, reason: str):
    _settingsScreen.add_contact_by_chat_key(chat_key, reason)

@When("the user sends a contact request with the reason \"|any|\"")
def step(context: any, reason: str):
    _settingsScreen.send_contact_request_via_profile_popup(reason)

@When("the user opens own profile popup")
def step(context: any):
    the_user_opens_own_profile_popup()

@When("the user navigates to edit profile")
def step(context: any):
    _statusMain.navigate_to_edit_profile()

@When("the user closes the popup")
def step(context: any):
    _statusMain.close_popup()

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

@Then("the user's display name is \"|any|\"")
def step(context, display_name: str):
    if "popup" in context.userData["scenario_name"]:
        the_user_display_name_in_profile_popup_is(display_name)
    else:
        the_user_display_name_is(display_name)

@Then("the user's bio is \"|any|\"")
def step(context, bio):
    _settingsScreen.profile_settings.verify_bio(bio)

@Then("the user's social links are:")
def step(context):
    _settingsScreen.profile_settings.verify_social_links(context.table)

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

@Then("the contact request for chat key \"|any|\" is present in the pending requests tab")
def step(context, chat_key: str):
    _settingsScreen.verify_contact_request(chat_key)

@Then("a contact request is present in the sent pending requests tab")
def step(context):
    _settingsScreen.verify_there_is_a_sent_contact_request()

@Then("a contact request is present in the received pending requests tab")
def step(context):
    _settingsScreen.verify_there_is_a_received_contact_request()

@Then("the user opens the community named \"|any|\"")
def step(context, community_name:str):
    _settingsScreen.open_community(community_name)

###########################################################################
### COMMON methods used in different steps given/when/then region:
###########################################################################

def the_user_opens_app_settings_screen():
    init_steps.the_user_opens_app_settings_screen()

def the_user_opens_the_messaging_settings():
    _settingsScreen.open_messaging_settings()

def the_user_opens_the_contact_settings():
    _settingsScreen.open_contacts_settings()

def the_user_opens_the_wallet_settings():
    _settingsScreen.open_wallet_settings()

def the_user_opens_the_profile_settings():
    _settingsScreen.profile_settings

def the_user_display_name_is(display_name: str):
    _settingsScreen.profile_settings.verify_display_name(display_name)

def the_user_display_name_in_profile_popup_is(display_name: str):
    _statusMain.verify_profile_popup_display_name(display_name)

def the_user_opens_own_profile_popup():
    _statusMain.open_own_profile_popup()
