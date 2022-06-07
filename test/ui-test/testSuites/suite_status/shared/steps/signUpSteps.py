
from screens.StatusWelcomeScreen import StatusWelcomeScreen
from screens.StatusMainScreen import StatusMainScreen

_welcomeScreen = StatusWelcomeScreen() 

@Given("A first time user lands on the status desktop and generates new key") 
def step(context):
    _welcomeScreen.agree_terms_conditions_and_generate_new_key()

    
@When("user inputs username |any| and password |any|") 
def step(context, username, password):
    _welcomeScreen.input_username_and_password_and_finalize_sign_up(username, password)
    

@When("the user inputs username |any|") 
def step(context, username):
    _welcomeScreen.input_username(username)



@Then("the user lands on the signed in app")
def step(context):
    StatusMainScreen()