import steps.commonInitSteps as init_steps
from screens.StatusWelcomeScreen import StatusWelcomeScreen
from screens.StatusMainScreen import StatusMainScreen
import builtins

_welcomeScreen = StatusWelcomeScreen()
_mainScreen = StatusMainScreen()

#########################
### PRECONDITIONS region:
######################### 

@Given("A first time user lands on the status desktop and generates new key")
def step(context):
    init_steps.a_first_time_user_lands_on_and_generates_new_key(context)

@Given("A first time user lands on the status desktop and navigates to import seed phrase")
def step(context):
    init_steps.a_first_time_user_lands_on_and_navigates_to_import_seed_phrase(context)
    
@Given("the user lands on the signed in app")
def step(context):
    init_steps.the_user_lands_on_the_signed_in_app()
    
@Given("the user signs up with username \"|any|\" and password \"|any|\"")
def step(context, username, password):
    init_steps.the_user_signs_up(username, password)
    
@Given("the user signs up with profileImage \"|any|\", username \"|any|\" and password \"|any|\"")
def step(context, profileImageUrl: str, username: str, password: str):
    _welcomeScreen.input_username_profileImage_password_and_finalize_sign_up("file:///"+context.userData["fixtures_root"]+"images/"+profileImageUrl, username, password)
    
@Given("my profile modal has the updated profile image")
def step(context):
    _mainScreen.profile_modal_image_is_updated()
    
@Given("the profile setting has the updated profile image")
def step(context):
    _mainScreen.profile_settings_image_is_updated()
    
@Given("a screenshot of the profileImage is taken")
def step(context):
    _welcomeScreen.grab_screenshot()
    
@Given("the user inputs username \"|any|\"")
def step(context, username):
    the_user_inputs_username(username)

#########################
### ACTIONS region:
########################
@When("the user lands on the status desktop and generates new key")
def step(context):
    init_steps.a_user_lands_on_and_generates_new_key(context)

@When("the user signs up with username \"|any|\" and password \"|any|\"")
def step(context, username, password):
    init_steps.the_user_signs_up(username, password)

@When("the user signs up again with username \"|any|\" and password \"|any|\"")
def step(context, username, password):
    init_steps.the_user_signs_again_up(username, password)
    
@When("the user inputs username \"|any|\"")
def step(context, username):
    the_user_inputs_username(username)
    
@When("the user inputs the seed phrase \"|any|\"")
def step(context, seed_phrase):
    init_steps.the_user_inputs_the_seed_phrase(seed_phrase)
    
@When("the user logs in with password \"|any|\"")
def step(context, password: str):
    _welcomeScreen.enter_password(password)
    
@When("the user inputs the new password \"|any|\"")
def step(context, password: str):
    _welcomeScreen.type_new_password(password)
    
@When("the user inputs the new confirmation password \"|any|\"")
def step(context, password: str):
    _welcomeScreen.type_confirm_password(password)
    
@When("the user lands on the signed in app")
def step(context):
    the_user_lands_on_the_signed_in_app()

@When("the user maximizes the \"|any|\" application window")
def step(context, index):
    init_steps.switch_aut_context(context, builtins.int(index)-1)
    
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
 
@Then("the profile navigation bar has the updated profile image")
def step(context):
    _mainScreen.profile_image_is_updated()
    filesMngr.delete_created_searchImage(context.userData["search_images"] + "profiletestimage.png")
    filesMngr.delete_created_searchImage(context.userData["search_images"] + "loginUserName.png")
    
###########################################################################
### COMMON methods used in different steps given/when/then region:
########################################################################### 
def the_user_inputs_username(username: str):
    _welcomeScreen.input_username(username)
    
def the_user_lands_on_the_signed_in_app():
    init_steps.the_user_lands_on_the_signed_in_app()
