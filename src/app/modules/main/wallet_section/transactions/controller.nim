import NimQml, json, json_serialization, stint, tables, sugar, sequtils
import io_interface
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

import ../../../../core/[main]
import ../../../../core/tasks/[qt, threadpool]

const UNIQUE_WALLET_SECTION_TRANSACTION_MODULE_IDENTIFIER* = "WalletSection-TransactionModule"

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
  self.events.on(SIGNAL_HISTORY_FETCHING) do (e:Args):
    let args = HistoryArgs(e)
    self.delegate.setHistoryFetchState(args.addresses, isFetching = true)

  self.events.on(SIGNAL_HISTORY_READY) do (e:Args):
    let args = HistoryArgs(e)
    self.delegate.setHistoryFetchState(args.addresses, isFetching = false)

  self.events.on(SIGNAL_HISTORY_NON_ARCHIVAL_NODE) do (e:Args):
    let accounts = self.getWalletAccounts()
    let addresses = accounts.map(account => account.address)
    self.delegate.setHistoryFetchState(addresses, isFetching = false)
    self.delegate.setIsNonArchivalNode(true)

  self.events.on(SIGNAL_HISTORY_ERROR) do (e:Args):
    let accounts = self.getWalletAccounts()
    let addresses = accounts.map(account => account.address)
    self.delegate.setHistoryFetchState(addresses, isFetching = false)
    
  self.events.on(SIGNAL_TRANSACTIONS_LOADED) do(e:Args):
    let args = TransactionsLoadedArgs(e)
    self.delegate.setTrxHistoryResult(args.transactions, args.address, args.wasFetchMore)

  self.events.on(SIGNAL_TRANSACTION_SENT) do(e:Args):
    self.delegate.transactionWasSent(TransactionSentArgs(e).result)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_WALLET_SECTION_TRANSACTION_MODULE_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.password)

  self.events.on(SIGNAL_SUGGESTED_ROUTES_READY) do(e:Args):
    self.delegate.suggestedRoutesReady(SuggestedRoutesArgs(e).suggestedRoutes)

  self.events.on(SIGNAL_TRANSACTION_LOADING_COMPLETED_FOR_ALL_NETWORKS) do(e:Args):
    let args = TransactionsLoadedArgs(e)
    self.delegate.setHistoryFetchState(args.address, isFetching = false)

proc watchPendingTransactions*(self: Controller): seq[TransactionDto] =
  return self.transactionService.watchPendingTransactions()

proc getPendingTransactions*(self: Controller): seq[TransactionDto] =
  return self.transactionService.getPendingTransactions()

proc getWalletAccounts*(self: Controller): seq[WalletAccountDto] =
  self.walletAccountService.getWalletAccounts()

proc getWalletAccount*(self: Controller, accountIndex: int): WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

proc getAccountByAddress*(self: Controller, address: string): WalletAccountDto =
  self.walletAccountService.getAccountByAddress(address)

proc getMigratedKeyPairByKeyUid*(self: Controller, keyUid: string): seq[KeyPairDto] =
  return self.walletAccountService.getMigratedKeyPairByKeyUid(keyUid)

proc loadTransactions*(self: Controller, address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false) =
  self.transactionService.loadTransactions(address, toBlock, limit, loadMore)

proc transfer*(self: Controller, from_addr: string, to_addr: string, tokenSymbol: string,
    value: string, uuid: string, selectedRoutes: string, password: string) =
  self.transactionService.transfer(from_addr, to_addr, tokenSymbol, value, uuid, selectedRoutes, password)

proc suggestedFees*(self: Controller, chainId: int): string = 
  let suggestedFees = self.transactionService.suggestedFees(chainId)
  return suggestedFees.toJson()

proc suggestedRoutes*(self: Controller, account: string, amount: Uint256, token: string, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs: seq[uint64], sendType: int, lockedInAmounts: string): string =
  let suggestedRoutes = self.transactionService.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts)
  return suggestedRoutes.toJson()

proc getChainIdForChat*(self: Controller): int =
  return self.networkService.getNetworkForChat().chainId

proc getChainIdForBrowser*(self: Controller): int =
  return self.networkService.getNetworkForBrowser().chainId

proc getEstimatedTime*(self: Controller, chainId: int, maxFeePerGas: string): EstimatedTime = 
  return self.transactionService.getEstimatedTime(chainId, maxFeePerGas)

proc getLastTxBlockNumber*(self: Controller): string =
  return self.transactionService.getLastTxBlockNumber(self.networkService.getNetworkForBrowser().chainId)


proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_WALLET_SECTION_TRANSACTION_MODULE_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getCurrencyFormat*(self: Controller, symbol: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(symbol)

proc findTokenSymbolByAddress*(self: Controller, address: string): string =
  return self.walletAccountService.findTokenSymbolByAddress(address)
