from screens.StatusMainScreen import StatusMainScreen
from screens.StatusChatScreen import StatusChatScreen

_statusMain = StatusMainScreen()
_statusChat = StatusChatScreen()


@When("user joins chat room |any|")
def step(context, room):
    _statusMain.joinChatRoom(room)


@Then("user is able to send chat message")
def step(context):
    table = context.table
    for row in table[1:]:
        _statusChat.sendMessage(row[0])
