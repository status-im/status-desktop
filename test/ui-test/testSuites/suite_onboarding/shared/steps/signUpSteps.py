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
    
@When("The user inputs the seed phrase |any|")
def step(context, seed_phrase):
    _welcomeScreen.input_seed_phrase(seed_phrase)

@Then("the user lands on the signed in app")
def step(context):
    _mainScreen.is_ready()  
      
@Then("the invalid seed text is visible")
def step(context):
    _welcomeScreen.seed_phrase_visible()
    
@When("the user logs in with password |any|")
def step(context, password: str):
    _welcomeScreen.enter_password(password)

@Then("the user is online")
def step(context):
    _mainScreen.user_is_online()

@When("the user signs up with profileImage |any|, username |any| and password |any|")
def step(context, profileImageUrl, username, password):
    _welcomeScreen.input_username_profileImage_password_and_finalize_sign_up("file:///"+context.userData["fixtures_root"]+"images/"+profileImageUrl, username, password)
 
@Then("my profile modal has the updated profile image")
def step(context):
    _welcomeScreen.profile_modal_image_is_updated()
    
@Then("the profile setting has the updated profile image")
def step(context):
    _welcomeScreen.profile_settings_image_is_updated()

@When("a screenshot of the profileImage is taken")
def step(context):
    _welcomeScreen.grab_screenshot()
 
@Then("the profile navigation bar has the updated profile image")
def step(context):
    _welcomeScreen.profile_image_is_updated()
    delete_created_searchImage(context.userData["search_images"] +"profiletestimage.png")
    delete_created_searchImage(context.userData["search_images"]+"loginUserName.png")

