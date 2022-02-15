import NimQml, json, json_serialization, stint, tables, sugar, sequtils
import ./controller_interface
import io_interface
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

import ../../../../core/[main]
import ../../../../core/tasks/[qt, threadpool]

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    transactionService: transaction_service.Service
    walletAccountService: wallet_account_service.ServiceInterface

# Forward declaration
method loadTransactions*(self: Controller, address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false)
method getWalletAccounts*(self: Controller): seq[WalletAccountDto]

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.ServiceInterface
): Controller =
  result = Controller()
  result.events = events
  result.delegate = delegate
  result.transactionService = transactionService
  result.walletAccountService = walletAccountService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
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

method checkPendingTransactions*(self: Controller) =
  self.transactionService.checkPendingTransactions()

method checkRecentHistory*(self: Controller) =
  self.transactionService.checkRecentHistory()

method getWalletAccounts*(self: Controller): seq[WalletAccountDto] =
  self.walletAccountService.getWalletAccounts()

method getWalletAccount*(self: Controller, accountIndex: int): WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

method getAccountByAddress*(self: Controller, address: string): WalletAccountDto =
  self.walletAccountService.getAccountByAddress(address)

method loadTransactions*(self: Controller, address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false) =
  self.transactionService.loadTransactions(address, toBlock, limit, loadMore)

method estimateGas*(self: Controller, from_addr: string, to: string, assetAddress: string, value: string, data: string): string =
  result = self.transactionService.estimateGas(from_addr, to, assetAddress, value, data)

method transferEth*(self: Controller, from_addr: string, to_addr: string, value: string,
  gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string,
  password: string, uuid: string): bool =
  result = self.transactionService.transferEth(from_addr, to_addr, value, gas, gasPrice,
    maxPriorityFeePerGas, maxFeePerGas, password, uuid)

method transferTokens*(self: Controller, from_addr: string, to_addr: string, contractAddress: string,
    value: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string,maxFeePerGas: string,
    password: string, uuid: string): bool =
  result = self.transactionService.transferTokens(from_addr, to_addr, contractAddress, value, gas,
    gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, uuid)
