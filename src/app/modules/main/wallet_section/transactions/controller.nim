import NimQml, json, json_serialization, stint, tables
import ./controller_interface
import io_interface
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

import status/types/transaction

import ../../../../../app_service/[main]
import ../../../../../app_service/tasks/[qt, threadpool]

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    transactionService: transaction_service.ServiceInterface
    walletAccountService: wallet_account_service.ServiceInterface

proc newController*[T](
  delegate: io_interface.AccessInterface, 
  transactionService: transaction_service.ServiceInterface,
  walletAccountService: wallet_account_service.ServiceInterface
): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.transactionService = transactionService
  result.walletAccountService = walletAccountService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method checkRecentHistory*[T](self: Controller[T]) =
  self.transactionService.checkRecentHistory()

method getWalletAccounts*[T](self: Controller[T]): seq[WalletAccountDto] =
  self.walletAccountService.getWalletAccounts()

method getAccountByAddress*[T](self: Controller[T], address: string): WalletAccountDto =
  self.walletAccountService.getAccountByAddress(address)

method loadTransactions*[T](self: Controller[T], address: string, toBlock: Uint256, limit: int, loadMore: bool) =
  let transactions = self.transactionService.getTransfersByAddressTemp(address, toBlock, limit, loadMore)
  self.setTrxHistoryResult(transactions)
  # TODO reimplement thread task
  # let arg = LoadTransactionsTaskArg(
  #   address: address,
  #   tptr: cast[ByteAddress](loadTransactionsTask),
  #   vptr: cast[ByteAddress](self.vptr),
  #   slot: "setTrxHistoryResult",
  #   toBlock: toBlock,
  #   limit: limit,
  #   loadMore: loadMore
  # )
  # self.appService.threadpool.start(arg)

method setTrxHistoryResult*[T](self: Controller[T], historyJSON: string) {.slot.} =
  let historyData = parseJson(historyJSON)
  let address = historyData["address"].getStr
  let wasFetchMore = historyData["loadMore"].getBool
  var transactions: seq[TransactionDto] = @[]
  for tx in historyData["history"]["result"].getElems():
    transactions.add(tx.toTransactionDto())

  self.delegate.setTrxHistoryResult(transactions, address, wasFetchMore)
