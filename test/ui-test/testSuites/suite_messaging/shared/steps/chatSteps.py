from random import randint
import steps.commonInitSteps as init_steps
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusChatScreen import StatusChatScreen
from screens.StatusCreateChatScreen import StatusCreateChatScreen

# Screen's creation:
_statusMain = StatusMainScreen()
_statusChat = StatusChatScreen()
_statusCreateChatView = StatusCreateChatScreen()

#########################
### PRECONDITIONS region:
#########################

@Given("the user sends a chat message \"|any|\"")
def step(context, message):
    the_user_sends_a_chat_message(message)
    
@Given("the image \"|any|\" is not unfurled in the chat")
def step(context: any, image_link: str):
    _statusChat.verify_image_unfurled_status(image_link, False)
       
@Given("the user types \"|any|\"") 
def step(context, message): 
    _statusChat.type_message(message)
    
@Given("the user selects the emoji in the suggestion's list")
def step(contenxt):
    _statusChat.select_the_emoji_in_suggestion_list()
    
@Given("the user installs the sticker pack at position |any|")
def step(context, pack_index):
    _statusChat.install_sticker_pack(pack_index)
    
@Given("the user creates a group chat adding users")
def step(context):
    the_user_creates_a_group_chat_adding_users(context)
    
@Given("the group chat is created")
def step(context):
    the_group_chat_is_created()
     
@Given("the user clicks on \"|any|\" chat")
@When("the user clicks on \"|any|\" chat")
def step(context, chatName):
    _statusMain.open_chat(chatName)

@When("the user wait for \"|any|\" chat and open it")
def step(context, chatName):
    _statusMain.wait_and_open_chat(chatName)

    
@Given("the user opens the edit group chat popup")
def step(context):
    _statusChat.open_group_chat_edit_popup()
    
@Given("the user changes the group name to \"|any|\"")
def step(context, groupName):
    _statusChat.group_chat_edit_name(groupName)
    
@Given("the user changes the group color to \"|any|\"")
def step(context, groupColor):
    _statusChat.group_chat_edit_color(groupColor)

@Given("the user changes the group image")
def step(context):
    _statusChat.group_chat_edit_image(context.userData["fixtures_root"])
    
@Given("the group chat history contains \"|any|\" message")
def step(context, createdTxt):
    _statusChat.verify_chat_created_message_is_displayed_in_history(createdTxt)
    
@Given("the group chat contains the following members")
def step(context):
    _statusChat.verify_members_added(context.table)
    
@Given("the user opens the chat section")
def step(context):
    the_user_opens_the_chat_section()
    
@Given("the user sends a random chat message")
def step(context):
    the_user_sends_a_random_chat_message(context)
    
@Given("the user saves changes")
def step(context):
    the_user_saves_changes()
    
@Given("the chat title is \"|any|\"")
def step(context, title):
    the_chat_title_is(title)

#########################
### ACTIONS region:
#########################

@When("the user opens the chat section")
def step(context):
    the_user_opens_the_chat_section()

@When("the user sends a chat message \"|any|\"")
def step(context, message):
    the_user_sends_a_chat_message(message)

@When("the user replies to the message at index |any| with \"|any|\"")
def step(context, message_index, message):
    _statusChat.reply_to_message_at_index(message_index, message)

@When("the user opens the user profile from the message at index |any|")
def step(context, message_index):
    _statusChat.open_user_profile_from_message_at_index(message_index)

@When("the user edits the message at index |any| and changes it to \"|any|\"" )
def step(context, message_index, message):
    _statusChat.edit_message_at_index(message_index, message)
    
@When("the user deletes the message at index |any|")
def step(context, message_index):
    _statusChat.delete_message_at_index(message_index)
    time.sleep(1)
    
@When("the user clears chat history")
def step(context):
    _statusChat.clear_history()
    
@When("the user sends a GIF message")
def step(context):
    _statusChat.send_gif()
    
@When("the user presses enter")
def step(context):
    _statusChat.press_enter()

@When("the user inputs a mention to \"|any|\" with message \"|any|\"")
def step(context,displayName,message):
    _statusChat.send_message_with_mention(displayName, message)
    
@When("the user sends the emoji \"|any|\" as a message")
def step(context, emoji_short_name):
    _statusChat.send_emoji(emoji_short_name, "")

@When("the user sends the emoji \"|any|\" with message \"|any|\"")
def step(context, emoji_short_name, message):
    _statusChat.send_emoji(emoji_short_name, message)

# Using position of sticker because stickers don't have ids, only hashes and it feels weird to type hashes in Gherkin
@When("the user sends the sticker at position |any| in the list")
def step(context, sticker_index):
    _statusChat.send_sticker(sticker_index)
    
