import
  std/[atomics, json, parseutils, sequtils, strformat, strutils, tables, wrapnils]

import
  chronicles, nimqml, status/[status, wallet2], stint

import
  ../../core/[main],
  ./views/[accounts, account_list, collectibles, networks, saved_addresses, settings],
  ./views/buy_sell_crypto/[service_controller]

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      status: Status
      appService: AppService
      accountsView: AccountsView
      collectiblesView: CollectiblesView
      settingsView*: SettingsView
      networksView*: NetworksView
      cryptoServiceController: CryptoServiceController
      savedAddressesView: SavedAddressesView

  proc delete(self: WalletView) =
    self.accountsView.delete
    self.collectiblesView.delete
    self.cryptoServiceController.delete
    self.savedAddressesView.delete
    self.QAbstractListModel.delete
    self.settingsView.delete
    self.networksView.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status, appService: AppService): WalletView =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.accountsView = newAccountsView(status)
    result.collectiblesView = newCollectiblesView(status, appService)
    result.settingsView = newSettingsView()
    result.networksView = newNetworksView(status)
    result.cryptoServiceController = newCryptoServiceController(status, appService)
    result.savedAddressesView = newSavedAddressesView(status, appService)
    result.setup

  proc getAccounts(self: WalletView): QVariant {.slot.} = 
    newQVariant(self.accountsView)
  QtProperty[QVariant] accountsView:
    read = getAccounts

  proc getCollectibles(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.collectiblesView)
  QtProperty[QVariant] collectiblesView:
    read = getCollectibles

  proc getSettings(self: WalletView): QVariant {.slot.} = newQVariant(self.settingsView)
  QtProperty[QVariant] settingsView:
    read = getSettings

  proc getNetworks(self: WalletView): QVariant {.slot.} = newQVariant(self.networksView)
  QtProperty[QVariant] networksView:
    read = getNetworks

  proc getSavedAddressesView(self: WalletView): QVariant {.slot.} = newQVariant(self.savedAddressesView)
  QtProperty[QVariant] savedAddressesView:
    read = getSavedAddressesView

  proc updateView*(self: WalletView) =
    # TODO:
    self.accountsView.triggerUpdateAccounts()

  proc setCurrentAccountByIndex*(self: WalletView, index: int) {.slot.} =
    if self.accountsView.setCurrentAccountByIndex(index):
      let selectedAccount = self.accountsView.accounts.getAccount(index)
      self.collectiblesView.loadCollections(selectedAccount)
      # TODO: load account details/transactions/etc

  proc addAccountToList*(self: WalletView, account: WalletAccount) =
    self.accountsView.addAccountToList(account)
    # If it's the first account we ever get, use its list as our first lists
    if (self.accountsView.accounts.rowCount == 1):
      self.setCurrentAccountByIndex(0)

  proc setSigningPhrase*(self: WalletView, signingPhrase: string) =
    self.settingsView.setSigningPhrase(signingPhrase)

  proc setEtherscanLink*(self: WalletView, link: string) =
    self.settingsView.setEtherscanLink(link)
    
  proc getCryptoServiceController*(self: WalletView): QVariant {.slot.} =
    newQVariant(self.cryptoServiceController)

  QtProperty[QVariant] cryptoServiceController:
    read = getCryptoServiceController

  proc onCryptoServicesFetched*(self: WalletView, jsonNode: JsonNode) =
    self.cryptoServiceController.onCryptoServicesFetched(jsonNode)