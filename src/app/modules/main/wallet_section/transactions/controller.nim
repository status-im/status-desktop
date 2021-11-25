import NimQml, json, json_serialization, stint, tables, eventemitter, sugar, sequtils
import ./controller_interface
import io_interface
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import
  status/[status, wallet]

export controller_interface

import status/types/transaction

import ../../../../core/[main]
import ../../../../core/tasks/[qt, threadpool]

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    transactionService: transaction_service.Service
    walletAccountService: wallet_account_service.ServiceInterface

# Forward declaration
method loadTransactions*[T](self: Controller[T], address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false)
method getWalletAccounts*[T](self: Controller[T]): seq[WalletAccountDto]

proc newController*[T](
  delegate: io_interface.AccessInterface, 
  events: EventEmitter,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.ServiceInterface
): Controller[T] =
  result = Controller[T]()
  result.events = events
  result.delegate = delegate
  result.transactionService = transactionService
  result.walletAccountService = walletAccountService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
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
      else:
        echo "Unhandled wallet signal: ", data.eventType
  
  self.events.on(SIGNAL_TRANSACTIONS_LOADED) do(e:Args):
    let args = TransactionsLoadedArgs(e)
    self.delegate.setTrxHistoryResult(args.transactions, args.address, args.wasFetchMore)

method checkRecentHistory*[T](self: Controller[T]) =
  self.transactionService.checkRecentHistory()

method getWalletAccounts*[T](self: Controller[T]): seq[WalletAccountDto] =
  self.walletAccountService.getWalletAccounts()

method getWalletAccount*[T](self: Controller[T], accountIndex: int): WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

method getAccountByAddress*[T](self: Controller[T], address: string): WalletAccountDto =
  self.walletAccountService.getAccountByAddress(address)

method loadTransactions*[T](self: Controller[T], address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false) =
  self.transactionService.loadTransactions(address, toBlock, limit, loadMore)
