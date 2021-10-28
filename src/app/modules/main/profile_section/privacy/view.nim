import NimQml

# import ./controller_interface
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      messagesFromContactsOnly: bool

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.messagesFromContactsOnly = false

  proc messagesFromContactsOnlyChanged*(self: View) {.signal.}

  proc getMessagesFromContactsOnly*(self: View): QVariant {.slot.} =
    newQVariant(self.messagesFromContactsOnly)

  proc setMessagesFromContactsOnly*(self: View, contactsOnly: bool) =
    self.messagesFromContactsOnly = contactsOnly
    self.messagesFromContactsOnlyChanged()

  QtProperty[QVariant] messagesFromContactsOnly:
    read = getMessagesFromContactsOnly
    notify = messagesFromContactsOnlyChanged

  proc getLinkPreviewWhitelist*(self: View): string {.slot.} =
    return self.delegate.getLinkPreviewWhitelist()

  proc changePassword*(self: View, password: string, newPassword: string): bool {.slot.} =
    return self.delegate.changePassword(password, newPassword)

  proc changeMessagesFromContactsOnly*(self: View, messagesFromContactsOnly: bool) {.slot.} =
    if (messagesFromContactsOnly == self.messagesFromContactsOnly):
      return
    let success = self.delegate.setMessageFromContactsOnlySetting(messagesFromContactsOnly)
    if (success):
      self.setMessagesFromContactsOnly(messagesFromContactsOnly)
    # TODO handle failure to change setting
    # TODO cleanup chats after activating this
