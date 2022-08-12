
from random import randint
from drivers.SquishDriver import *
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusChatScreen import StatusChatScreen
from screens.StatusCreateChatScreen import StatusCreateChatScreen


_statusMain = StatusMainScreen()
_statusChat = StatusChatScreen()
_statusCreateChatView = StatusCreateChatScreen()

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

@Then("user is able to send chat message")
def step(context):
    table = context.table
    for row in table[1:]:
        _statusChat.send_message(row[0])
        _statusChat.verify_last_message_sent(row[0])

@Then("user is able to send  a random chat message")
def step(context):
    random_int = randint(0, 10000)
    message = "random message " + str(random_int)
    _statusChat.send_message(message)
    _statusChat.verify_last_message_sent(message)
    context.userData["randomMessage"] = message

@Then("the group chat is created")
def step(context):
    _statusChat = StatusChatScreen()
    
@Then("the group chat history contains \"|any|\" message")
def step(context, createdTxt):
    _statusChat.verify_chat_created_message_is_displayed_in_history(createdTxt)
    
@Then("the group chat title is |any|")
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
    
@Then("the user cannot input a mention to a not existing user |any|")
def step(context, displayName):
    _statusChat.cannot_do_mention(displayName)
    
@Then("the |any| mention with message |any| have been sent")
def step(context,displayName,message):
    _statusChat.verify_last_message_sent_contains_mention(displayName, message)
