from screens.StatusWelcomeScreen import StatusWelcomeScreen
from screens.StatusMainScreen import StatusMainScreen

_welcomeScreen = StatusWelcomeScreen()


@Given("A first time user lands on the status desktop and generates new key")
def step(context):
    _welcomeScreen.agree_terms_conditions_and_generate_new_key()


@Given("A first time user lands on the status desktop and navigates to import seed phrase")
def step(context):
    _welcomeScreen.agree_terms_conditions_and_navigate_to_import_seed_phrase()


@When("user signs up with username |any| and password |any|")
def step(context, username, password):
    _welcomeScreen.input_username_and_password_and_finalize_sign_up(username, password)


@When("the user inputs username |any|")
def step(context, username):
    _welcomeScreen.input_username(username)


@Then("the user lands on the signed in app")
def step(context): 
    StatusMainScreen()
    
@When("The user inputs |any| seed phrases")
def step(context, seedPhraseAmount):
    table = context.table
    for row in table[1:]:
        _welcomeScreen.input_seed_phrase(row[0], seedPhraseAmount, row[1])
