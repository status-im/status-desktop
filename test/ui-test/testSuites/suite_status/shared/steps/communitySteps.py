
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusCommunityPortalScreen import StatusCommunityPortalScreen
from screens.StatusCommunityScreen import StatusCommunityScreen

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
    _statusCommunitityPortal.createCommunity(community_name, community_description, community_intro, community_outro)


@Then("the user lands on the community named |any|")
def step(context, community_name):
    StatusCommunityScreen(community_name)