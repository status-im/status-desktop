import NimQml, json, json_serialization, stint, tables, sugar, sequtils
import io_interface
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
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

# Forward declaration
proc loadTransactions*(self: Controller, address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false)
proc getWalletAccounts*(self: Controller): seq[WalletAccountDto]

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
): Controller =
  result = Controller()
  result.events = events
  result.delegate = delegate
  result.transactionService = transactionService
  result.walletAccountService = walletAccountService
  result.networkService = networkService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SignalType.Wallet.event) do(e:Args):
    var data = WalletSignal(e)
    case data.eventType:
      of "new-transfers":
        for account in data.accounts:
          # TODO find a way to use data.blockNumber
          self.loadTransactions(account, stint.fromHex(Uint256, "0x0"))
      of "recent-history-fetching":
        self.delegate.setHistoryFetchState(data.accounts, true)
      of "recent-history-ready":
        for account in data.accounts:
          self.loadTransactions(account, stint.fromHex(Uint256, "0x0"))
        self.delegate.setHistoryFetchState(data.accounts, false)
      of "non-archival-node-detected":
        let accounts = self.getWalletAccounts()
        let addresses = accounts.map(account => account.address)
        self.delegate.setHistoryFetchState(addresses, false)
        self.delegate.setIsNonArchivalNode(true)
      of "fetching-history-error":
        let accounts = self.getWalletAccounts()
        let addresses = accounts.map(account => account.address)
        self.delegate.setHistoryFetchState(addresses, false)
      else:
        echo "Unhandled wallet signal: ", data.eventType

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

  self.events.on(SIGNAL_PENDING_TX_COMPLETED) do(e:Args):
    self.walletAccountService.checkRecentHistory()

proc checkPendingTransactions*(self: Controller): seq[TransactionDto] =
  return self.transactionService.checkPendingTransactions()

proc checkRecentHistory*(self: Controller, calledFromTimerOrInit = false) =
  self.walletAccountService.checkRecentHistory(calledFromTimerOrInit)

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

proc estimateGas*(self: Controller, from_addr: string, to: string, assetSymbol: string, value: string, data: string): string =
  try:
    result = self.transactionService.estimateGas(from_addr, to, assetSymbol, value, data)
  except Exception as e:
    result = "0"

proc transfer*(self: Controller, from_addr: string, to_addr: string, tokenSymbol: string,
    value: string, uuid: string, priority: int, selectedRoutes: string, password: string) =
  self.transactionService.transfer(from_addr, to_addr, tokenSymbol, value, uuid, priority, selectedRoutes, password)

proc suggestedFees*(self: Controller, chainId: int): string = 
  let suggestedFees = self.transactionService.suggestedFees(chainId)
  return suggestedFees.toJson()

proc suggestedRoutes*(self: Controller, account: string, amount: Uint256, token: string, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs: seq[uint64], priority: int, sendType: int): string =
  let suggestedRoutes = self.transactionService.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, priority, sendType)
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