@When("the user sends a random chat message")
def step(context):
    the_user_sends_a_random_chat_message(context)

@When("the user switches to \"|any|\" chat")
def step(context, chatName):
    _statusChat.switch_to_chat(chatName)

@When("the user creates a group chat adding users")
def step(context):
    the_user_creates_a_group_chat_adding_users(context)

@When("the user creates a one to one chat with \"|any|\"")
def step(context, username):
    _statusMain.open_start_chat_view()
    _statusCreateChatView.create_chat([[username]])

@When("the user saves changes")
def step(context):
    the_user_saves_changes()
    
@When("the user leaves current chat")
def step(context):
    leave_current_chat()
    
@When("the user leaves chat \"|any|\" by right click on it")
def step(context, chatName: str):
    _statusMain.leave_chat(chatName)

#########################
### VERIFICATIONS region:
#########################

@Then("the last chat message contains \"|any|\"")
def step(context, message):
    _statusChat.verify_last_message_sent(message)
    
@Then("the chat message \"|any|\" is displayed as a reply")
def step(context, message):
    _statusChat.verify_last_message_is_reply(message) 

@Then("the chat message \"|any|\" is displayed as a reply of \"|any|\"")
def step(context, reply, message):
    _statusChat.verify_last_message_is_reply_to(reply, message) 

@Then("the chat message \"|any|\" is displayed as a reply of this user's \"|any|\"")
def step(context, reply, message):
    _statusChat.verify_last_message_is_reply_to_loggedin_user_message(reply, message) 
    
@Then("the chat message \"|any|\" is displayed as an edited one")
def step(context, message):
    _statusChat.verify_last_message_sent(message)  
    _statusChat.verify_last_message_is_edited(message)
         
@Then("the last message displayed is not \"|any|\"")
def step(context, message):
    _statusChat.verify_last_message_sent_is_not(message)
    
@Then("the chat is cleared")
def step(context):
    _statusChat.verify_last_message_is_not_loaded()    
    
@Then("the GIF message is displayed")
def step(context):
    _statusChat.verify_last_message_sent("tenor.com")
    
@Then("the image |any| is unfurled in the chat")
def step(context: any, image_link: str):
    _statusChat.verify_image_unfurled_status(image_link, True)
    
@Then("the user cannot delete the last message")
def step(context):
    _statusChat.cannot_delete_last_message()   

@Then("the \"|any|\" mention with message \"|any|\" have been sent")
def step(context,displayName,message):
    _statusChat.verify_last_message_sent_contains_mention(displayName, message)
    
@Then("the user cannot input a mention to a not existing user \"|any|\"")
def step(context, displayName):
    _statusChat.cannot_do_mention(displayName)
  
@Then("the last chat message is a sticker")
def step(context):
    _statusChat.verify_last_message_is_sticker()
    
@Then("the user chats are sorted accordingly")
def step(context):
    table = context.table
    for i, row in enumerate(table):
        chatName = row[0]
        _statusChat.verify_chat_order(i, chatName)

@Then("the random chat message is displayed")
def step(context):
    message = context.userData["randomMessage"]  
    _statusChat.verify_last_message_sent(message)
    
@Then("the group chat is created")
def step(context):
    the_group_chat_is_created()
    
@Then("the chat title is \"|any|\"")
def step(context, title):
    the_chat_title_is(title)

@Then("the chat color is \"|any|\"")
def step(context, color):
    _statusChat.verify_chat_color(color)

@Then("the chat image is changed")
def step(context):
    _statusChat.verify_chat_image(context.userData["fixtures_root"])

@Then("the chat \"|any|\" does not exist")
def step(context, chatName):
    _statusMain.verify_chat_does_not_exist(chatName)
    
###########################################################################
### COMMON methods used in different steps given/when/then region:
########################################################################### 

def the_user_sends_a_chat_message(message: str):
    _statusChat.send_message(message)
    
def the_user_creates_a_group_chat_adding_users(context: any):
    _statusMain.open_start_chat_view()
    _statusCreateChatView.create_chat(context.table)
    
def the_group_chat_is_created():
    _statusChat = StatusChatScreen()
    
def the_user_opens_the_chat_section():
    init_steps.the_user_opens_the_chat_section()

def the_user_sends_a_random_chat_message(context):
    random_int = randint(0, 10000)
    message = "random message " + str(random_int)
    _statusChat.send_message(message)
    context.userData["randomMessage"] = message

def leave_current_chat():
    _statusChat.leave_chat()
    
def the_user_saves_changes():
    _statusChat.group_chat_edit_save()
    
def the_chat_title_is(title: str):
    _statusChat.verify_chat_title(title)
