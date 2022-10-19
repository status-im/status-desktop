from screens.StatusLoginScreen import StatusLoginScreen

_loginScreen = StatusLoginScreen()
 
#########################
### PRECONDITIONS region:
######################### 
@Given("the user \"|any|\" logs in with password \"|any|\"")
def step(context, username, password):
    the_user_any_logs_in_with_password(username, password)

#########################
### ACTIONS region:
#########################
   
@When("the user \"|any|\" logs in with password \"|any|\"")
def step(context, username, password):
    the_user_any_logs_in_with_password(username, password)

#########################
### VERIFICATIONS region:
#########################

@Then("the user is NOT able to login to Status Desktop application")
def step(context):
    _loginScreen.verify_error_message_is_displayed()

###########################################################################
### COMMON methods used in different steps given/when/then region:
########################################################################### 
def the_user_any_logs_in_with_password(username: str, password: str):
    _loginScreen.login(username, password)