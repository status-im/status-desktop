import atomics, strutils, sequtils, json, tables, chronicles, web3/[ethtypes, conversions], stint
import NimQml, json, sequtils, chronicles, strutils, strformat, json

import
  ../../../../status/[status, wallet, tokens],
  ../../../../status/tokens as status_tokens
import ../../../../app_service/[main]
import ../../../../app_service/tasks/[qt, threadpool]

import account_item, accounts, transactions, history

logScope:
  topics = "balance-view"

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
    slot: slot, address: address, tokenList: tokenList
  )
  self.appService.threadpool.start(arg)

QtObject:
  type BalanceView* = ref object of QObject
      status: Status
      appService: AppService
      totalFiatBalance: string
      accountsView: AccountsView
      transactionsView*: TransactionsView
      historyView*: HistoryView

  proc setup(self: BalanceView) = self.QObject.setup
  proc delete(self: BalanceView) = self.QObject.delete

  proc newBalanceView*(status: Status, appService: AppService, accountsView: AccountsView, transactionsView: TransactionsView, historyView: HistoryView): BalanceView =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.totalFiatBalance = ""
    result.accountsView = accountsView
    result.transactionsView = transactionsView
    result.historyView = historyView
    result.setup

  proc totalFiatBalanceChanged*(self: BalanceView) {.signal.}

  proc getTotalFiatBalance(self: BalanceView): string {.slot.} =
    self.status.wallet.getTotalFiatBalance()

  proc setTotalFiatBalance*(self: BalanceView, newBalance: string) =
    self.totalFiatBalance = newBalance
    self.totalFiatBalanceChanged()

  QtProperty[string] totalFiatBalance:
    read = getTotalFiatBalance
    write = setTotalFiatBalance
    notify = totalFiatBalanceChanged

  proc getFiatValue*(self: BalanceView, cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string {.slot.} =
    if (cryptoBalance == "" or cryptoSymbol == "" or fiatSymbol == ""): return "0.00"
    let val = self.status.wallet.convertValue(cryptoBalance, cryptoSymbol, fiatSymbol)
    result = fmt"{val:.2f}"

  proc getCryptoValue*(self: BalanceView, fiatBalance: string, fiatSymbol: string, cryptoSymbol: string): string {.slot.} =
    result = fmt"{self.status.wallet.convertValue(fiatBalance, fiatSymbol, cryptoSymbol)}"

  proc defaultCurrency*(self: BalanceView): string {.slot.} =
    self.status.wallet.getDefaultCurrency()

  proc defaultCurrencyChanged*(self: BalanceView) {.signal.}

  proc setDefaultCurrency*(self: BalanceView, currency: string) {.slot.} =
    self.status.wallet.setDefaultCurrency(currency)
    self.defaultCurrencyChanged()

  QtProperty[string] defaultCurrency:
    read = defaultCurrency
    write = setDefaultCurrency
    notify = defaultCurrencyChanged

  proc initBalances*(self: BalanceView, loadTransactions: bool = true) =
    for acc in self.status.wallet.accounts:
      let accountAddress = acc.address
      let tokenList = acc.assetList.filter(proc(x:Asset): bool = x.address != "").map(proc(x: Asset): string = x.address)
      self.initBalances("getAccountBalanceSuccess", accountAddress, tokenList)
      if loadTransactions: 
        self.historyView.loadTransactionsForAccount(accountAddress)

  proc initBalance(self: BalanceView, acc: WalletAccount, loadTransactions: bool = true) =
    let
      accountAddress = acc.address
      tokenList = acc.assetList.filter(proc(x:Asset): bool = x.address != "").map(proc(x: Asset): string = x.address)
    self.initBalances("getAccountBalanceSuccess", accountAddress, tokenList)
    if loadTransactions: 
      self.historyView.loadTransactionsForAccount(accountAddress)

  proc initBalance*(self: BalanceView, accountAddress: string, loadTransactions: bool = true) =
    var found = false
    var acc: WalletAccount
    for a in self.status.wallet.accounts:
      if a.address.toLowerAscii == accountAddress.toLowerAscii:
        found = true
        acc = a
        break
      
    if not found:
     error "Failed to init balance: could not find account", account=accountAddress
     return
    self.initBalance(acc, loadTransactions)

  proc getAccountBalanceSuccess*(self: BalanceView, jsonResponse: string) {.slot.} =
    let jsonObj = jsonResponse.parseJson()
    self.status.wallet.update(jsonObj["address"].getStr(), jsonObj["eth"].getStr(), jsonObj["tokens"])
    self.setTotalFiatBalance(self.status.wallet.getTotalFiatBalance())
    self.accountsView.triggerUpdateAccounts()
