import NimQml

import ./model
import ./item
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc setItems*(self: View, items: seq[Item]) =
    self.model.setItems(items)

  proc generateNewAccount*(self: View, password: string, accountName: string, color: string) {.slot.} =
    self.delegate.generateNewAccount(password, accountName, color)

  proc addAccountsFromPrivateKey*(self: View, privateKey: string, password: string, accountName: string, color: string) {.slot.} =
    self.delegate.addAccountsFromPrivateKey(privateKey, password, accountName, color)

  proc addAccountsFromSeed*(self: View, seedPhrase: string, password: string, accountName: string, color: string) {.slot.} =
    self.delegate.addAccountsFromSeed(seedPhrase, password, accountName, color)

  proc addWatchOnlyAccount*(self: View, address: string, accountName: string, color: string) {.slot.} =
    self.delegate.addWatchOnlyAccount(address, accountName, color)

  proc deleteAccount*(self: View, address: string) {.slot.} =
    self.delegate.deleteAccount(address)