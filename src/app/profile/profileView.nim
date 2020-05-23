import NimQml
import Tables
import mailservers_list

QtObject:
  type ProfileView* = ref object of QObject
    username*: string
    identicon*: string
    mailserversList*: MailServersList

  proc setup(self: ProfileView) =
    self.QObject.setup

  proc delete*(self: ProfileView) =
    self.QObject.delete

  proc newProfileView*(): ProfileView =
    new(result, delete)
    result.username = ""
    result.identicon = ""
    result.mailserversList = newMailServersList()
    result.setup

  proc username*(self: ProfileView): string {.slot.} =
    result = self.username

  proc receivedUsername*(self: ProfileView, username: string) {.signal.}

  proc addMailserverToList*(self: ProfileView, name: string, endpoint: string) {.slot.} =
    self.mailserversList.add(name, endpoint)

  proc setUsername*(self: ProfileView, username: string) {.slot.} =
    self.username = username
    self.receivedUsername(username)

  QtProperty[string] username:
    read = username
    write = setUsername
    notify = receivedUsername

  proc identicon*(self: ProfileView): string {.slot.} =
    result = self.identicon

  proc getMailserversList(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.mailserversList)

  QtProperty[QVariant] mailserversList:
    read = getMailserversList

  proc receivedIdenticon*(self: ProfileView, identicon: string) {.signal.}

  proc setIdenticon*(self: ProfileView, identicon: string) {.slot.} =
    self.identicon = identicon
    self.receivedIdenticon(identicon)

  QtProperty[string] identicon:
    read = identicon
    write = setIdenticon
    notify = receivedIdenticon
