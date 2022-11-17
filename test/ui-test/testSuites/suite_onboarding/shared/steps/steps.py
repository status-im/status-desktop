from screens.StatusWelcomeScreen import StatusWelcomeScreen

_welcomeScreen = StatusWelcomeScreen()

@Then("the password strength indicator is \"|any|\"")
def step(context, strength):
    _welcomeScreen.validate_password_strength(strength)