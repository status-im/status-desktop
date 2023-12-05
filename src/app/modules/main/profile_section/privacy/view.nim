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

  proc changePassword*(self: View, password: string, newPassword: string) {.slot.} =
    self.delegate.changePassword(password, newPassword)

  proc passwordChanged(self: View, success: bool, errorMsg: string) {.signal.}
  proc emitPasswordChangedSignal*(self: View, success: bool, errorMsg: string) =
    self.passwordChanged(success, errorMsg)

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

  proc mnemonicWasShown*(self: View) {.slot.} =
    self.delegate.mnemonicWasShown()

  proc getMnemonicWordAtIndex*(self: View, index: int): string {.slot.} =
    return self.delegate.getMnemonicWordAtIndex(index)

  proc messagesFromContactsOnlyChanged(self: View) {.signal.}
  proc getMessagesFromContactsOnly(self: View): bool {.slot.} =
    return self.delegate.getMessagesFromContactsOnly()
  proc setMessagesFromContactsOnly(self: View, value: bool) {.slot.} =
    if self.getMessagesFromContactsOnly() == value:
      return
    self.delegate.setMessagesFromContactsOnly(value)
    self.messagesFromContactsOnlyChanged()
  QtProperty[bool] messagesFromContactsOnly:
    read = getMessagesFromContactsOnly
    write = setMessagesFromContactsOnly
    notify = messagesFromContactsOnlyChanged

  proc urlUnfurlingModeChanged(self: View) {.signal.}
  proc getUrlUnfurlingMode(self: View): int {.slot.} =
    return self.delegate.urlUnfurlingMode()
  proc setUrlUnfurlingMode(self: View, value: int) {.slot.} =
    if self.getUrlUnfurlingMode() == value:
      return
    self.delegate.setUrlUnfurlingMode(value)

  QtProperty[int] urlUnfurlingMode:
    read = getUrlUnfurlingMode
    write = setUrlUnfurlingMode
    notify = urlUnfurlingModeChanged

  proc validatePassword*(self: View, password: string): bool {.slot.} =
    self.delegate.validatePassword(password)

  proc getPasswordStrengthScore*(self: View, password: string): int {.slot.} =
    return self.delegate.getPasswordStrengthScore(password)

  proc storeToKeychainError*(self:View, errorDescription: string) {.signal.}
  proc emitStoreToKeychainError*(self: View, errorDescription: string) =
    self.storeToKeychainError(errorDescription)

  proc storeToKeychainSuccess*(self:View) {.signal.}
  proc emitStoreToKeychainSuccess*(self: View) =
    self.storeToKeychainSuccess()

  proc tryStoreToKeyChain*(self: View) {.slot.} =
    self.delegate.tryStoreToKeyChain()

  proc tryRemoveFromKeyChain*(self: View) {.slot.} =
    self.delegate.tryRemoveFromKeyChain()
    
  proc backupData*(self: View): int {.slot.} =
    return self.delegate.backupData().int
  
  proc emitUrlUnfurlingModeUpdated*(self: View, mode: int) =
    self.urlUnfurlingModeChanged()
