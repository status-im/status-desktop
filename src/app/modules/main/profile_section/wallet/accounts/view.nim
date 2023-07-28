import NimQml, sequtils, strutils, sugar

import ./io_interface
import ./model
import app/modules/shared_models/keypair_model
import app/modules/shared_models/wallet_account_item

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

  proc setItems*(self: View, items: seq[WalletAccountItem]) =
    self.accounts.setItems(items)

  proc updateAccount(self: View, address: string, accountName: string, colorId: string, emoji: string) {.slot.} =
    self.delegate.updateAccount(address, accountName, colorId, emoji)

  proc onUpdatedAccount*(self: View, account: WalletAccountItem, prodPreferredChainIds: string, testPreferredChainIds: string) =
    self.accounts.onUpdatedAccount(account)
    self.keyPairModel.onUpdatedAccount(account.keyUid, account.address, account.name, account.colorId, account.emoji, prodPreferredChainIds, testPreferredChainIds)

  proc deleteAccount*(self: View, address: string) {.slot.} =
    self.delegate.deleteAccount(address)

  proc deleteKeypair*(self: View, keyUid: string) {.slot.} =
    self.delegate.deleteKeypair(keyUid)

  proc keyPairModel*(self: View): KeyPairModel =
    return self.keyPairModel

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

  proc keypairNameExists*(self: View, name: string): bool {.slot.} =
    return self.keyPairModel.keypairNameExists(name)

  proc renameKeypair*(self: View, keyUid: string, name: string) {.slot.} =
    self.delegate.renameKeypair(keyUid, name)

  proc moveAccount(self: View, fromRow: int, toRow: int) {.slot.} =
    discard self.accounts.moveItem(fromRow, toRow)

  proc moveAccountFinally(self: View, fromRow: int, toRow: int) {.slot.} =
    self.delegate.moveAccountFinally(fromRow, toRow)

  proc updateWalletAccountProdPreferredChains*(self: View, address: string, preferredChainIds: string) {.slot.} =
    self.delegate.updateWalletAccountProdPreferredChains(address, preferredChainIds)

  proc updateWalletAccountTestPreferredChains*(self: View, address: string, preferredChainIds: string) {.slot.} =
    self.delegate.updateWalletAccountTestPreferredChains(address, preferredChainIds)
