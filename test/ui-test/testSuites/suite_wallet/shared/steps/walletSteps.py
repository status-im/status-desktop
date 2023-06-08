from common.Common import str_to_bool
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusWalletScreen import StatusWalletScreen
from screens.StatusWalletScreen import VALUE_YES
from screens.components.authenticate_popup import AuthenticatePopup
from scripts.decorators import verify_screenshot

_statusMain = StatusMainScreen()
_walletScreen = StatusWalletScreen()


#########################
### PRECONDITIONS region:
#########################

@Given("the user accepts the signing phrase")
def step(context):
    the_user_accepts_the_signing_phrase()


#########################
### ACTIONS region:
#########################

@When("the user opens wallet section")
def step(context):
    walletInitSteps.the_user_opens_wallet_screen()

@When("the user clicks on the default wallet account")
def step(context):
    _walletScreen.click_default_wallet_account()


@When("the user selects wallet account with \"|any|\"")
def step(context, name):
    _walletScreen.left_panel.select_account(name)


@When("the user adds a watch only account \"|any|\" with \"|any|\" color \"|any|\" and emoji \"|any|\" via \"|any|\"")
@verify_screenshot
def step(context, address, name, color, emoji, via_right_click_menu):
    if via_right_click_menu == VALUE_YES:
        account_popup = _walletScreen.left_panel.open_add_watch_anly_account_popup()
    else:
        account_popup = _walletScreen.left_panel.open_add_account_popup()
    account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_eth_address(address).save()
    account_popup.wait_until_hidden()


@When("the user adds a generated account with \"|any|\" color \"|any|\" and emoji \"|any|\" via \"|any|\"")
@verify_screenshot
def step(context, name, color, emoji, via_right_click_menu):
    if via_right_click_menu == VALUE_YES:
        account_popup = _walletScreen.left_panel.open_add_new_account_popup()
    else:
        account_popup = _walletScreen.left_panel.open_add_account_popup()
    account_popup.set_name(name).set_emoji(emoji).set_color(color).save()
    AuthenticatePopup().wait_until_appears().authenticate()
    account_popup.wait_until_hidden()


@When("the user adds a private key account \"|any|\" with \"|any|\" color \"|any|\" and emoji \"|any|\"")
@verify_screenshot
def step(context, private_key, name, color, emoji):
    account_popup = _walletScreen.left_panel.open_add_account_popup()
    account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_private_key(private_key).save()
    AuthenticatePopup().wait_until_appears().authenticate()
    account_popup.wait_until_hidden()


@When("the user adds an imported seed phrase account \"|any|\" with \"|any|\" color \"|any|\" and emoji \"|any|\"")
@verify_screenshot
def step(context, seed_phrase, name, color, emoji):
    account_popup = _walletScreen.left_panel.open_add_account_popup()
    account_popup.set_name(name)
    account_popup.set_emoji(emoji)
    account_popup.set_color(color)
    account_popup.set_origin_seed_phrase(seed_phrase.split())
    account_popup.save()
    AuthenticatePopup().wait_until_appears().authenticate()
    account_popup.wait_until_hidden()


@When("the user adds a custom generated account with \"|any|\" color \"|any|\" emoji \"|any|\" and derivation \"|any|\" \"|any|\"")
@verify_screenshot
def step(context, name, color, emoji, derivation_path, generated_address_index):
    account_popup = _walletScreen.left_panel.open_add_account_popup()
    account_popup.set_name(name)
    account_popup.set_emoji(emoji)
    account_popup.set_color(color)
    account_popup.set_derivation_path(derivation_path, generated_address_index)
    account_popup.save()

@When("the user adds to \"|any|\" a custom generated account with \"|any|\" color \"|any|\" emoji \"|any|\" and derivation \"|any|\" \"|any|\"")
@verify_screenshot
def step(context, keypair_name, name, color, emoji, derivation_path, generated_address_index):
    account_popup = _walletScreen.left_panel.open_add_account_popup()
    account_popup.set_name(name)
    account_popup.set_emoji(emoji)
    account_popup.set_color(color)
    account_popup.set_derivation_path(derivation_path, generated_address_index)
    account_popup.set_origin_keypair(keypair_name)
    account_popup.save()


@When(
    "the user adds a generated seed phrase account with \"|any|\" color \"|any|\" emoji \"|any|\" and keypair \"|any|\"")
