import NimQml, eventemitter, stint

import ./io_interface, ./view, ./controller
import ../../../../core/global_singleton
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    controller: controller.AccessInterface
    moduleLoaded: bool

# Forward declarations
method checkRecentHistory*[T](self: Module[T])
method getWalletAccounts*[T](self: Module[T]): seq[WalletAccountDto]
method loadTransactions*[T](self: Module[T], address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false)

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.ServiceInterface
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = controller.newController[Module[T]](result, events, transactionService, walletAccountService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("walletSectionTransactions", newQVariant(self.view))

  self.checkRecentHistory()

  let accounts = self.getWalletAccounts()

  self.controller.init()

  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method switchAccount*[T](self: Module[T], accountIndex: int) =
  let walletAccount = self.controller.getWalletAccount(accountIndex)
  self.view.switchAccount(walletAccount)

method checkRecentHistory*[T](self: Module[T]) =
  self.controller.checkRecentHistory()

method getWalletAccounts*[T](self: Module[T]): seq[WalletAccountDto] =
  self.controller.getWalletAccounts()

method getAccountByAddress*[T](self: Module[T], address: string): WalletAccountDto =
  self.controller.getAccountByAddress(address)

method loadTransactions*[T](self: Module[T], address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false) =
  let toBlockParsed = stint.fromHex(Uint256, toBlock)
  let txLimit = if toBlock == "0x0":
      limit
    else:
      limit + 1
    
  self.controller.loadTransactions(address, toBlockParsed, txLimit, loadMore)

method setTrxHistoryResult*[T](self: Module[T], transactions: seq[TransactionDto], address: string, wasFetchMore: bool) =
  self.view.setTrxHistoryResult(transactions, address, wasFetchMore)

method setHistoryFetchState*[T](self: Module[T], addresses: seq[string], isFetching: bool) =
  self.view.setHistoryFetchStateForAccounts(addresses, isFetching)
