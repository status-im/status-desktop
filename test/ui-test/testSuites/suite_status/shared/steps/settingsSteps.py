
from screens.StatusMainScreen import StatusMainScreen
from screens.SettingsScreen import SettingsScreen

_statusMain = StatusMainScreen()
_settingsScreen =SettingsScreen()


@When("the user opens app settings screen")
def step(context):
    _statusMain.open_settings()


@When("the user activates wallet")
def step(context):
    _settingsScreen.activate_wallet()

