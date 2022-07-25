
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusCommunityPortalScreen import StatusCommunityPortalScreen
from screens.StatusCommunityScreen import StatusCommunityScreen

_statusCommunityScreen = StatusCommunityScreen()
_statusCommunitityPortal = StatusCommunityPortalScreen()
_statusMainScreen = StatusMainScreen()


@Then("the user opens the community portal section")
def step(context: any):
    _statusMainScreen.open_community_portal()

@Then("the user lands on the community portal section")
def step(context): 
    StatusCommunityPortalScreen()

@When("the user creates a community named |any|, with description |any|, intro |any| and outro |any|")
def step(context, community_name, community_description, community_intro, community_outro):
    _statusCommunitityPortal.create_community(community_name, community_description, community_intro, community_outro)

@Then("the user lands on the community named |any|")
def step(context, community_name):
    StatusCommunityScreen()
    _statusCommunityScreen.verify_community_name(community_name)
    
@When("the admin creates a community channel named |any|, with description |any|")
def step(context, community_channel_name, community_channel_description):
    _statusCommunityScreen.create_community_channel(community_channel_name, community_channel_description)
    
@When("the admin edits a community channel named |any| to the name |any|")
def step(context, community_channel_name, new_community_channel_name):
    _statusCommunityScreen.editCommunityChannel(community_channel_name, new_community_channel_name)
    
@Then("the user lands on the community channel named |any|")
def step(context, community_channel_name): 
    _statusCommunityScreen.verify_channel_name(community_channel_name)