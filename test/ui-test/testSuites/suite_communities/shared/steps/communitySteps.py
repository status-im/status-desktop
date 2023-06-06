import steps.commonInitSteps as init_steps
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusCommunityPortalScreen import StatusCommunityPortalScreen
from screens.StatusCommunityScreen import StatusCommunityScreen

_statusCommunityScreen = StatusCommunityScreen()
_statusCommunitityPortal = StatusCommunityPortalScreen()
_statusMainScreen = StatusMainScreen()

#########################
### PRECONDITIONS region:
#########################
@Given("the user opens the community portal section")
def step(context: any):
    init_steps.the_user_opens_the_community_portal_section()

@Given("the user lands on the community portal section")
def step(context):
    init_steps.the_user_lands_on_the_community_portal_section()
    
@Given("the user creates a community named \"|any|\", with description \"|any|\", intro \"|any|\" and outro \"|any|\"")
def step(context: any, community_name: str, community_description: str, community_intro: str, community_outro: str):
    the_user_creates_a_community(community_name, community_description, community_intro, community_outro)
    
@Given("the admin creates a community channel named \"|any|\", with description \"|any|\", with the method \"|any|\"")
def step(context, community_channel_name, community_channel_description, method):
    the_admin_creates_a_community_channel(community_channel_name, community_channel_description, method)
    
@Given("the user lands on the community named \"|any|\"")
def step(context: any, community_name: str):
    the_user_lands_on_the_community(community_name)

@Given("the channel named \"|any|\" is open")
def step(context, community_channel_name): 
    the_channel_is_open(community_channel_name)
    
@Given("the channel count is |integer|")
def step(context, community_channel_count: int):
    the_channel_count_is(community_channel_count)
    
@Given("the admin creates a community category named \"|any|\", with channels \"|any|\" and with the method \"|any|\"")
def step(context, category_name, channel_names, method):
    the_admin_creates_a_community_category(category_name, channel_names, method)
    
@Given("the category named \"|any|\" contains channels \"|any|\"")
def step(context, category_name, channel_names):
    the_category_contains_channels(category_name, channel_names)     

@Given("\"|any|\" is toggled on under Experimental features")
def step(context: any, settings_type:str):
    _settingsScreen.toggle_experimental_feature(settings_type)

@Given("\"|any|\" is clicked in the community sidebar")
def step(context, community_sidebar_option:str):
    _statusCommunityScreen.click_sidebar_option(community_sidebar_option)

@Given("\"|any|\" should be an available option in Community Settings")
def step(context, manage_community_option:str):
    _statusCommunityScreen.verify_option_exists(manage_community_option)

#########################
### ACTIONS region:
#########################

@When("the user opens the community named \"|any|\"")
def step(context, community_name):
    _statusMainScreen.click_community(community_name)

@When("the user sends a test image in the current channel")
def step(context): 
    _statusCommunityScreen.send_test_image(context.userData["fixtures_root"], False, "")

@When("the user sends a test image in the current channel with message \"|any|\" with an image")
def step(context, message): 
    _statusCommunityScreen.send_test_image(context.userData["fixtures_root"], False, message)
    
@When("the user sends multiple test images in the current channel with message \"|any|\" with an image again")
def step(context, message): 
    _statusCommunityScreen.send_test_image(context.userData["fixtures_root"], True, message)

@When("the user replies to community chat message at index |integer| with \"|any|\"")
def step(context, message_index: int, message: str):
    _statusCommunityScreen.toggle_reply_message_at_index(message_index)
    the_user_sends_a_chat_message(message)
        
@When("the user pins the message at index |integer|")
def step(context, message_index: int):
    _statusCommunityScreen.toggle_pin_message_at_index(message_index)
    
@When("the user unpins the message at index |integer|")
def step(context, message_index: int):
    _statusCommunityScreen.toggle_pin_message_at_index(message_index)
    
@When("the user creates a community named \"|any|\", with description \"|any|\", intro \"|any|\" and outro \"|any|\"")
def step(context: any, community_name: str, community_description: str, community_intro: str, community_outro: str):
    the_user_creates_a_community(community_name, community_description, community_intro, community_outro)

