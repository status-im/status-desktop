
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

@When("the admin creates a community channel named |any|, with description |any| with the method |any|")
def step(context, community_channel_name, community_channel_description, method):
    _statusCommunityScreen.create_community_channel(community_channel_name, community_channel_description, method)

@When("the admin edits the current community channel to the name |any|")
def step(context, new_community_channel_name):
    _statusCommunityScreen.edit_community_channel(new_community_channel_name)

@Then("the user lands on the community channel named |any|")
def step(context, community_channel_name):
    _statusCommunityScreen.verify_channel_name(community_channel_name)

@When("the admin edits the current community to the name |any| and description |any| and color |any|")
def step(context, new_community_name, new_community_description, new_community_color):
    _statusCommunityScreen.edit_community(new_community_name, new_community_description, new_community_color)

@When("the admin goes back to the community")
def step(context):
    _statusCommunityScreen.go_back_to_community()

@When("the admin deletes current channel")
def step(context):
    _statusCommunityScreen.delete_current_community_channel()

@Then("the channel count is |any|")
def step(context, community_channel_count: int):
    _statusCommunityScreen.check_channel_count(community_channel_count)
