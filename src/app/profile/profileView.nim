import NimQml

QtObject:
  type ProfileView* = ref object of QObject
    username*: string
    identicon*: string

  proc setup(self: ProfileView) =
    self.QObject.setup

  proc newProfileView*(): ProfileView =
    new(result)
    result.username = ""
    result.identicon = ""
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

  proc identicon*(self: ProfileView): string {.slot.} =
    result = self.identicon

  proc receivedIdenticon*(self: ProfileView, identicon: string) {.signal.}

  proc setIdenticon*(self: ProfileView, identicon: string) {.slot.} =
    self.identicon = identicon
    self.receivedIdenticon(identicon)

  QtProperty[string] identicon:
    read = identicon
    write = setIdenticon
    notify = receivedIdenticon
