from pathlib import Path
import sys
from screens.StatusWelcomeScreen import CreatePasswordView

_welcome_screen = CreatePasswordView()


@When('the user inputs the password \"|any|\"')
def step(context, password):
    _welcome_screen.new_password = str(password)


@Then("the password strength indicator is \"|any|\"")
def step(context, strength):
    _welcomeScreen.validate_password_strength(strength)