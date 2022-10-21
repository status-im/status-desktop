from steps.startupSteps import *
from screens.StatusWelcomeScreen import StatusWelcomeScreen
from screens.StatusMainScreen import StatusMainScreen

_welcomeScreen = StatusWelcomeScreen()
_mainScreen = StatusMainScreen()

#########################
### PRECONDITIONS region:
######################### 

@Given("A first time user lands on the status desktop and generates new key")
def step(context):
    a_first_time_user_lands_on_and_generates_new_key(context)    

@Given("A first time user lands on the status desktop and navigates to import seed phrase")
def step(context):
    a_first_time_user_lands_on_and_navigates_to_import_seed_phrase(context)
    
@Given("the user lands on the signed in app")
def step(context):
    the_user_lands_on_the_signed_in_app()

#########################
### ACTIONS region:
#########################

@When("user signs up with username \"|any|\" and password \"|any|\"")
def step(context, username, password):
    the_user_signs_up(username, password)

@When("the user inputs username |any|")
def step(context, username):
    _welcomeScreen.input_username(username) 
    
@When("The user inputs the seed phrase \"|any|\"")
def step(context, seed_phrase):
    the_user_inputs_the_seed_phrase(seed_phrase)
    
@When("the user logs in with password |any|")
def step(context, password: str):
    _welcomeScreen.enter_password(password)
    
@When("the user signs up with profileImage |any|, username |any| and password |any|")
def step(context, profileImageUrl, username, password):
    _welcomeScreen.input_username_profileImage_password_and_finalize_sign_up("file:///"+context.userData["fixtures_root"]+"images/"+profileImageUrl, username, password)

@When("a screenshot of the profileImage is taken")
def step(context):
    _welcomeScreen.grab_screenshot()
    
#########################
### VERIFICATIONS region:
#########################

@Then("the user lands on the signed in app")
def step(context):
    the_user_lands_on_the_signed_in_app()
      
@Then("the invalid seed text is visible")
def step(context):
    _welcomeScreen.seed_phrase_visible()
    
@Then("the user is online")
def step(context):
    _mainScreen.user_is_online()
 
@Then("my profile modal has the updated profile image")
def step(context):
    _welcomeScreen.profile_modal_image_is_updated()
    
@Then("the profile setting has the updated profile image")
def step(context):
    _welcomeScreen.profile_settings_image_is_updated()
 
@Then("the profile navigation bar has the updated profile image")
def step(context):
    _welcomeScreen.profile_image_is_updated()
    delete_created_searchImage(context.userData["search_images"] +"profiletestimage.png")
    delete_created_searchImage(context.userData["search_images"]+"loginUserName.png")
    
###########################################################################
### COMMON methods used in different steps given/when/then region:
########################################################################### 

