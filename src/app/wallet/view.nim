import NimQml, Tables, strformat, strutils, chronicles, json, std/wrapnils, parseUtils, stint
import ../../status/[status, wallet, threads]
import ../../status/wallet/collectibles as status_collectibles
import ../../status/libstatus/wallet as status_wallet
import ../../status/libstatus/tokens
import ../../status/libstatus/types
import ../../status/libstatus/utils
import views/[asset_list, account_list, account_item, transaction_list, collectibles_list]

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      accounts*: AccountList
      currentAssetList*: AssetList
      currentCollectiblesLists*: CollectiblesList
      currentAccount: AccountItemView
      currentTransactions: TransactionList
      status: Status
      totalFiatBalance: string
      etherscanLink: string
      safeLowGasPrice: string
      standardGasPrice: string
      fastGasPrice: string
      fastestGasPrice: string
      defaultGasLimit: string
      signingPhrase: string

  proc delete(self: WalletView) =
    self.accounts.delete
    self.currentAssetList.delete
    self.currentAccount.delete
    self.currentTransactions.delete
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status
    result.accounts = newAccountList()
    result.currentAccount = newAccountItemView()
    result.currentAssetList = newAssetList()
    result.currentTransactions = newTransactionList()
    result.currentCollectiblesLists = newCollectiblesList()
    result.totalFiatBalance = ""
    result.etherscanLink = ""
    result.safeLowGasPrice = "0"
    result.standardGasPrice = "0"
    result.fastGasPrice = "0"
    result.fastestGasPrice = "0"
    result.defaultGasLimit = "21000"
    result.signingPhrase = ""
    result.setup

  proc etherscanLinkChanged*(self: WalletView) {.signal.}

  proc getEtherscanLink*(self: WalletView): QVariant {.slot.} =
    newQVariant(self.etherscanLink.replace("/address", "/tx"))

  proc setEtherscanLink*(self: WalletView, link: string) =
    self.etherscanLink = link
    self.etherscanLinkChanged()

  proc signingPhraseChanged*(self: WalletView) {.signal.}

  proc getSigningPhrase*(self: WalletView): QVariant {.slot.} =
    newQVariant(self.signingPhrase)

  proc setSigningPhrase*(self: WalletView, signingPhrase: string) =
    self.signingPhrase = signingPhrase
    self.signingPhraseChanged()

  QtProperty[QVariant] etherscanLink:
    read = getEtherscanLink
    notify = etherscanLinkChanged

  QtProperty[QVariant] signingPhrase:
    read = getSigningPhrase
    notify = signingPhraseChanged

  proc setCurrentAssetList*(self: WalletView, assetList: seq[Asset])

  proc currentCollectiblesListsChanged*(self: WalletView) {.signal.}

  proc getCurrentCollectiblesLists(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.currentCollectiblesLists)

  proc setCurrentCollectiblesLists*(self: WalletView, collectiblesLists: seq[CollectibleList]) =
    self.currentCollectiblesLists.setNewData(collectiblesLists)
    self.currentCollectiblesListsChanged()

  QtProperty[QVariant] collectiblesLists:
    read = getCurrentCollectiblesLists
    write = setCurrentCollectiblesLists
    notify = currentCollectiblesListsChanged

  proc currentTransactionsChanged*(self: WalletView) {.signal.}

  proc getCurrentTransactions*(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.currentTransactions)

  proc setCurrentTransactions*(self: WalletView, transactionList: seq[Transaction]) =
    self.currentTransactions.setNewData(transactionList)
    self.currentTransactionsChanged()

  QtProperty[QVariant] transactions:
    read = getCurrentTransactions
    write = setCurrentTransactions
    notify = currentTransactionsChanged

  proc loadCollectiblesForAccount*(self: WalletView, address: string, currentCollectiblesList: seq[CollectibleList])
  proc loadTransactionsForAccount*(self: WalletView, address: string)

  proc currentAccountChanged*(self: WalletView) {.signal.}

  proc setCurrentAccountByIndex*(self: WalletView, index: int) {.slot.} =
    if(self.accounts.rowCount() == 0): return

    let selectedAccount = self.accounts.getAccount(index)
    if self.currentAccount.address == selectedAccount.address: return
    self.currentAccount.setAccountItem(selectedAccount)
    self.currentAccountChanged()
    self.setCurrentAssetList(selectedAccount.assetList)

    # Display currently known collectibles, and get latest from API/Contracts
    self.setCurrentCollectiblesLists(selectedAccount.collectiblesLists)
    self.loadCollectiblesForAccount(selectedAccount.address, selectedAccount.collectiblesLists)
    
    # Display currently known transactions, and get latest transactions from status-go
    self.setCurrentTransactions(selectedAccount.transactions)
    self.loadTransactionsForAccount(selectedAccount.address)

  proc getCurrentAccount*(self: WalletView): QVariant {.slot.} =
    result = newQVariant(self.currentAccount)

  QtProperty[QVariant] currentAccount:
    read = getCurrentAccount
    write = setCurrentAccountByIndex
    notify = currentAccountChanged

  proc currentAssetListChanged*(self: WalletView) {.signal.}

  proc getCurrentAssetList(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.currentAssetList)

  proc setCurrentAssetList*(self: WalletView, assetList: seq[Asset]) =
    self.currentAssetList.setNewData(assetList)
    self.currentAssetListChanged()

  QtProperty[QVariant] assets:
    read = getCurrentAssetList
    write = setCurrentAssetList
    notify = currentAssetListChanged


  proc totalFiatBalanceChanged*(self: WalletView) {.signal.}

  proc getTotalFiatBalance(self: WalletView): string {.slot.} =
    self.status.wallet.getTotalFiatBalance()

  proc setTotalFiatBalance*(self: WalletView, newBalance: string) =
    self.totalFiatBalance = newBalance
    self.totalFiatBalanceChanged()

  QtProperty[string] totalFiatBalance:
    read = getTotalFiatBalance
    write = setTotalFiatBalance
    notify = totalFiatBalanceChanged

  proc accountListChanged*(self: WalletView) {.signal.}

  proc addAccountToList*(self: WalletView, account: WalletAccount) =
    self.accounts.addAccountToList(account)
    # If it's the first account we ever get, use its list as our first lists
    if (self.accounts.rowCount == 1):
      self.setCurrentAssetList(account.assetList)
      self.setCurrentAccountByIndex(0)
    self.accountListChanged()

  proc getFiatValue*(self: WalletView, cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string {.slot.} =
    let val = self.status.wallet.convertValue(cryptoBalance, cryptoSymbol, fiatSymbol)
    result = fmt"{val:.2f}"

  proc getCryptoValue*(self: WalletView, fiatBalance: string, fiatSymbol: string, cryptoSymbol: string): string {.slot.} =
    result = fmt"{self.status.wallet.convertValue(fiatBalance, fiatSymbol, cryptoSymbol)}"

  proc getGasEthValue*(self: WalletView, gweiValue: string, gasLimit: string): string {.slot.} =
    var gweiValueInt:int
    var gasLimitInt:int

    discard gweiValue.parseInt(gweiValueInt)
    discard gasLimit.parseInt(gasLimitInt)

    let weiValue = gweiValueInt.u256 * 1000000000.u256 * gasLimitInt.u256
    let ethValue = wei2Eth(weiValue)
    result = fmt"{ethValue}"

  proc generateNewAccount*(self: WalletView, password: string, accountName: string, color: string): string {.slot.} =
    result = self.status.wallet.generateNewAccount(password, accountName, color)

  proc addAccountsFromSeed*(self: WalletView, seed: string, password: string, accountName: string, color: string): string {.slot.} =
    result = self.status.wallet.addAccountsFromSeed(seed.strip(), password, accountName, color)

  proc addAccountsFromPrivateKey*(self: WalletView, privateKey: string, password: string, accountName: string, color: string): string {.slot.} =
    result = self.status.wallet.addAccountsFromPrivateKey(privateKey, password, accountName, color)

  proc addWatchOnlyAccount*(self: WalletView, address: string, accountName: string, color: string): string {.slot.} =
    result = self.status.wallet.addWatchOnlyAccount(address, accountName, color)

  proc changeAccountSettings*(self: WalletView, address: string, accountName: string, color: string): string {.slot.} =
    result = self.status.wallet.changeAccountSettings(address, accountName, color)
    if (result == ""):
      self.currentAccountChanged()
      self.accountListChanged()
      self.accounts.forceUpdate()

  proc deleteAccount*(self: WalletView, address: string): string {.slot.} =
    result = self.status.wallet.deleteAccount(address)
    if (result == ""):
      let index = self.accounts.getAccountindexByAddress(address)
      if (index == -1):
        return fmt"Unable to find the account with the address {address}"
      self.accounts.deleteAccountAtIndex(index)
      self.accountListChanged()
      self.accounts.forceUpdate()

  proc getAccountList(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.accounts)

  QtProperty[QVariant] accounts:
    read = getAccountList
    notify = accountListChanged

  proc sendTransaction*(self: WalletView, from_addr: string, to: string, assetAddress: string, value: string, gas: string, gasPrice: string, password: string): string {.slot.} =
    let resultJson = %*{}
    try:
      resultJson{"result"} = %self.status.wallet.sendTransaction(from_addr, to, assetAddress, value, gas, gasPrice, password)
    except StatusGoException as e:
      resultJson{"error"} = %e.msg
    finally:
      result = $resultJson

  proc getDefaultAccount*(self: WalletView): string {.slot.} =
    self.currentAccount.address

  proc defaultCurrency*(self: WalletView): string {.slot.} =
    self.status.wallet.getDefaultCurrency()

  proc defaultCurrencyChanged*(self: WalletView) {.signal.}

  proc setDefaultCurrency*(self: WalletView, currency: string) {.slot.} =
    self.status.wallet.setDefaultCurrency(currency)
    self.defaultCurrencyChanged()

  QtProperty[string] defaultCurrency:
    read = defaultCurrency
    write = setDefaultCurrency
    notify = defaultCurrencyChanged

  proc hasAsset*(self: WalletView, account: string, symbol: string): bool {.slot.} =
    self.status.wallet.hasAsset(account, symbol)

  proc toggleAsset*(self: WalletView, symbol: string, checked: bool, address: string, name: string, decimals: int, color: string) {.slot.} =
    self.status.wallet.toggleAsset(symbol, checked, address, name, decimals, color)
    for account in self.status.wallet.accounts:
      if account.address == self.currentAccount.address:
        self.currentAccount.setAccountItem(account)
      else: 
        self.accounts.updateAssetsInList(account.address, account.assetList)
    self.accountListChanged()
    self.currentAccountChanged()

  proc updateView*(self: WalletView) =
    self.totalFiatBalanceChanged()
    self.currentAccountChanged()
    self.accountListChanged()
    self.accounts.forceUpdate()
    self.setCurrentAssetList(self.currentAccount.account.assetList)

  proc addCustomToken*(self: WalletView, address: string, name: string, symbol: string, decimals: string) {.slot.} =
    self.status.wallet.toggleAsset(symbol, true, address, name, parseInt(decimals), "")

  proc loadCollectiblesForAccount*(self: WalletView, address: string, currentCollectiblesList: seq[CollectibleList]) =
    if (currentCollectiblesList.len > 0):
      return
    # Add loading state if it is the current account
    if address == self.currentAccount.address:
      for collectibleType in status_collectibles.COLLECTIBLE_TYPES:
        self.currentCollectiblesLists.addCollectibleListToList(CollectibleList(
          collectibleType: collectibleType,
          collectiblesJSON: "[]",
          error: "",
          loading: 1
        ))

    # TODO find a way to use a loop to streamline this code
    # Spawn for each collectible. They can end in whichever order
    spawnAndSend(self, "setCollectiblesResult") do:
      $(%*{
        "address": address,
        "collectibleType": status_collectibles.CRYPTOKITTY,
        "collectiblesOrError": status_collectibles.getCryptoKitties(address)
      })
    spawnAndSend(self, "setCollectiblesResult") do:
      $(%*{
        "address": address,
        "collectibleType": status_collectibles.KUDO,
        "collectiblesOrError": status_collectibles.getKudos(address)
      })
    spawnAndSend(self, "setCollectiblesResult") do:
      $(%*{
        "address": address,
        "collectibleType": status_collectibles.ETHERMON,
        "collectiblesOrError": status_collectibles.getEthermons(address)
      })
    spawnAndSend(self, "setCollectiblesResult") do:
      $(%*{
        "address": address,
        "collectibleType": status_collectibles.STICKER,
        "collectiblesOrError": status_collectibles.getStickers(address)
      })

  proc setCollectiblesResult(self: WalletView, collectiblesJSON: string) {.slot.} =
    let collectibleData = parseJson(collectiblesJSON)
    let address = collectibleData["address"].getStr
    let collectibleType = collectibleData["collectibleType"].getStr
    
    var collectibles: JSONNode
    try:
      collectibles = parseJson(collectibleData["collectiblesOrError"].getStr)
    except Exception as e:
      # We failed parsing, this means the result is an error string
      self.currentCollectiblesLists.setErrorByType(
        collectibleType,
        $collectibleData["collectiblesOrError"]
      )
      return

    # Add the collectibles to the WalletAccount
    let index = self.accounts.getAccountindexByAddress(address)
    if index == -1: return
    self.accounts.addCollectibleListToAccount(index, collectibleType, $collectibles)
    
    if address == self.currentAccount.address:
      # Add CollectibleListJSON to the right list
      self.currentCollectiblesLists.setCollectiblesJSONByType(
        collectibleType,
        $collectibles
      )

  proc reloadCollectible*(self: WalletView, collectibleType: string) {.slot.} =
    let address = self.currentAccount.address
    # TODO find a cooler way to do this
    case collectibleType:
      of CRYPTOKITTY:
        spawnAndSend(self, "setCollectiblesResult") do:
          $(%*{
            "address": address,
            "collectibleType": status_collectibles.CRYPTOKITTY,
            "collectiblesOrError": status_collectibles.getCryptoKitties(address)
          })
      of KUDO:
        spawnAndSend(self, "setCollectiblesResult") do:
          $(%*{
            "address": address,
            "collectibleType": status_collectibles.KUDO,
            "collectiblesOrError": status_collectibles.getKudos(address)
          })
      of ETHERMON:
        spawnAndSend(self, "setCollectiblesResult") do:
          $(%*{
            "address": address,
            "collectibleType": status_collectibles.ETHERMON,
            "collectiblesOrError": status_collectibles.getEthermons(address)
          })
      of status_collectibles.STICKER:
        spawnAndSend(self, "setCollectiblesResult") do:
          $(%*{
            "address": address,
            "collectibleType": status_collectibles.STICKER,
            "collectiblesOrError": status_collectibles.getStickers(address)
          })
      else:
        error "Unrecognized collectible"
        return

    self.currentCollectiblesLists.setLoadingByType(collectibleType, 1)


  proc loadingTrxHistory*(self: WalletView, isLoading: bool) {.signal.}

  proc loadTransactionsForAccount*(self: WalletView, address: string) {.slot.} =
    self.loadingTrxHistory(true)
    spawnAndSend(self, "setTrxHistoryResult") do:
      $(%*{
        "address": address,
        "history": getTransfersByAddress(address)
      })

  proc setTrxHistoryResult(self: WalletView, historyJSON: string) {.slot.} =
    let historyData = parseJson(historyJSON)
    let transactions = historyData["history"].to(seq[Transaction]);
    let address = historyData["address"].getStr
    let index = self.accounts.getAccountindexByAddress(address)
    if index == -1: return
    self.accounts.getAccount(index).transactions = transactions
    if address == self.currentAccount.address:
      self.setCurrentTransactions(transactions)
    self.loadingTrxHistory(false)

  proc gasPricePredictionsChanged*(self: WalletView) {.signal.}

  proc getGasPricePredictions*(self: WalletView) {.slot.} =
    let prediction = self.status.wallet.getGasPricePredictions()
    self.safeLowGasPrice = prediction.safeLow
    self.standardGasPrice = prediction.standard
    self.fastGasPrice = prediction.fast
    self.fastestGasPrice = prediction.fastest
    self.gasPricePredictionsChanged()

  proc safeLowGasPrice*(self: WalletView): string {.slot.} = result = ?.self.safeLowGasPrice
  QtProperty[string] safeLowGasPrice:
    read = safeLowGasPrice
    notify = gasPricePredictionsChanged

  proc standardGasPrice*(self: WalletView): string {.slot.} = result = ?.self.standardGasPrice
  QtProperty[string] standardGasPrice:
    read = standardGasPrice
    notify = gasPricePredictionsChanged

  proc fastGasPrice*(self: WalletView): string {.slot.} = result = ?.self.fastGasPrice
  QtProperty[string] fastGasPrice:
    read = fastGasPrice
    notify = gasPricePredictionsChanged

  proc fastestGasPrice*(self: WalletView): string {.slot.} = result = ?.self.fastestGasPrice
  QtProperty[string] fastestGasPrice:
    read = fastestGasPrice
    notify = gasPricePredictionsChanged

  proc defaultGasLimit*(self: WalletView): string {.slot.} = result = ?.self.defaultGasLimit
  QtProperty[string] defaultGasLimit:
    read = defaultGasLimit

  proc getSNTAddress*(self: WalletView): string {.slot.} =
    result = getSNTAddress()

  proc getSNTBalance*(self: WalletView): string {.slot.} =
    let currAcct = status_wallet.getWalletAccounts()[0]
    result = getSNTBalance($currAcct.address)

  proc getDefaultAddress*(self: WalletView): string {.slot.} =
    result = $status_wallet.getWalletAccounts()[0].address
