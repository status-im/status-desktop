from screens.StatusWalletScreen import StatusWalletScreen

_walletScreen = StatusWalletScreen()

@When("the user accept the signing phrase")
def step(context):
    _walletScreen.acceptSigningPhrase()

@When("the user add watch only account with |any| and |any|")
def step(context, account_name, address):
    _walletScreen.addWatchOnlyAccount(account_name, address)

@When("the user generate a new account with |any| and |any|")
def step(context, account_name, password):
    _walletScreen.generateNewAccount(account_name, password)

@When("the user import a private key with |any| and |any| and |any|")
def step(context, account_name, password, private_key):
    _walletScreen.importPrivateKey(account_name, password, private_key)  
    
@When("the user import a seed phrase with |any| and |any| and |any|")
def step(context, account_name, password, mnemonic):
    _walletScreen.importSeedPhrase(account_name, password, mnemonic)  

@Then("the new account |any| is added")
def step(context, account_name):
    _walletScreen.verifyAccountNameIsPresent(account_name)