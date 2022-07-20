from screens.StatusWalletScreen import StatusWalletScreen

_walletScreen = StatusWalletScreen()

@When("the user accept the signing phrase")
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

@Then("the new account |any| is added")
def step(context, account_name):
    _walletScreen.verify_account_name_is_present(account_name)