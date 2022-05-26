
from screens.StatusWelcomeScreen import StatusWelcomeScreen
from screens.StatusChatScreen import StatusChatScreen

welcomeScreen = StatusWelcomeScreen() 

@Given("A first time user lands on the status desktop and generates new key") 
def step(context):
    welcomeScreen.agree_terms_conditions_and_generate_new_key()

    
@When("user inputs username |any| and password |any|") 
def step(context, username, password):
    welcomeScreen.input_username_and_password_and_finalize_sign_up(username, password)


@Then("the user lands on the signed in app")
def step(context):
    StatusChatScreen()