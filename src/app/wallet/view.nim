import NimQml, Tables, strformat, strutils, chronicles, sequtils, json, std/wrapnils, parseUtils, stint, tables
import ../../status/[status, wallet]
import ../../status/wallet/collectibles as status_collectibles
import ../../status/libstatus/accounts/constants
import ../../status/libstatus/wallet as status_wallet
import ../../status/libstatus/settings as status_settings
import ../../status/libstatus/tokens
import ../../status/libstatus/types
import ../../status/libstatus/utils as status_utils
import ../../status/libstatus/eth/contracts
import ../../status/ens as status_ens
import views/[asset_list, account_list, account_item, token_list, transaction_list, collectibles_list]
import ../../status/tasks/[qt, task_runner_impl]

type
  SendTransactionTaskArg = ref object of QObjectTaskArg
    from_addr: string
    to: string
    assetAddress: string
    value: string
    gas: string
    gasPrice: string
    password: string
    uuid: string
  InitBalancesTaskArg = ref object of QObjectTaskArg
    address: string
    tokenList: seq[string]
  LoadCollectiblesTaskArg = ref object of QObjectTaskArg
    address: string
    collectiblesType: string
  GasPredictionsTaskArg = ref object of QObjectTaskArg
  LoadTransactionsTaskArg = ref object of QObjectTaskArg
    address: string
    blockNumber: string
  ResolveEnsTaskArg = ref object of QObjectTaskArg
    ens: string
    uuid: string
  WatchTransactionTaskArg = ref object of QObjectTaskArg
    transactionHash: string

const sendTransactionTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[SendTransactionTaskArg](argEncoded)
  var
    success: bool
    response: string
  if arg.assetAddress != ZERO_ADDRESS and not arg.assetAddress.isEmptyOrWhitespace:
    response = wallet.sendTokenTransaction(arg.from_addr, arg.to, arg.assetAddress, arg.value, arg.gas, arg.gasPrice, arg.password, success)
  else:
    response = wallet.sendTransaction(arg.from_addr, arg.to, arg.value, arg.gas, arg.gasPrice, arg.password, success)
  let output = %* { "result": %response, "success": %success, "uuid": %arg.uuid }
  arg.finish(output)

