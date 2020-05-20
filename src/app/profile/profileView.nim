import NimQml

QtObject:
  type ProfileView* = ref object of QObject
    username*: string

  proc setup(self: ProfileView) =
    self.QObject.setup

  proc newProfileView*(): ProfileView =
    new(result)
    result.username = ""
    result.setup

  proc delete*(self: ProfileView) =
    self.QObject.delete

  proc username*(self: ProfileView): string {.slot.} =
    result = self.username

  proc receivedUsername*(self: ProfileView, username: string) {.signal.}

  proc setUsername*(self: ProfileView, username: string) {.slot.} =
    self.username = username
    self.receivedUsername(username)

  QtProperty[string] username:
    read = username
    write = setUsername
    notify = receivedUsername
