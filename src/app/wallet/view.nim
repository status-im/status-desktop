import # std libs
  atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables

import # vendor libs
  NimQml, chronicles, stint

import # status-desktop libs
  ../../status/[status, wallet, settings, tokens],
  ../../status/wallet/collectibles as status_collectibles,
  ../../status/wallet as status_wallet,
  ../../status/types,
  ../../status/utils as status_utils,
  ../../status/tokens as status_tokens,
  ../../status/ens as status_ens,
  views/[asset_list, accounts, account_list, account_item, token_list, transaction_list, collectibles_list, collectibles],
  ../../status/tasks/[qt, task_runner_impl], ../../status/signals/types as signal_types

const ZERO_ADDRESS* = "0x0000000000000000000000000000000000000000"

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
    tokenBalances[token] = status_tokens.getTokenBalance(token, arg.address)
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
      "history": status_wallet.getTransfersByAddress(arg.address)
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
      currentAssetList*: AssetList
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
      accountsView: AccountsView
      collectiblesView: CollectiblesView
      dappBrowserAccount*: AccountItemView

  proc delete(self: WalletView) =
    self.accountsView.delete
    self.currentAssetList.delete
    self.currentTransactions.delete
    self.defaultTokenList.delete
    self.customTokenList.delete
    self.dappBrowserAccount.delete
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status

    result.accountsView = newAccountsView(status)
    result.collectiblesView = newCollectiblesView(status, result.accountsView)
    result.dappBrowserAccount = newAccountItemView()

    result.currentAssetList = newAssetList()
    result.currentTransactions = newTransactionList()
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

  proc getAccounts(self: WalletView): QVariant {.slot.} =
    newQVariant(self.accountsView)

  QtProperty[QVariant] accountsView:
    read = getAccounts

  proc getCollectibles(self: WalletView): QVariant {.slot.} =
    newQVariant(self.collectiblesView)

  QtProperty[QVariant] collectiblesView:
    read = getCollectibles

  proc setDappBrowserAddress*(self: WalletView)

  proc setCurrentAssetList*(self: WalletView, assetList: seq[Asset])

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
    self.accountsView.setAccountItems()

  proc removeCustomToken*(self: WalletView, tokenAddress: string) {.slot.} =
    let t = self.status.tokens.getCustomTokens().getErc20ContractByAddress(parseAddress(tokenAddress))
    if t == nil: return
    self.status.wallet.hideAsset(t.symbol)
    self.status.tokens.removeCustomToken(tokenAddress)
    self.customTokenList.loadCustomTokens()
    self.accountsView.setAccountItems()

  proc addCustomToken*(self: WalletView, address: string, name: string, symbol: string, decimals: string) {.slot.} =
    self.status.wallet.addCustomToken(symbol, true, address, name, parseInt(decimals), "")

  proc updateView*(self: WalletView) =
    self.setTotalFiatBalance(self.status.wallet.getTotalFiatBalance())
    self.totalFiatBalanceChanged()

    self.accountsView.currentAccount.assetList.setNewData(self.accountsView.currentAccount.account.assetList)
    self.accountsView.triggerUpdateAccounts()

    self.setCurrentAssetList(self.accountsView.currentAccount.account.assetList)

  proc checkRecentHistory*(self:WalletView) {.slot.} =
    var addresses:seq[string] = @[]
    for acc in self.status.wallet.accounts:
      addresses.add(acc.address)
    discard self.status.wallet.checkRecentHistory(addresses)

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
    self.accountsView.triggerUpdateAccounts()
    self.updateView()

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
    result = $self.status.wallet.getWalletAccounts()[0].address

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
    let token = self.status.tokens.getToken(tokenAddress)

    if(token != nil):
      let amountDec = $self.status.wallet.hex2Token(amount, token.decimals)
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
    let index = self.accountsView.accounts.getAccountindexByAddress(address)
    if index == -1: return
    self.accountsView.accounts.getAccount(index).transactions = transactions
    if address == self.accountsView.currentAccount.address:
      self.setCurrentTransactions(
            self.accountsView.accounts.getAccount(index).transactions)
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

  proc setInitialRange*(self: WalletView) {.slot.} = 
    discard self.status.wallet.setInitialBlocksRange()

  proc setCurrentAccountByIndex*(self: WalletView, index: int) {.slot.} =
    if self.accountsView.setCurrentAccountByIndex(index):
      # TODO: get the account from above instead
      let selectedAccount = self.accountsView.accounts.getAccount(index)

      self.setCurrentAssetList(selectedAccount.assetList)

      # Display currently known collectibles, and get latest from API/Contracts
      self.collectiblesView.setCurrentCollectiblesLists(selectedAccount.collectiblesLists)
      self.collectiblesView.loadCollectiblesForAccount(selectedAccount.address, selectedAccount.collectiblesLists)

      self.setCurrentTransactions(selectedAccount.transactions)

  proc addAccountToList*(self: WalletView, account: WalletAccount) =
    self.accountsView.addAccountToList(account)
    # If it's the first account we ever get, use its list as our first lists
    if (self.accountsView.accounts.rowCount == 1):
      self.setCurrentAssetList(account.assetList)
      # discard self.accountsView.setCurrentAccountByIndex(0)
      discard self.accountsView.setCurrentAccountByIndex(0)
    # self.accountsView.accountListChanged()

  proc dappBrowserAccountChanged*(self: WalletView) {.signal.}

  proc setDappBrowserAddress*(self: WalletView) {.slot.} =
    if(self.accountsView.accounts.rowCount() == 0): return

    let dappAddress = self.status.settings.getSetting[:string](Setting.DappsAddress)
    var index = self.accountsView.accounts.getAccountIndexByAddress(dappAddress)
    if index == -1: index = 0
    let selectedAccount = self.accountsView.accounts.getAccount(index)
    if self.dappBrowserAccount.address == selectedAccount.address: return
    self.dappBrowserAccount.setAccountItem(selectedAccount)
    self.dappBrowserAccountChanged()

  proc getDappBrowserAccount*(self: WalletView): QVariant {.slot.} =
    result = newQVariant(self.dappBrowserAccount)

  QtProperty[QVariant] dappBrowserAccount:
    read = getDappBrowserAccount
    notify = dappBrowserAccountChanged
