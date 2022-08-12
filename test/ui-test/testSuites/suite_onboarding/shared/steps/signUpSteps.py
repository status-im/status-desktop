from screens.StatusWelcomeScreen import StatusWelcomeScreen
from screens.StatusMainScreen import StatusMainScreen

_welcomeScreen = StatusWelcomeScreen()
_mainScreen = StatusMainScreen()



@Given("A first time user lands on the status desktop and generates new key")
def step(context):
    erase_directory(context.userData["status_data_folder_path"])
    startApplication(context.userData["aut_name"])
    _welcomeScreen.agree_terms_conditions_and_generate_new_key()


@Given("A first time user lands on the status desktop and navigates to import seed phrase")
def step(context):
    erase_directory(context.userData["status_data_folder_path"])
    startApplication(context.userData["aut_name"])
    _welcomeScreen.agree_terms_conditions_and_navigate_to_import_seed_phrase()


@When("user signs up with username |any| and password |any|")
def step(context, username, password):
    _welcomeScreen.input_username_and_password_and_finalize_sign_up(username, password)


@When("the user inputs username |any|")
def step(context, username):
    _welcomeScreen.input_username(username)


@Then("the user lands on the signed in app")
def step(context): 
    _mainScreen
    
    
@When("The user inputs the seed phrase |any|")
def step(context, seed_phrase):
    _welcomeScreen.input_seed_phrase(seed_phrase)

    
@Then("the invalid seed text is visible")
def step(context):
    _welcomeScreen.seed_phrase_visible()
    
@Then("the user is online")
def step(context):
    _mainScreen.user_is_online()
