
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusCommunityPortalScreen import StatusCommunityPortalScreen
from screens.StatusCommunityScreen import StatusCommunityScreen

_statusCommunityScreen = StatusCommunityScreen()
_statusCommunitityPortal = StatusCommunityPortalScreen()
_statusMainScreen = StatusMainScreen()


@When("the user opens the community portal section")
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
    
@Then("the user lands on the channel named |any|")
def step(context, community_channel_name): 
    _statusCommunityScreen.verify_channel_name(community_channel_name)

@When("the admin creates a community category named |any|, with channels |any| and with the method |any|")
def step(context, community_category_name, community_channel_names, method):
    _statusCommunityScreen.create_community_category(community_category_name, community_channel_names, method)

@When("the admin edits category named |any| to the name |any| and channels |any|")
def step(context, community_category_name, new_community_category_name, community_channel_names):
    _statusCommunityScreen.edit_community_category(community_category_name, new_community_category_name, community_channel_names)

@When("the admin deletes category named |any|")
def step(context, community_category_name):
    _statusCommunityScreen.delete_community_category(community_category_name)

@Then("the category named |any| is missing")
def step(context, community_category_name): 
    _statusCommunityScreen.verify_category_name_missing(community_category_name)

@Then("the category named |any| has channels |any|")
def step(context, community_category_name, community_channel_names):
    _statusCommunityScreen.verify_category_contains_channels(community_category_name, community_channel_names)

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

@Then("the count of communities in navbar is |any|")
def step(context: any, expected_count: int):
    _statusMainScreen.verify_communities_count(expected_count)

@When("the user changes emoji of the current community channel with emoji by description |any|")
def step(context, emoji_description: str):
    _statusCommunityScreen.search_and_change_community_channel_emoji(emoji_description)

@Then("the community channel has emoji |any|")
def step(context, emoji: str):
    _statusCommunityScreen.check_community_channel_emoji(emoji)

    
@When("the user sends a test image in the current channel")
def step(context): 
    _statusCommunityScreen.send_test_image(context.userData["fixtures_root"], False, "")
    
@When("the user sends a test image in the current channel with message |any|")
def step(context, message): 
    _statusCommunityScreen.send_test_image(context.userData["fixtures_root"], False, message)
    
@When("the user sends multiple test images in the current channel with message |any|")
def step(context, message): 
    _statusCommunityScreen.send_test_image(context.userData["fixtures_root"], True, message)

@Then("the test image is displayed in the last message")
def step(context):
    _statusCommunityScreen.verify_sent_test_image(False, False)

@Then("the test image is displayed just before the last message")
def step(context):
    _statusCommunityScreen.verify_sent_test_image(False, True)

@Then("the test images are displayed just before the last message")
def step(context):
    _statusCommunityScreen.verify_sent_test_image(True, True)

@When("the user pins the message at index |any|")
def step(context, message_index):
    _statusCommunityScreen.toggle_pin_message_at_index(message_index)

@When("the user unpins the message at index |any|")
def step(context, message_index):
    _statusCommunityScreen.toggle_pin_message_at_index(message_index)

@Then("the amount of pinned messages is |any|")
def step(context, amount):
    _statusCommunityScreen.check_pin_count(amount)

