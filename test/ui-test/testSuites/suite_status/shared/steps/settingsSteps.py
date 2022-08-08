
from screens.StatusMainScreen import StatusMainScreen
from screens.SettingsScreen import SettingsScreen

_statusMain = StatusMainScreen()
_settingsScreen = SettingsScreen()


@When("the user opens app settings screen")
def step(context: any):
    _statusMain.open_settings()

@When("the user opens the wallet settings")
def step(context: any):
    _settingsScreen.open_wallet_settings()
    
@When("the user activates wallet and opens the wallet settings")
def step(context: any):
    _settingsScreen.activate_open_wallet_settings()

@When("the user activates wallet and opens the wallet section")
def step(context: any):
    _settingsScreen.activate_open_wallet_section()

@When("the user deletes the account |any|")
def step(context: any, account_name: str):
    _statusMain.open_settings()
    _settingsScreen.delete_account(account_name)
    
@When("the user toggles test networks")
def step(context: any):
    _settingsScreen.toggle_test_networks()
    
@Then("the address |any| is displayed in the wallet")
def step(context: any, address: str):
    _settingsScreen.verify_address(address)


@Then("the account |any| is not in the list of accounts")
def step(context: any, account_name):
    _settingsScreen.verify_no_account(account_name) 
 
