from screens.StatusWalletScreen import StatusWalletScreen
from scripts.decorators import verify_screenshot
from common.Common import str_to_bool

_statusMain = StatusMainScreen()
_walletScreen = StatusWalletScreen()

@When("the user opens wallet screen")
def step(context):
    _statusMain.open_wallet()
    
@When("the user accepts the signing phrase")
def step(context):
    _walletScreen.accept_signing_phrase()

@When("the user adds watch only account with |any| and |any|")
@verify_screenshot
def step(context, account_name, address):
    _walletScreen.add_watch_only_account(account_name, address)

@When("the user generates a new account with |any| and |any|")
def step(context, account_name, password):
    _walletScreen.generate_new_account(account_name, password)

@When("the user imports a private key with |any| and |any| and |any|")
def step(context, account_name, password, private_key):
    _walletScreen.import_private_key(account_name, password, private_key)  
    
@When("the user imports a seed phrase with |any| and |any| and |any|")
def step(context, account_name, password, mnemonic):
    _walletScreen.import_seed_phrase(account_name, password, mnemonic)  

@When("the user sends a transaction to himself from account |any| of |any| |any| on |any| with password |any|")
def step(context, account_name, amount, token, chain_name, password):
    _walletScreen.send_transaction(account_name, amount, token, chain_name, password)
    
@When("the user adds a saved address named |any| and address |any|")
def step(context, name, address):
    _walletScreen.add_saved_address(name, address)

@When("the user edits a saved address with name |any| to |any|")
def step(context, name, new_name):
    _walletScreen.edit_saved_address(name, new_name)

@When("the user deletes the saved address with name |any|")
def step(context, name):
    _walletScreen.delete_saved_address(name)

@When("the user toggles favourite for the saved address with name |any|")
def step(context, name):
    _walletScreen.toggle_favourite_for_saved_address(name)

@Then("the saved address |any| has favourite status |any|")
def step(context, name, favourite):
    _walletScreen.check_favourite_status_for_saved_address(name, str_to_bool(favourite))

@When("the user toggles the network |any|")
def step(context, network_name):
    _walletScreen.toggle_network(network_name)

@Then("the user has a positive balance of |any|")
def step(context, symbol):
    _walletScreen.verify_positive_balance(symbol)

@Then("the new account |any| is added")
def step(context, account_name):
    _walletScreen.verify_account_name_is_present(account_name)

@Then("the transaction is in progress")
def step(context):
    _walletScreen.verify_transaction()
    
@Then("the name |any| is in the list of saved addresses")
def step(context, name: str):
    _walletScreen.verify_saved_address_exists(name) 
    
@Then("the name |any| is not in the list of saved addresses")
def step(context, name: str):
    _walletScreen.verify_saved_address_doesnt_exist(name)     
    
@Then("the collectibles are listed for the |any|")
def step(context, account_name: str):
    _walletScreen.verify_collectibles_exist(account_name)    
    
@Then("the transactions are listed for the added account")
def step(context):
    _walletScreen.verify_transactions_exist()