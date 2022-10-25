from screens.StatusSearchScreen import StatusSearchScreen

_searchScreen = StatusSearchScreen()

#########################
### PRECONDITIONS region:
#########################
@Given("the user opens the search menu")
def step(context):
    _searchScreen.open_search_menu()
    
@Given("the user searches for \"|any|\"")
def step(context, search_term):
    _searchScreen.search_for(search_term)
    
#########################
### ACTIONS region:
#########################

@When("the user clicks on the search result for channel \"|any|\"")
def step(context, channel_name):
    _searchScreen.click_on_channel(channel_name) 
     
@When("the user searches the random message")
def step(context):
    _searchScreen.search_for(context.userData["randomMessage"])    

@When("the user clicks on the search result for the random message")
def step(context):
    _searchScreen.click_on_message(context.userData["randomMessage"])
    
#########################
### VERIFICATIONS region:
#########################

@Then("the search menu shows |integer| results")
def step(context, amount: int):
    _searchScreen.verify_number_of_results(amount)