
from screens.StatusMainScreen import StatusMainScreen
from screens.SettingsScreen import SettingsScreen

_statusMain = StatusMainScreen()
_settingsScreen =SettingsScreen()


@When("the user opens app settings screen")
def step(context: any):
    _statusMain.open_settings()


@When("the user activates wallet and opens the wallets section")
def step(context: any):
    _settingsScreen.activate_open_wallet_section()
    
@Then("the |any| seed phrase address is |any| displayed in the wallet")
def step(context: any, phrase :str, address: str):
    _settingsScreen.verify_address(phrase, address)
 