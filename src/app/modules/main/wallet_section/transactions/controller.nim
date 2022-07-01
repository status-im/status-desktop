import NimQml, json, json_serialization, stint, tables, sugar, sequtils
import io_interface
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import ../../../../core/[main]
import ../../../../core/tasks/[qt, threadpool]

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
      else:
        echo "Unhandled wallet signal: ", data.eventType

  self.events.on(SIGNAL_TRANSACTIONS_LOADED) do(e:Args):
    let args = TransactionsLoadedArgs(e)
    self.delegate.setTrxHistoryResult(args.transactions, args.address, args.wasFetchMore)

  self.events.on(SIGNAL_TRANSACTION_SENT) do(e:Args):
    self.delegate.transactionWasSent(TransactionSentArgs(e).result)

proc checkPendingTransactions*(self: Controller) =
  self.transactionService.checkPendingTransactions()

proc checkRecentHistory*(self: Controller) =
  self.walletAccountService.checkRecentHistory()

proc getWalletAccounts*(self: Controller): seq[WalletAccountDto] =
  self.walletAccountService.getWalletAccounts()

proc getWalletAccount*(self: Controller, accountIndex: int): WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

proc getAccountByAddress*(self: Controller, address: string): WalletAccountDto =
  self.walletAccountService.getAccountByAddress(address)

proc loadTransactions*(self: Controller, address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false) =
  self.transactionService.loadTransactions(address, toBlock, limit, loadMore)

proc estimateGas*(self: Controller, from_addr: string, to: string, assetSymbol: string, value: string, data: string): string =
  result = self.transactionService.estimateGas(from_addr, to, assetSymbol, value, data)

proc transfer*(self: Controller, from_addr: string, to_addr: string, tokenSymbol: string,
    value: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string,maxFeePerGas: string,
    password: string, chainId: string, uuid: string, eip1559Enabled: bool,
): bool =
  result = self.transactionService.transfer(from_addr, to_addr, tokenSymbol, value, gas,
    gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, chainId, uuid, eip1559Enabled)

proc suggestedFees*(self: Controller, chainId: int): string = 
  let suggestedFees = self.transactionService.suggestedFees(chainId)
  return suggestedFees.toJson()

proc suggestedRoutes*(self: Controller, account: string, amount: float64, token: string, disabledChainIDs: seq[uint64]): string =
  let suggestedRoutes = self.transactionService.suggestedRoutes(account, amount, token, disabledChainIDs)
  return suggestedRoutes.toJson()

proc getChainIdForChat*(self: Controller): int =
  return self.networkService.getNetworkForChat().chainId

proc getChainIdForBrowser*(self: Controller): int =
  return self.networkService.getNetworkForBrowser().chainId

proc getEstimatedTime*(self: Controller, chainId: int, maxFeePerGas: string): EstimatedTime = 
  return self.transactionService.getEstimatedTime(chainId, maxFeePerGas)