@When("the admin creates a community channel named \"|any|\", with description \"|any|\", with the method \"|any|\"")
def step(context, community_channel_name, community_channel_description, method):
    the_admin_creates_a_community_channel(community_channel_name, community_channel_description, method)

@When("the admin edits the current community channel to the name \"|any|\"")
def step(context, new_community_channel_name):
    _statusCommunityScreen.edit_community_channel(new_community_channel_name)        

@When("the admin creates a community category named \"|any|\", with channels \"|any|\" and with the method \"|any|\"")
def step(context, category_name, channel_names, method):
    the_admin_creates_a_community_category(category_name, channel_names, method)

@When("the admin renames the category \"|any|\" to \"|any|\" and toggles the channels \"|any|\"")
def step(context, community_category_name, new_community_category_name, community_channel_names):
    _statusCommunityScreen.edit_community_category(community_category_name, new_community_category_name, community_channel_names)    

@When("the admin deletes category named \"|any|\"")
def step(context, community_category_name):
    _statusCommunityScreen.delete_community_category(community_category_name) 
    
@When("the admin renames the community to \"|any|\" and description to \"|any|\" and color to \"|any|\"")
def step(context, new_community_name, new_community_description, new_community_color):
    _statusCommunityScreen.edit_community(new_community_name, new_community_description, new_community_color)

@When("the admin changes the community name to \"|any|\"")
def step(context, new_community_name):
    _statusCommunityScreen.open_edit_community_by_community_header()
    _statusCommunityScreen.change_community_name(new_community_name)
    _statusCommunityScreen.save_community_changes()

@When("the admin changes the community description to \"|any|\"") 
def step(context, new_community_description):
    _statusCommunityScreen.open_edit_community_by_community_header()
    _statusCommunityScreen.change_community_description(new_community_description)
    _statusCommunityScreen.save_community_changes()

@When("the admin changes the community color to \"|any|\"")
def step(context, new_community_color):
    _statusCommunityScreen.open_edit_community_by_community_header()
    _statusCommunityScreen.change_community_color(new_community_color)
    _statusCommunityScreen.save_community_changes()

@When("the admin goes back to the community")
def step(context):
    _statusCommunityScreen.go_back_to_community()
    
@When("the admin changes the current community channel emoji to \"|any|\"")
def step(context, emoji_description: str):
    _statusCommunityScreen.search_and_change_community_channel_emoji(emoji_description)   

@When("the admin deletes current channel")
def step(context):
    _statusCommunityScreen.delete_current_community_channel()

@When("the admin invites the user named |any| to the community with message |any|")
def step(context, user_name, message):
    _statusCommunityScreen.invite_user_to_community(user_name, message)

@When("the admin kicks the user named |any|")
def step(context, user_name):
    _statusCommunityScreen.kick_member_from_community(user_name)

@When("the user opens the community portal section")
def step(context: any):
    init_steps.the_user_opens_the_community_portal_section()

@When("the user marks the channel \"|any|\" as read")
def step(context, channel):
    _statusCommunityScreen.mark_as_read(channel)

@When("\"|any|\" is clicked in the community sidebar")
def step(context, community_sidebar_option:str):
    _statusCommunityScreen.click_sidebar_option(community_sidebar_option)
    time.sleep(1)
    
@When("\"|any|\" section is selected") 
def step(context, section_option:str):
    _statusCommunityScreen.select_community_settings_option(section_option)
    time.sleep(1)


#########################
### VERIFICATIONS region:
#########################

@Then("the user lands on the community named \"|any|\"")
def step(context: any, community_name: str):
    the_user_lands_on_the_community(community_name)

@Then("the channel named \"|any|\" is open")
def step(context, community_channel_name): 
    the_channel_is_open(community_channel_name)

@Then("the amount of pinned messages is |integer|")
def step(context, amount: int):
    _statusCommunityScreen.check_pin_count(amount)
    
