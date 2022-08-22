

from random import randint
from drivers.SquishDriver import *
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusChatScreen import StatusChatScreen
from screens.StatusCreateChatScreen import StatusCreateChatScreen


_statusMain = StatusMainScreen()
_statusChat = StatusChatScreen()
_statusCreateChatView = StatusCreateChatScreen()

@When("the user opens the chat section")
def step(context):
    _statusMain.open_chat_section()

@When("user joins chat room |any|")
def step(context, room):
    _statusMain.join_chat_room(room)
    _statusChat.verify_chat_title(room)
    
@When("the user creates a group chat adding users")
def step(context):
    _statusMain.open_start_chat_view()
    _statusCreateChatView.create_chat(context.table)
    
@When("the user clicks on |any| chat")
def step(context, chatName):
    _statusMain.open_chat(chatName)
    
@When("the user inputs a mention to |any| with message |any|")
def step(context,displayName,message):
    _statusChat.send_message_with_mention(displayName, message)
    
@When("the user clears chat history")
def step(context):
    _statusChat.clear_history()
    
@When("the user types \"|any|\"") 
def step(context, message): 
    _statusChat.type_message_in_chat_input(message)

@When("the user pressed enter")
def step(context):
    _statusChat.press_enter_in_chat_input()

@Then("user is able to send chat message")
def step(context):
    table = context.table
    for row in table[1:]:
        _statusChat.send_message(row[0])
        _statusChat.verify_last_message_sent(row[0])
        
@Then("The user is able to send a gif message")
def step(context):
    _statusChat.send_gif()
    _statusChat.verify_last_message_sent("tenor.gif")
    
@Then("the user selects emoji in the suggestion list")
def step(contenxt):
    _statusChat.select_the_emoji_in_suggestion_list()
    
@Then("the user is able to send chat message \"|any|\"")
def step(context, message):
     _statusChat.send_message(message)

@When("the user sends the chat message |any|")
def step(context, message):
    _statusChat.send_message(message)
    _statusChat.verify_last_message_sent(message)

@Then("the user is able to send a random chat message")
def step(context):
    random_int = randint(0, 10000)
    message = "random message " + str(random_int)
    _statusChat.send_message(message)
    _statusChat.verify_last_message_sent(message)
    context.userData["randomMessage"] = message
    
@Then("the chat is cleared")
def step(context):
    _statusChat.verify_last_message_is_not_loaded()

@Then("the group chat is created")
def step(context):
    _statusChat = StatusChatScreen()
    
@Then("the group chat history contains \"|any|\" message")
def step(context, createdTxt):
    _statusChat.verify_chat_created_message_is_displayed_in_history(createdTxt)
    
@Then("the chat title is |any|")
def step(context, title):
    _statusChat.verify_chat_title(title)
    
@Then("the group chat contains the following members")
def step(context):
    _statusChat.verify_members_added(context.table)

@Then("the group chat is up to chat sending \"|any|\" message")
def step(context, message):
    _statusChat.send_message(message)
    _statusChat.verify_last_message_sent(message)
    
@Then("the user can reply to the message at index |any| with \"|any|\"")
def step(context, message_index, message):
    _statusChat.reply_to_message_at_index(message_index, message)
    _statusChat.verify_last_message_sent(message)
    
@When("the user edits the message at index |any| and changes it to \"|any|\"" )
def step(context, message_index, message):
    _statusChat.edit_message_at_index(message_index, message)
    _statusChat.verify_last_message_sent(message)

@Then("the user can mark the channel |any| as read")
def step(context, channel):
    _statusMain.mark_as_read(channel)

@Then("the user can delete the message at index |any|")
def step(context, message_index):
    _statusChat.delete_message_at_index(message_index)
    time.sleep(1)

@Then("the user cannot delete the last message")
def step(context):
    _statusChat.cannot_delete_last_message()
    
@Then("the last message is not \"|any|\"")
def step(context, message):
    _statusChat.verify_last_message_sent_is_not(message)
    
@Then("the last message is not the random message")
def step(context):
    _statusChat.verify_last_message_sent_is_not(context.userData["randomMessage"])

@When("user sends the emoji |any| as a message")
def step(context, emoji_short_name):
    _statusChat.send_emoji(emoji_short_name, "")

@When("user sends the emoji |any| with message |any|")
def step(context, emoji_short_name, message):
    _statusChat.send_emoji(emoji_short_name, message)

@Then("the emoji |any| is displayed in the last message")
def step(context, emoji):
     _statusChat.verify_last_message_sent(emoji)

@Then("the message |any| is displayed in the last message")
def step(context, message):
    _statusChat.verify_last_message_sent(message)

@Then("the user cannot input a mention to a not existing user |any|")
def step(context, displayName):
    _statusChat.cannot_do_mention(displayName)
    
@Then("the |any| mention with message |any| have been sent")
def step(context,displayName,message):
    _statusChat.verify_last_message_sent_contains_mention(displayName, message)

@Then("user chats are sorted accordingly")
def step(context):
    table = context.table
    for i, row in enumerate(table):
        chatName = row[0]
        _statusChat.verify_chat_order(i, chatName)

@When("user switches to |any| chat")
def step(context, chatName):
    _statusChat.switch_to_chat(chatName)
