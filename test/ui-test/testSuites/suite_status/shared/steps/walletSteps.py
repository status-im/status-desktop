from screens.StatusWalletScreen import StatusWalletScreen

_statusMain = StatusMainScreen()
_walletScreen = StatusWalletScreen()

@When("the user opens wallet screen")
def step(context):
    _statusMain.open_wallet()
    
@When("the user accepts the signing phrase")
def step(context):
    _walletScreen.accept_signing_phrase()

@When("the user adds watch only account with |any| and |any|")
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
    
@When("the user adds a saved address name |any| and address |any|")
def step(context, name, address):
    _walletScreen.add_saved_address(name, address)

@Then("the new account |any| is added")
def step(context, account_name):
    _walletScreen.verify_account_name_is_present(account_name)

@Then("the transaction is in progress")
def step(context):
    _walletScreen.verify_transaction()
    
@Then("the name |any| is in the list of saved addresses")
def step(context, name: str):
    _walletScreen.verify_saved_address_exists(name) 
    