@Then("the channel count is |integer|")
def step(context, community_channel_count: int):
    the_channel_count_is(community_channel_count)
    
@Then("the category named \"|any|\" contains channels \"|any|\"")
def step(context, category_name, channel_names):
    the_category_contains_channels(category_name, channel_names)
        
@Then("the category named \"|any|\" is missing")
def step(context, category_name): 
    _statusCommunityScreen.verify_category_name_missing(category_name)
    
@Then("the community channel has emoji \"|any|\"")
def step(context, emoji: str):
    _statusCommunityScreen.check_community_channel_emoji(emoji)   
    
@Then("the count of communities in navbar is |integer|")
def step(context: any, expected_count: int):
    _statusMainScreen.verify_communities_count(expected_count)
    
@Then("the last chat message contains the test image")
def step(context):
    _statusCommunityScreen.verify_sent_test_image(False, False)
    
@Then("the test image is displayed just before the last message")
def step(context):
    _statusCommunityScreen.verify_sent_test_image(False, True)

@Then("the test images are displayed just before the last message")
def step(context):
    _statusCommunityScreen.verify_sent_test_image(True, True)   

@Then("the number of members is |any|")
def step(context, amount):
    _statusCommunityScreen.verify_number_of_members(amount)
    
@Then("the community overview name is \"|any|\"")
def step(context, name: str):
    _statusCommunityScreen.verify_community_overview_name(name)

@Then("the community overview description is \"|any|\"")
def step(context, communityDescription: str):
    _statusCommunityScreen.verify_community_overview_description(communityDescription)

@Then("the community overview color is \"|any|\"")
def step(context, color: str):
    _statusCommunityScreen.verify_community_overview_color(color)

@Then("the welcome \"|any|\" image is present")
def step(context, option):
    _statusCommunityScreen.verify_welcome_image(option)    
    
@Then("\"|any|\" should be an available option in Community->Manage->left navigation")
def step(context, list):
    _statusCommunityScreen.verify_option_exists(list)
    
@Then("\"|any|\" should be in the list of uncategorized channels")
def step(context, chat_name:str):
    _statusCommunityScreen.check_channel_is_uncategorized(chat_name)

@Then("the welcome \"|any|\" title is present") 
def step(context, option:str):
    _statusCommunityScreen.verify_welcome_title(option)     

@Then("the welcome \"|any|\" subtitle is present")
def step(context, option:str):
    _statusCommunityScreen.verify_welcome_subtitle(option)    
    
@Then("the welcome \"|any|\" settings \"|any|\" is present")
def step(context, option:str, list):
    _statusCommunityScreen.verify_welcome_settings_checklist(option, list)

@Then("\"|any|\" button is present")
def step (context, action_button_name):
    _statusCommunityScreen.verify_action_button_enabled(action_button_name)
      
@Then("the user is able to open Back up modal and copy private key")
def step(context):
    _statusCommunityScreen.verify_community_private_key() 

@Then("the user is able to click Airdrop Tokens button and navigate to Airdrops screen")
def step(context):
    _statusCommunityScreen.open_airdrops_from_overview()
    
###########################################################################
### COMMON methods used in different steps given/when/then region:
########################################################################### 

def the_user_creates_a_community(name:str, description: str, intro:str, outro:str):
    init_steps.the_user_creates_a_community(name, description, intro, outro)
    
def the_user_lands_on_the_community(name: str):
    init_steps.the_user_lands_on_the_community(name)
    
def the_admin_creates_a_community_channel(name: str, description: str, method: str):
    init_steps.the_admin_creates_a_community_channel(name, description, method)

def the_channel_is_open(name: str):
    init_steps.the_channel_is_open(name)
    
def the_channel_count_is(community_channel_count: int):
    _statusCommunityScreen.check_channel_count(community_channel_count)
    
def the_admin_creates_a_community_category(name: str, channels: str, method: str):
    _statusCommunityScreen.create_community_category(name, channels, method)
    
def the_category_contains_channels(category_name: str, channels: str):
    _statusCommunityScreen.verify_category_contains_channels(category_name, channels)
