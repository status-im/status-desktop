from screens.StatusLoginScreen import StatusLoginScreen

_loginScreen = StatusLoginScreen()


@When("the user logs in with password |any|")
def step(context, password):
    _loginScreen.login(password)
    
@When("the user |any| logs in with password |any|")
def step(context, username, password):
    _loginScreen.login(username, password)

@Then("the user is NOT able to login to Status Desktop application")
def step(context):
    _loginScreen.verify_error_message_is_displayed()
