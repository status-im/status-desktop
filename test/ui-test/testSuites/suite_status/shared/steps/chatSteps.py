
from screens.StatusMainScreen import StatusMainScreen

_statusMain = StatusMainScreen()


@When("user joins chat room |any|")
def step(context, room):
    _statusMain.joinChatRoom(room)


@Then("user is able to send chat message |any|")
def step(context, message):
   StatusMainScreen()