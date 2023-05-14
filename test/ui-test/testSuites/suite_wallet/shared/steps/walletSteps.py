import walletInitSteps as wallet_init_steps

from screens.StatusMainScreen import StatusMainScreen
from screens.StatusWalletScreen import StatusWalletScreen
from screens.StatusWalletScreen import MainWalletRightClickMenu
from screens.StatusWalletScreen import NOT_APPLICABLE, VALUE_YES
from scripts.decorators import verify_screenshot
from common.Common import str_to_bool

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
    wallet_init_steps.the_user_opens_wallet_screen()

@When("the user clicks on the default wallet account")
def step(context):
    _walletScreen.click_default_wallet_account()

@When("the user adds a watch only account \"|any|\" with \"|any|\" color \"|any|\" and emoji \"|any|\" via \"|any|\"")
@verify_screenshot
def step(context, address, name, color, emoji, via_right_click_menu):
    if via_right_click_menu == VALUE_YES:
        _walletScreen.click_option_from_left_part_right_click_menu(MainWalletRightClickMenu.ADD_WATCH_ONLY_ACCOUNT_ACTION_PLACEHOLDER.value)
    else:
        _walletScreen.open_add_account_popup()
    _walletScreen.add_account_popup_change_account_name(name)
    _walletScreen.add_account_popup_change_account_color(color)
    _walletScreen.add_account_popup_change_account_emoji(emoji)
    _walletScreen.add_account_popup_set_watch_only_account_as_selected_origin(address)
    _walletScreen.add_account_popup_do_primary_action()

@When("the user adds a generated account with \"|any|\" color \"|any|\" and emoji \"|any|\" via \"|any|\" using password \"|any|\"")
@verify_screenshot
def step(context, name, color, emoji, via_right_click_menu, password):
    if via_right_click_menu == VALUE_YES:
        _walletScreen.click_option_from_left_part_right_click_menu(MainWalletRightClickMenu.ADD_NEW_ACCOUNT_ACTION_PLACEHOLDER.value)
    else:
        _walletScreen.open_add_account_popup()
    _walletScreen.add_account_popup_change_account_name(name)
    _walletScreen.add_account_popup_change_account_color(color)
    _walletScreen.add_account_popup_change_account_emoji(emoji)
    _walletScreen.add_account_popup_do_primary_action(password)

@When("the user adds to \"|any|\" a custom generated account with \"|any|\" color \"|any|\" and emoji \"|any|\" using password \"|any|\" and setting custom path index \"|any|\" or selecting address with \"|any|\" using \"|any|\"")
@verify_screenshot
def step(context, keypair_name, name, color, emoji, password, index, order, is_ethereum_root):
    _walletScreen.open_add_account_popup()
    _walletScreen.add_account_popup_change_account_name(name)
    _walletScreen.add_account_popup_change_account_color(color)
    _walletScreen.add_account_popup_change_account_emoji(emoji)
    if keypair_name != NOT_APPLICABLE:
        _walletScreen.add_account_popup_change_origin_by_keypair_name(keypair_name)
    _walletScreen.add_account_popup_open_edit_derivation_path_section(password)
    _walletScreen.add_account_popup_change_derivation_path(index, order, is_ethereum_root)
    _walletScreen.add_account_popup_do_primary_action()

@When("the user adds a private key account \"|any|\" with \"|any|\" color \"|any|\" and emoji \"|any|\" using password \"|any|\" making keypair with name \"|any|\"")
@verify_screenshot
def step(context, private_key, name, color, emoji, password, keypair_name):
    _walletScreen.open_add_account_popup()
    _walletScreen.add_account_popup_change_account_name(name)
    _walletScreen.add_account_popup_change_account_color(color)
    _walletScreen.add_account_popup_change_account_emoji(emoji)
    _walletScreen.add_account_popup_set_new_private_key_as_selected_origin(private_key, keypair_name)
    _walletScreen.add_account_popup_do_primary_action(password)

@When("the user adds an imported seed phrase account \"|any|\" with \"|any|\" color \"|any|\" and emoji \"|any|\" using password \"|any|\" making keypair with name \"|any|\"")
@verify_screenshot
def step(context, seed_phrase, name, color, emoji, password, keypair_name):
    _walletScreen.open_add_account_popup()
    _walletScreen.add_account_popup_change_account_name(name)
    _walletScreen.add_account_popup_change_account_color(color)
    _walletScreen.add_account_popup_change_account_emoji(emoji)
    _walletScreen.add_account_popup_set_new_seed_phrase_as_selected_origin(seed_phrase, keypair_name)
    _walletScreen.add_account_popup_do_primary_action(password)

@When("the user adds a generated seed phrase account with \"|any|\" color \"|any|\" and emoji \"|any|\" using password \"|any|\" making keypair with name \"|any|\"")
@verify_screenshot
def step(context, name, color, emoji, password, keypair_name):
    _walletScreen.open_add_account_popup()
    _walletScreen.add_account_popup_change_account_name(name)
    _walletScreen.add_account_popup_change_account_color(color)
    _walletScreen.add_account_popup_change_account_emoji(emoji)
    _walletScreen.add_account_popup_set_generated_seed_phrase_as_selected_origin(keypair_name)
    _walletScreen.add_account_popup_do_primary_action(password)

@When("the user adds new master key and go to use a Keycard")
def step(context):
    _walletScreen.open_add_account_popup()
    _walletScreen.add_account_popup_go_to_keycard_settings()

@When("the user edits an account with \"|any|\" to \"|any|\" with color \"|any|\" and emoji \"|any|\"")
def step(context, name, new_name, new_color, new_emoji):
    _walletScreen.click_option_from_right_click_menu_of_account_with_name(MainWalletRightClickMenu.EDIT_ACCOUNT_ACTION_PLACEHOLDER.value, name)
    _walletScreen.add_account_popup_change_account_name(new_name)
    _walletScreen.add_account_popup_change_account_color(new_color)
    _walletScreen.add_account_popup_change_account_emoji(new_emoji)
    _walletScreen.add_account_popup_do_primary_action()

@When("the user removes an account with name \"|any|\" and path \"|any|\" using password \"|any|\" and test cancel \"|any|\"")
def step(context, name, path, password, test_cancel):
    _walletScreen.click_option_from_right_click_menu_of_account_with_name(MainWalletRightClickMenu.DELETE_ACCOUNT_ACTION_PLACEHOLDER.value, name)
    _walletScreen.remove_account_popup_verify_account_account_to_be_removed(name, path)
    if test_cancel == VALUE_YES:
        _walletScreen.remove_account_popup_do_cancel_action()
        _walletScreen.click_option_from_right_click_menu_of_account_with_name(MainWalletRightClickMenu.DELETE_ACCOUNT_ACTION_PLACEHOLDER.value, name)
        _walletScreen.remove_account_popup_verify_account_account_to_be_removed(name, path)
    _walletScreen.remove_account_popup_do_remove_action(True if path != NOT_APPLICABLE else False, password)

@When("the user sends a transaction to himself from account \"|any|\" of \"|any|\" \"|any|\" on \"|any|\" with password \"|any|\"")
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


#########################
### VERIFICATIONS region:
#########################

@Then("the account is correctly displayed with \"|any|\" and \"|any|\" and emoji unicode \"|any|\"")
def step(context, name, color, emoji_unicode):
    _walletScreen.verify_account_existence(name, color, emoji_unicode)

@Then("settings keycard section is opened")
def step(context):
    _walletScreen.verify_keycard_settings_is_opened()

@Then("the account with \"|any|\" is not displayed")
def step(context, name):
    _walletScreen.verify_account_doesnt_exist(name)

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