def step(context, name, color, emoji, keypair_name):
    account_popup = _walletScreen.left_panel.open_add_account_popup()
    account_popup.set_name(name)
    account_popup.set_emoji(emoji)
    account_popup.set_color(color)
    account_popup.set_origin_new_seed_phrase(keypair_name)
    account_popup.save()
    AuthenticatePopup().wait_until_appears().authenticate()
    account_popup.wait_until_hidden()


@When("the user adds new master key and go to use a Keycard")
def step(context):
    _walletScreen.left_panel.open_add_account_popup()
    _walletScreen.add_account_popup_go_to_keycard_settings()


@When("the user edits an account with \"|any|\" to \"|any|\" with color \"|any|\" and emoji \"|any|\"")
def step(context, name, new_name, new_color, new_emoji):
    account_popup = _walletScreen.left_panel.open_edit_account_popup(name)
    account_popup.set_name(new_name)
    account_popup.set_emoji(new_emoji)
    account_popup.set_color(new_color)
    account_popup.save()


@When("the user removes account \"|any|\"")
def step(context, name):
    _walletScreen.left_panel.delete_account(name).confirm()

@When("the user opens All accounts view")
def step(context):
    _walletScreen.left_panel.open_all_accounts_view()


@When("the user start removing account \"|any|\" and cancel it")
def step(context, name):
    _walletScreen.left_panel.delete_account(name).cancel()


@When("the user removes account \"|any|\" with agreement")
def step(context, name):
    _walletScreen.left_panel.delete_account(name).agree_and_confirm()


@When(
    "the user sends a transaction to himself from account \"|any|\" of \"|any|\" \"|any|\" on \"|any|\" with password \"|any|\"")
def step(context, account_name, amount, token, chain_name, password):
    _walletScreen.send_transaction(account_name, amount, token, chain_name, password)

@When("the user adds a saved address named \"|any|\" and address \"|any|\"")
def step(context, name, address):
    _walletScreen.add_saved_address(name, address)

@When("the user adds a saved address named \"|any|\" and ENS name \"|any|\"")
def step(context, name, ens_name):
    _walletScreen.add_saved_address(name, ens_name)

@When("the user edits a saved address with name \"|any|\" to \"|any|\"")
def step(context, name, new_name):
    _walletScreen.edit_saved_address(name, new_name)


@When("the user deletes the saved address with name \"|any|\"")
def step(context, name):
    _walletScreen.delete_saved_address(name)


@When("the user toggles favourite for the saved address with name \"|any|\"")
def step(context, name):
    _walletScreen.toggle_favourite_for_saved_address(name)


@When("the user toggles the network |any|")
def step(context, network_name):
    _walletScreen.toggle_network(network_name)

@When("the user clicks Hide / Show watch-only button")
def step(context):   
    _walletScreen.click_hide_show_watch_only()  


#########################
### VERIFICATIONS region:
#########################

@Then("the account is correctly displayed with \"|any|\" and \"|any|\" and emoji unicode \"|any|\" in accounts list")
def step(context, name, color, emoji_unicode):
    _walletScreen.verify_account_existence(name, color, emoji_unicode)


@Then("settings keycard section is opened")
def step(context):
    _walletScreen.verify_keycard_settings_is_opened()


@Then("the account with \"|any|\" is not displayed")
def step(context, name):
    _walletScreen.verify_account_doesnt_exist(name)


@Then("the account with \"|any|\" is displayed")
def step(context, name):
    _walletScreen.verify_account_exist(name)


@Then("the user has a positive balance of \"|any|\"")
def step(context, symbol):
    _walletScreen.verify_positive_balance(symbol)


@Then("the transaction is in progress")
def step(context):
    _walletScreen.verify_transaction()

@Then("the name \"|any|\" is in the list of saved addresses")
def step(context, name: str):
    _walletScreen.verify_saved_address_exists(name)

@Then("the name \"|any|\" is not in the list of saved addresses")
def step(context, name: str):
    _walletScreen.verify_saved_address_doesnt_exist(name)

@Then("the collectibles are listed for the |any|")
def step(context, account_name: str):
    _walletScreen.verify_collectibles_exist(account_name)

@Then("the transactions are listed for the added account")
def step(context):
    _walletScreen.verify_transactions_exist()

@Then("the saved address \"|any|\" has favourite status \"|any|\"")
def step(context, name, favourite):
    _walletScreen.check_favourite_status_for_saved_address(name, str_to_bool(favourite))

###########################################################################
### COMMON methods used in different steps given/when/then region:
###########################################################################
