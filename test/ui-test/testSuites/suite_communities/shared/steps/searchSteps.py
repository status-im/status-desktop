from screens.StatusSearchScreen import StatusSearchScreen

_searchScreen = StatusSearchScreen()


@When("the user opens the search menu")
def step(context):
    _searchScreen.open_search_menu()
    
@When("the user searches for |any|")
def step(context, search_term):
    _searchScreen.search_for(search_term)
    
@When("the user searches the random message")
def step(context):
    _searchScreen.search_for(context.userData["randomMessage"])

@Then("the search menu shows |any| results")
def step(context, amount):
    _searchScreen.verify_number_of_results(amount)

@When("the user clicks on the search result for channel |any|")
def step(context, channel_name):
    _searchScreen.click_on_channel(channel_name)

@When("the user clicks on the search result for the random message")
def step(context):
    _searchScreen.click_on_message(context.userData["randomMessage"])