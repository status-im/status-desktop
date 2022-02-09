import NimQml

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getLinkPreviewWhitelist*(self: View): string {.slot.} =
    return self.delegate.getLinkPreviewWhitelist()

  proc changePassword*(self: View, password: string, newPassword: string) {.slot.} =
    self.delegate.changePassword(password, newPassword)

  proc passwordChanged(self: View, success: bool) {.signal.}
  proc emitPasswordChangedSignal*(self: View, success: bool) =
    self.passwordChanged(success)

  proc mnemonicBackedUpChanged(self: View) {.signal.}
  proc isMnemonicBackedUp(self: View): bool {.slot.} =
    return self.delegate.isMnemonicBackedUp()
  QtProperty[bool] mnemonicBackedUp:
    read = isMnemonicBackedUp
    notify = mnemonicBackedUpChanged

  proc emitMnemonicBackedUpSignal*(self: View) =
    self.mnemonicBackedUpChanged()

  proc getMnemonic*(self: View): string {.slot.} =
    return self.delegate.getMnemonic()

  proc removeMnemonic*(self: View) {.slot.} =
    self.delegate.removeMnemonic()

  proc getMnemonicWordAtIndex*(self: View, index: int): string {.slot.} =
    return self.delegate.getMnemonicWordAtIndex(index)

  proc messagesFromContactsOnlyChanged(self: View) {.signal.}
  proc getMessagesFromContactsOnly(self: View): bool {.slot.} =
    return self.delegate.getMessagesFromContactsOnly()
  proc setMessagesFromContactsOnly(self: View, value: bool) {.slot.} =
    self.delegate.setMessagesFromContactsOnly(value)
    self.messagesFromContactsOnlyChanged()
  QtProperty[bool] messagesFromContactsOnly:
    read = getMessagesFromContactsOnly
    write = setMessagesFromContactsOnly
    notify = messagesFromContactsOnlyChanged
