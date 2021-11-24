import NimQml, chronicles, sequtils, sugar, stint, json
import status/statusgo_backend_new/transactions as transactions
import status/statusgo_backend/wallet

import eventemitter

import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]
import ../wallet_account/service as wallet_account_service
import ./service_interface, ./dto

export service_interface

logScope:
  topics = "transaction-service"

include async_tasks

# Signals which may be emitted by this service:
const SIGNAL_TRANSACTIONS_LOADED* = "SIGNAL_TRANSACTIONS_LOADED"

type
  TransactionsLoadedArgs* = ref object of Args
    transactions*: seq[TransactionDto]
    address*: string
    wasFetchMore*: bool

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    walletAccountService: wallet_account_service.ServiceInterface

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool, walletAccountService: wallet_account_service.ServiceInterface): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.walletAccountService = walletAccountService

  proc init*(self: Service) =
    discard

  proc checkRecentHistory*(self: Service) =
    try:
      let addresses = self.walletAccountService.getWalletAccounts().map(a => a.address)
      transactions.checkRecentHistory(addresses)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc getPendingTransactions*(self: Service): string =
    wallet.getPendingTransactions()

  proc getTransfersByAddress*(self: Service, address: string, toBlock: Uint256, limit: int, loadMore: bool = false): seq[TransactionDto] =
    try:
      let response = transactions.getTransfersByAddress(address, toBlock, limit, loadMore)

      result = map(
        response.result.getElems(),
        proc(x: JsonNode): TransactionDto = x.toTransactionDto()
      )
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc setTrxHistoryResult*(self: Service, historyJSON: string) {.slot.} =
    let historyData = parseJson(historyJSON)
    let address = historyData["address"].getStr
    let wasFetchMore = historyData["loadMore"].getBool
    var transactions: seq[TransactionDto] = @[]
    for tx in historyData["history"]["result"].getElems():
      transactions.add(tx.toTransactionDto())

    # emit event
    self.events.emit(SIGNAL_TRANSACTIONS_LOADED, TransactionsLoadedArgs(
      transactions: transactions,
      address: address,
      wasFetchMore: wasFetchMore
    ))

  proc loadTransactions*(self: Service, address: string, toBlock: Uint256, limit: int = 20, loadMore: bool = false) =
    let arg = LoadTransactionsTaskArg(
      address: address,
      tptr: cast[ByteAddress](loadTransactionsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setTrxHistoryResult",
      toBlock: toBlock,
      limit: limit,
      loadMore: loadMore
    )
    self.threadpool.start(arg)