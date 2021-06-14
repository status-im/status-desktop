import # std libs
  atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables

import # vendor libs
  NimQml, chronicles, stint

import # status-desktop libs
  # ../../status/[status, wallet, settings, tokens],
  ../../status/[status, wallet, settings],
  ../../status/wallet/collectibles as status_collectibles,
  ../../status/wallet as status_wallet,
  ../../status/types,
  ../../status/utils as status_utils,
  ../../status/tokens as status_tokens,
  ../../status/ens as status_ens,
  views/[asset_list, accounts, account_list, account_item, token_list, transaction_list, collectibles_list, collectibles, transactions, gas, tokens, ens],
  ../../status/tasks/[qt, task_runner_impl], ../../status/signals/types as signal_types

const ZERO_ADDRESS* = "0x0000000000000000000000000000000000000000"

type
  InitBalancesTaskArg = ref object of QObjectTaskArg
    address: string
    tokenList: seq[string]

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

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      status: Status
      totalFiatBalance: string
      etherscanLink: string
      signingPhrase: string
      fetchingHistoryState: Table[string, bool]
      # currentTransactions: TransactionList
      accountsView: AccountsView
      collectiblesView: CollectiblesView
      transactionsView*: TransactionsView
      tokensView*: TokensView
      gasView*: GasView
      ensView*: EnsView
      dappBrowserAccount*: AccountItemView

  proc delete(self: WalletView) =
    self.accountsView.delete
    self.gasView.delete
    self.dappBrowserAccount.delete
    self.ensView.delete
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status

    result.accountsView = newAccountsView(status)
    result.collectiblesView = newCollectiblesView(status, result.accountsView)
    result.transactionsView = newTransactionsView(status, result.accountsView)
    result.tokensView = newTokensView(status, result.accountsView)
    result.gasView = newGasView(status)
    result.ensView = newEnsView(status)
    result.dappBrowserAccount = newAccountItemView()

    # result.currentTransactions = newTransactionList()
    result.totalFiatBalance = ""
    result.etherscanLink = ""
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

  proc getTransactions(self: WalletView): QVariant {.slot.} =
    newQVariant(self.transactionsView)

  QtProperty[QVariant] transactionsView:
    read = getTransactions

  proc getGas(self: WalletView): QVariant {.slot.} =
    newQVariant(self.gasView)

  QtProperty[QVariant] gasView:
    read = getGas

  proc getTokens(self: WalletView): QVariant {.slot.} =
    newQVariant(self.tokensView)

  QtProperty[QVariant] tokensView:
    read = getTokens

  proc getEns(self: WalletView): QVariant {.slot.} =
    newQVariant(self.ensView)

  QtProperty[QVariant] ensView:
    read = getEns

  proc setDappBrowserAddress*(self: WalletView)

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

  proc updateView*(self: WalletView) =
    self.setTotalFiatBalance(self.status.wallet.getTotalFiatBalance())
    self.totalFiatBalanceChanged()

    self.accountsView.currentAccount.assetList.setNewData(self.accountsView.currentAccount.account.assetList)
    self.accountsView.triggerUpdateAccounts()

    self.tokensView.setCurrentAssetList(self.accountsView.currentAccount.account.assetList)

  proc getAccountBalanceSuccess*(self: WalletView, jsonResponse: string) {.slot.} =
    let jsonObj = jsonResponse.parseJson()
    self.status.wallet.update(jsonObj["address"].getStr(), jsonObj["eth"].getStr(), jsonObj["tokens"])
    self.setTotalFiatBalance(self.status.wallet.getTotalFiatBalance())
    self.accountsView.triggerUpdateAccounts()
    self.updateView()

  proc getDefaultAddress*(self: WalletView): string {.slot.} =
    result = $self.status.wallet.getWalletAccounts()[0].address

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
    return self.transactionsView.currentTransactions.rowCount() > 0

  proc loadingTrxHistoryChanged*(self: WalletView, isLoading: bool) {.signal.}

  proc loadTransactionsForAccount*(self: WalletView, address: string) {.slot.} =
    self.loadingTrxHistoryChanged(true)
    self.transactionsView.loadTransactions("setTrxHistoryResult", address)

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
      self.transactionsView.setCurrentTransactions(
            self.accountsView.accounts.getAccount(index).transactions)
    self.loadingTrxHistoryChanged(false)

  proc setInitialRange*(self: WalletView) {.slot.} = 
    discard self.status.wallet.setInitialBlocksRange()

  proc setCurrentAccountByIndex*(self: WalletView, index: int) {.slot.} =
    if self.accountsView.setCurrentAccountByIndex(index):
      # TODO: get the account from above instead
      let selectedAccount = self.accountsView.accounts.getAccount(index)

      self.tokensView.setCurrentAssetList(selectedAccount.assetList)

      # Display currently known collectibles, and get latest from API/Contracts
      self.collectiblesView.setCurrentCollectiblesLists(selectedAccount.collectiblesLists)
      self.collectiblesView.loadCollectiblesForAccount(selectedAccount.address, selectedAccount.collectiblesLists)

      self.transactionsView.setCurrentTransactions(selectedAccount.transactions)

  proc addAccountToList*(self: WalletView, account: WalletAccount) =
    self.accountsView.addAccountToList(account)
    # If it's the first account we ever get, use its list as our first lists
    if (self.accountsView.accounts.rowCount == 1):
      self.tokensView.setCurrentAssetList(account.assetList)
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

  proc transactionCompleted*(self: WalletView, success: bool, txHash: string, revertReason: string = "") {.signal.}
