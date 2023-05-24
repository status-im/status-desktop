import NimQml, json, json_serialization, stint, tables, sugar, sequtils
import io_interface
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/collectible/service as collectible_service
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

import ../../../../core/[main]
import ../../../../core/tasks/[qt, threadpool]
import ./backend/transactions

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    transactionService: transaction_service.Service
    networkService: network_service.Service
    walletAccountService: wallet_account_service.Service
    currencyService: currency_service.Service

# Forward declaration
proc loadTransactions*(self: Controller, address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false)
proc getWalletAccounts*(self: Controller): seq[WalletAccountDto]

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  currencyService: currency_service.Service,
): Controller =
  result = Controller()
  result.events = events
  result.delegate = delegate
  result.transactionService = transactionService
  result.walletAccountService = walletAccountService
  result.networkService = networkService
  result.currencyService = currencyService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_TRANSACTION_SENT) do(e:Args):
    self.delegate.transactionWasSent(TransactionSentArgs(e).result)

  self.events.on(SIGNAL_HISTORY_FETCHING) do (e:Args):
    let args = HistoryArgs(e)
    self.delegate.setHistoryFetchState(args.addresses, isFetching = true)

  self.events.on(SIGNAL_HISTORY_READY) do (e:Args):
    let args = HistoryArgs(e)
    self.delegate.setHistoryFetchState(args.addresses, isFetching = true)

  self.events.on(SIGNAL_HISTORY_NON_ARCHIVAL_NODE) do (e:Args):
    let accounts = self.getWalletAccounts()
    let addresses = accounts.map(account => account.address)
    self.delegate.setHistoryFetchState(addresses, isFetching = false)
    self.delegate.setIsNonArchivalNode(true)

  self.events.on(SIGNAL_HISTORY_ERROR) do (e:Args):
    let accounts = self.getWalletAccounts()
    let addresses = accounts.map(account => account.address)
    self.delegate.setHistoryFetchState(addresses, isFetching = false, hasMore = false)

  self.events.on(SIGNAL_TRANSACTIONS_LOADED) do(e:Args):
    let args = TransactionsLoadedArgs(e)
    self.delegate.setHistoryFetchState(@[args.address], isFetching = false)
    self.delegate.setTrxHistoryResult(args.transactions, args.collectibles, args.address, args.wasFetchMore)

  self.events.on(SIGNAL_TRANSACTION_LOADING_COMPLETED_FOR_ALL_NETWORKS) do(e:Args):
    let args = TransactionsLoadedArgs(e)
    self.delegate.setHistoryFetchState(args.address, args.allTxLoaded, isFetching = false)

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.delegate.refreshTransactions()

  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    # TODO: Rebuild Transaction items
    discard

  self.events.on(SIGNAL_COLLECTIBLES_UPDATED) do(e:Args):
    # TODO: Refresh collectible data in Transaction items
    discard

proc watchPendingTransactions*(self: Controller): seq[TransactionDto] =
  return self.transactionService.watchPendingTransactions()

proc getPendingTransactions*(self: Controller): seq[TransactionDto] =
  return self.transactionService.getPendingTransactions()

proc getWalletAccounts*(self: Controller): seq[WalletAccountDto] =
  self.walletAccountService.getWalletAccounts()

proc getWalletAccountByAddress*(self: Controller, address: string): WalletAccountDto =
  return self.walletAccountService.getAccountByAddress(address)

proc loadTransactions*(self: Controller, address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false) =
  self.transactionService.loadTransactions(address, toBlock, limit, loadMore)

proc getAllTransactions*(self: Controller, address: string): seq[TransactionDto] =
  return self.transactionService.getAllTransactions(address)

proc getChainIdForChat*(self: Controller): int =
  return self.networkService.getNetworkForChat().chainId

proc getChainIdForBrowser*(self: Controller): int =
  return self.networkService.getNetworkForBrowser().chainId

proc getLatestBlockNumber*(self: Controller, chainId: int): string =
  return self.transactionService.getLatestBlockNumber(chainId)

proc getEnabledChainIds*(self: Controller): seq[int] = 
  return self.networkService.getNetworks().filter(n => n.enabled).map(n => n.chainId)

proc getCurrencyFormat*(self: Controller, symbol: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(symbol)

proc findTokenSymbolByAddress*(self: Controller, address: string): string =
  return self.walletAccountService.findTokenSymbolByAddress(address)

proc getMultiTransactions*(self: Controller, transactionIDs: seq[int]): seq[MultiTransactionDto] =
  return transaction_service.getMultiTransactions(transactionIDs)
