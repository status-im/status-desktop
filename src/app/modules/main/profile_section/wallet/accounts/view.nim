import NimQml, sequtils, strutils, sugar

import ./model
import ./item
import ./io_interface
import ../../../../shared_models/[keypair_model, keypair_item]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      accounts: Model
      accountsVariant: QVariant
      keyPairModel: KeyPairModel
      includeWatchOnlyAccount: bool

  proc delete*(self: View) =
    self.accounts.delete
    self.accountsVariant.delete
    self.keyPairModel.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.accounts = newModel()
    result.accountsVariant = newQVariant(result.accounts)
    result.keyPairModel = newKeyPairModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc accountsChanged*(self: View) {.signal.}

  proc getAccounts(self: View): QVariant {.slot.} =
    return self.accountsVariant

  QtProperty[QVariant] accounts:
    read = getAccounts
    notify = accountsChanged

  proc setItems*(self: View, items: seq[Item]) =
    self.accounts.setItems(items)

  proc updateAccount(self: View, address: string, accountName: string, colorId: string, emoji: string) {.slot.} =
    self.delegate.updateAccount(address, accountName, colorId, emoji)

  proc updateAccountPosition(self: View, address: string, position: int) {.slot.} =
    self.delegate.updateAccountPosition(address, position)

  proc onUpdatedAccount*(self: View, account: Item) =
    self.accounts.onUpdatedAccount(account)
    self.keyPairModel.onUpdatedAccount(account.keyUid, account.address, account.name, account.colorId, account.emoji)
    
  proc deleteAccount*(self: View, address: string) {.slot.} =
    self.delegate.deleteAccount(address)
  
  proc keyPairModelChanged*(self: View) {.signal.}
  proc getKeyPairModel(self: View): QVariant {.slot.} =
    return newQVariant(self.keyPairModel)
  QtProperty[QVariant] keyPairModel:
    read = getKeyPairModel
    notify = keyPairModelChanged

  proc setKeyPairModelItems*(self: View, items: seq[KeyPairItem]) =
    self.keyPairModel.setItems(items)
    self.keyPairModelChanged()

  proc includeWatchOnlyAccountChanged*(self: View) {.signal.}
  proc getIncludeWatchOnlyAccount(self: View): bool {.slot.} =
    return self.includeWatchOnlyAccount
  QtProperty[bool] includeWatchOnlyAccount:
    read = getIncludeWatchOnlyAccount
    notify = includeWatchOnlyAccountChanged

  proc toggleIncludeWatchOnlyAccount*(self: View) {.slot.} =
    self.delegate.toggleIncludeWatchOnlyAccount()

  proc setIncludeWatchOnlyAccount*(self: View, includeWatchOnlyAccount: bool) =
    self.includeWatchOnlyAccount = includeWatchOnlyAccount
    self.includeWatchOnlyAccountChanged()