proc sendTransaction[T](self: T, slot: string, from_addr: string, to: string, assetAddress: string, value: string, gas: string, gasPrice: string, password: string, uuid: string) =
  let arg = SendTransactionTaskArg(
    tptr: cast[ByteAddress](sendTransactionTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    from_addr: from_addr,
    to: to,
    assetAddress: assetAddress,
    value: value,
    gas: gas,
    gasPrice: gasPrice,
    password: password,
    uuid: uuid
  )
  self.status.tasks.threadpool.start(arg)

const initBalancesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[InitBalancesTaskArg](argEncoded)
  var tokenBalances = initTable[string, string]()
  for token in arg.tokenList:
    tokenBalances[token] = getTokenBalance(token, arg.address)
  let output = %* {
    "address": arg.address,
    "eth": getEthBalance(arg.address),
    "tokens": tokenBalances
  }
  arg.finish(output)

proc initBalances[T](self: T, slot: string, address: string, tokenList: seq[string]) =
  let arg = InitBalancesTaskArg(
    tptr: cast[ByteAddress](initBalancesTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    address: address,
    tokenList: tokenList
  )
  self.status.tasks.threadpool.start(arg)

const loadCollectiblesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[LoadCollectiblesTaskArg](argEncoded)
  var collectiblesOrError = ""
  case arg.collectiblesType:
    of status_collectibles.CRYPTOKITTY:
      collectiblesOrError = status_collectibles.getCryptoKitties(arg.address)
    of status_collectibles.KUDO:
      collectiblesOrError = status_collectibles.getKudos(arg.address)
    of status_collectibles.ETHERMON:
      collectiblesOrError = status_collectibles.getEthermons(arg.address)
    of status_collectibles.STICKER:
      collectiblesOrError = status_collectibles.getStickers(arg.address)

  let output = %*{
    "address": arg.address,
    "collectibleType": arg.collectiblesType,
    "collectiblesOrError": collectiblesOrError
  }
  arg.finish(output)

proc loadCollectibles[T](self: T, slot: string, address: string, collectiblesType: string) =
  let arg = LoadCollectiblesTaskArg(
    tptr: cast[ByteAddress](loadCollectiblesTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    address: address,
    collectiblesType: collectiblesType,
  )
  self.status.tasks.threadpool.start(arg)

const getGasPredictionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[GasPredictionsTaskArg](argEncoded)
    output = %getGasPricePredictions()
  arg.finish(output)

proc getGasPredictions[T](self: T, slot: string) =
  let arg = GasPredictionsTaskArg(
    tptr: cast[ByteAddress](getGasPredictionsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot
  )
  self.status.tasks.threadpool.start(arg)

const loadTransactionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[LoadTransactionsTaskArg](argEncoded)
    output = %*{
      "address": arg.address,
      "history": getTransfersByAddress(arg.address)
    }
  arg.finish(output)

proc loadTransactions[T](self: T, slot: string, address: string) =
  let arg = LoadTransactionsTaskArg(
    tptr: cast[ByteAddress](loadTransactionsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    address: address
  )
  self.status.tasks.threadpool.start(arg)

const resolveEnsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[ResolveEnsTaskArg](argEncoded)
    output = %* { "address": status_ens.address(arg.ens), "uuid": arg.uuid }
  arg.finish(output)

proc resolveEns[T](self: T, slot: string, ens: string, uuid: string) =
  let arg = ResolveEnsTaskArg(
    tptr: cast[ByteAddress](resolveEnsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    ens: ens,
    uuid: uuid
  )
  self.status.tasks.threadpool.start(arg)

const watchTransactionTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[WatchTransactionTaskArg](argEncoded)
    response = status_wallet.watchTransaction(arg.transactionHash)
    output = %* { "result": response }
  arg.finish(output)

proc watchTransaction[T](self: T, slot: string, transactionHash: string) =
  let arg = WatchTransactionTaskArg(
    tptr: cast[ByteAddress](watchTransactionTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    transactionHash: transactionHash
  )
  self.status.tasks.threadpool.start(arg)

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      accounts*: AccountList
      currentAssetList*: AssetList
      currentCollectiblesLists*: CollectiblesList
      currentAccount: AccountItemView
      focusedAccount: AccountItemView
      dappBrowserAccount: AccountItemView
      currentTransactions: TransactionList
      defaultTokenList: TokenList
      customTokenList: TokenList
      status: Status
      totalFiatBalance: string
      etherscanLink: string
      safeLowGasPrice: string
      standardGasPrice: string
      fastGasPrice: string
      fastestGasPrice: string
      defaultGasLimit: string
      signingPhrase: string
      fetchingHistoryState: Table[string, bool]

  proc delete(self: WalletView) =
    self.accounts.delete
    self.currentAssetList.delete
    self.currentAccount.delete
    self.focusedAccount.delete
    self.dappBrowserAccount.delete
    self.currentTransactions.delete
    self.defaultTokenList.delete
    self.customTokenList.delete
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc setDappBrowserAddress*(self: WalletView)

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status
    result.accounts = newAccountList()
    result.currentAccount = newAccountItemView()
    result.focusedAccount = newAccountItemView()
    result.dappBrowserAccount = newAccountItemView()
    result.currentAssetList = newAssetList()
    result.currentTransactions = newTransactionList()
    result.currentCollectiblesLists = newCollectiblesList()
    result.defaultTokenList = newTokenList(status)
    result.customTokenList = newTokenList(status)
    result.totalFiatBalance = ""
    result.etherscanLink = ""
    result.safeLowGasPrice = "0"
    result.standardGasPrice = "0"
    result.fastGasPrice = "0"
    result.fastestGasPrice = "0"
    result.defaultGasLimit = "21000"
    result.signingPhrase = ""
    result.fetchingHistoryState = initTable[string, bool]()
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

  proc getStatusToken*(self: WalletView): string {.slot.} = self.status.wallet.getStatusToken

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

    self.setCurrentTransactions(selectedAccount.transactions)

  proc getCurrentAccount*(self: WalletView): QVariant {.slot.} =
    result = newQVariant(self.currentAccount)

  QtProperty[QVariant] currentAccount:
    read = getCurrentAccount
    write = setCurrentAccountByIndex
    notify = currentAccountChanged

  proc focusedAccountChanged*(self: WalletView) {.signal.}

  proc setFocusedAccountByAddress*(self: WalletView, address: string) {.slot.} =
    if(self.accounts.rowCount() == 0): return

    var index = self.accounts.getAccountindexByAddress(address)
    if index == -1: index = 0
    let selectedAccount = self.accounts.getAccount(index)
    if self.focusedAccount.address == selectedAccount.address: return
    self.focusedAccount.setAccountItem(selectedAccount)
    self.focusedAccountChanged()

  proc getFocusedAccount*(self: WalletView): QVariant {.slot.} =
    result = newQVariant(self.focusedAccount)

  QtProperty[QVariant] focusedAccount:
    read = getFocusedAccount
    write = setFocusedAccountByAddress
    notify = focusedAccountChanged

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
    if (cryptoBalance == "" or cryptoSymbol == "" or fiatSymbol == ""): return "0.00"
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
  
  proc estimateGas*(self: WalletView, from_addr: string, to: string, assetAddress: string, value: string, data: string = ""): string {.slot.} =
    var
      response: string
      success: bool
    if assetAddress != ZERO_ADDRESS and not assetAddress.isEmptyOrWhitespace:
      response = self.status.wallet.estimateTokenGas(from_addr, to, assetAddress, value, success)
    else:
      response = self.status.wallet.estimateGas(from_addr, to, value, data, success)

    if success == true:
      let res = fromHex[int](response)
      result = $(%* { "result": %res, "success": %success })
    else:
      result = $(%* { "result": "-1", "success": %success, "error": { "message": %response } })

  proc transactionWasSent*(self: WalletView, txResult: string) {.signal.}

  proc transactionSent(self: WalletView, txResult: string) {.slot.} =
    self.transactionWasSent(txResult)
    let jTxRes = txResult.parseJSON()
    let txHash = jTxRes{"result"}.getStr()
    if txHash != "":
      self.watchTransaction("transactionWatchResultReceived", txHash)

  proc sendTransaction*(self: WalletView, from_addr: string, to: string, assetAddress: string, value: string, gas: string, gasPrice: string, password: string, uuid: string) {.slot.} =
    self.sendTransaction("transactionSent", from_addr, to, assetAddress, value, gas, gasPrice, password, uuid)

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

  proc hasAsset*(self: WalletView, symbol: string): bool {.slot.} =
    self.status.wallet.hasAsset(symbol)

  proc toggleAsset*(self: WalletView, symbol: string) {.slot.} =
    self.status.wallet.toggleAsset(symbol)
    for account in self.status.wallet.accounts:
      if account.address == self.currentAccount.address:
        self.currentAccount.setAccountItem(account)
      else:
        self.accounts.updateAssetsInList(account.address, account.assetList)
    self.accountListChanged()
    self.currentAccountChanged()

  proc removeCustomToken*(self: WalletView, tokenAddress: string) {.slot.} =
    let t = getCustomTokens().getErc20ContractByAddress(parseAddress(tokenAddress))
    if t == nil: return
    self.status.wallet.hideAsset(t.symbol)
    removeCustomToken(tokenAddress)
    self.customTokenList.loadCustomTokens()
    for account in self.status.wallet.accounts:
      if account.address == self.currentAccount.address:
        self.currentAccount.setAccountItem(account)
      else: 
        self.accounts.updateAssetsInList(account.address, account.assetList)
    self.accountListChanged()
    self.currentAccountChanged()

  proc addCustomToken*(self: WalletView, address: string, name: string, symbol: string, decimals: string) {.slot.} =
    self.status.wallet.addCustomToken(symbol, true, address, name, parseInt(decimals), "")

  proc updateView*(self: WalletView) =
    self.setTotalFiatBalance(self.status.wallet.getTotalFiatBalance())
    self.totalFiatBalanceChanged()
    self.currentAccount.assetList.setNewData(self.currentAccount.account.assetList)
    self.currentAccountChanged()
    self.accountListChanged()
    self.accounts.forceUpdate()
    self.setCurrentAssetList(self.currentAccount.account.assetList)

  proc checkRecentHistory*(self:WalletView) {.slot.} =
    var addresses:seq[string] = @[]
    for acc in self.status.wallet.accounts:
      addresses.add(acc.address)
    discard status_wallet.checkRecentHistory(addresses)

  proc transactionWatchResultReceived(self: WalletView, watchResult: string) {.slot.} =
    let wTxRes = watchResult.parseJSON()["result"].getStr().parseJson(){"result"}
    if wTxRes.kind == JNull:
      self.checkRecentHistory()
    else:
      discard #TODO: Ask Simon if should we show an error popup indicating the trx wasn't mined in 10m or something

  proc getAccountBalanceSuccess*(self: WalletView, jsonResponse: string) {.slot.} =
    let jsonObj = jsonResponse.parseJson()
    self.status.wallet.update(jsonObj["address"].getStr(), jsonObj["eth"].getStr(), jsonObj["tokens"])
    self.setTotalFiatBalance(self.status.wallet.getTotalFiatBalance())
    self.accounts.forceUpdate()
    self.currentAccountChanged()
    self.updateView()


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
    # Create a thread in the threadpool for each collectible. They can end in whichever order
    self.loadCollectibles("setCollectiblesResult", address, status_collectibles.CRYPTOKITTY)
    self.loadCollectibles("setCollectiblesResult", address, status_collectibles.KUDO)
    self.loadCollectibles("setCollectiblesResult", address, status_collectibles.ETHERMON)
    self.loadCollectibles("setCollectiblesResult", address, status_collectibles.STICKER)

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
    self.loadCollectibles("setCollectiblesResult", address, collectibleType)
    self.currentCollectiblesLists.setLoadingByType(collectibleType, 1)

  proc gasPricePredictionsChanged*(self: WalletView) {.signal.}

  proc getGasPricePredictions*(self: WalletView) {.slot.} =
    self.getGasPredictions("getGasPricePredictionsResult")

  proc getGasPricePredictionsResult(self: WalletView, gasPricePredictionsJson: string) {.slot.} =
    let prediction = Json.decode(gasPricePredictionsJson, GasPricePrediction)
    self.safeLowGasPrice = fmt"{prediction.safeLow:.3f}"
    self.standardGasPrice = fmt"{prediction.standard:.3f}"
    self.fastGasPrice = fmt"{prediction.fast:.3f}"
    self.fastestGasPrice = fmt"{prediction.fastest:.3f}"
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

  proc getDefaultAddress*(self: WalletView): string {.slot.} =
    result = $status_wallet.getWalletAccounts()[0].address

  proc getDefaultTokenList(self: WalletView): QVariant {.slot.} =
    self.defaultTokenList.loadDefaultTokens()
    result = newQVariant(self.defaultTokenList)

  QtProperty[QVariant] defaultTokenList:
    read = getDefaultTokenList

  proc loadCustomTokens(self: WalletView) {.slot.} =
    self.customTokenList.loadCustomTokens()

  proc getCustomTokenList(self: WalletView): QVariant {.slot.} =
    result = newQVariant(self.customTokenList)

  QtProperty[QVariant] customTokenList:
    read = getCustomTokenList
  
  proc isKnownTokenContract*(self: WalletView, address: string): bool {.slot.} =
    return self.status.wallet.getKnownTokenContract(parseAddress(address)) != nil

  proc decodeTokenApproval*(self: WalletView, tokenAddress: string, data: string): string {.slot.} =
    let amount = data[74..len(data)-1]
    let token = getToken(tokenAddress)
    
    if(token != nil):
      let amountDec = $hex2Token(amount, token.decimals)
      return $(%* {"symbol": token.symbol, "amount": amountDec})
    
    return """{"error":"Unknown token address"}""";

  proc historyWasFetched*(self: WalletView) {.signal.}

  proc setHistoryFetchState*(self: WalletView, accounts: seq[string], isFetching: bool) =
    for acc in accounts:
      self.fetchingHistoryState[acc] = isFetching
    if not isFetching: self.historyWasFetched()

  proc isFetchingHistory*(self: WalletView, address: string): bool {.slot.} =
    if self.fetchingHistoryState.hasKey(address):
      return self.fetchingHistoryState[address]
    return true

  proc isHistoryFetched*(self: WalletView, address: string): bool {.slot.} =
    return self.currentTransactions.rowCount() > 0

  proc loadingTrxHistoryChanged*(self: WalletView, isLoading: bool) {.signal.}

  proc loadTransactionsForAccount*(self: WalletView, address: string) {.slot.} =
    self.loadingTrxHistoryChanged(true)
    self.loadTransactions("setTrxHistoryResult", address)

  proc getLatestTransactionHistory*(self: WalletView, accounts: seq[string]) =
    for acc in accounts:
      self.loadTransactionsForAccount(acc)

  proc initBalances*(self: WalletView, loadTransactions: bool = true) =
    for acc in self.status.wallet.accounts:
      let accountAddress = acc.address
      let tokenList = acc.assetList.filter(proc(x:Asset): bool = x.address != "").map(proc(x: Asset): string = x.address)
      self.initBalances("getAccountBalanceSuccess", accountAddress, tokenList)
      if loadTransactions: 
        self.loadTransactionsForAccount(accountAddress)

  proc setTrxHistoryResult(self: WalletView, historyJSON: string) {.slot.} =
    let historyData = parseJson(historyJSON)
    let transactions = historyData["history"].to(seq[Transaction]);
    let address = historyData["address"].getStr
    let index = self.accounts.getAccountindexByAddress(address)
    if index == -1: return
    self.accounts.getAccount(index).transactions = transactions
    if address == self.currentAccount.address:
      self.setCurrentTransactions(
            self.accounts.getAccount(index).transactions)
    self.loadingTrxHistoryChanged(false)

  proc resolveENS*(self: WalletView, ens: string, uuid: string) {.slot.} =
    self.resolveEns("ensResolved", ens, uuid)

  proc ensWasResolved*(self: WalletView, resolvedAddress: string, uuid: string) {.signal.}

  proc ensResolved(self: WalletView, addressUuidJson: string) {.slot.} =
    var
      parsed = addressUuidJson.parseJson
      address = parsed["address"].to(string)
      uuid = parsed["uuid"].to(string)
    if address == "0x":
      address = ""
    self.ensWasResolved(address, uuid)
  
  proc transactionCompleted*(self: WalletView, success: bool, txHash: string, revertReason: string = "") {.signal.}

  proc dappBrowserAccountChanged*(self: WalletView) {.signal.}

  proc setDappBrowserAddress*(self: WalletView) {.slot.} =
    if(self.accounts.rowCount() == 0): return

    let dappAddress = status_settings.getSetting[string](Setting.DappsAddress)
    var index = self.accounts.getAccountIndexByAddress(dappAddress)
    if index == -1: index = 0
    let selectedAccount = self.accounts.getAccount(index)
    if self.dappBrowserAccount.address == selectedAccount.address: return
    self.dappBrowserAccount.setAccountItem(selectedAccount)
    self.dappBrowserAccountChanged()

  proc getDappBrowserAccount*(self: WalletView): QVariant {.slot.} =
    result = newQVariant(self.dappBrowserAccount)

  QtProperty[QVariant] dappBrowserAccount:
    read = getDappBrowserAccount
    notify = dappBrowserAccountChanged

  proc setInitialRange*(self: WalletView) {.slot.} = 
    discard status_wallet.setInitialBlocksRange()
