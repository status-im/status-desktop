import NimQml
import json, chronicles, stint, sequtils, sugar

import ../../tasks/[qt, threadpool]
import status/[status, wallet2]
import status/types/[transaction]
import status/statusgo_backend/wallet as status_wallet

include async_tasks

logScope:
  topics = "wallet-service"

const TransactionsPageSize = 20

QtObject:
  type WalletService* = ref object of QObject
    status: Status
    threadpool: ThreadPool
    receivedTransactions: tuple[address: string, transactionIds: seq[string]]

  proc setup(self: WalletService) = 
    self.QObject.setup
  
  proc delete*(self: WalletService) =
    self.QObject.delete

  proc newWalletService*(status: Status, threadpool: ThreadPool): WalletService =
    new(result, delete)
    result.status = status
    result.threadpool = threadpool  
    result.setup()

  proc onAsyncFetchCryptoServices*(self: WalletService, response: string) {.slot.} =
    self.status.wallet2.onAsyncFetchCryptoServices(response)

  proc asyncFetchCryptoServices*(self: WalletService) =
    ## Asynchronous request for the list of services to buy/sell crypto.
    let arg = QObjectTaskArg(
      tptr: cast[ByteAddress](asyncGetCryptoServicesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncFetchCryptoServices"
    )
    self.threadpool.start(arg)

  proc onAsyncTransactionFetched*(self: WalletService, response: string) {.slot.} =
    var address: string
    var transactions: seq[Transaction]

    let responseObject = response.parseJson
    if (responseObject.kind != JObject):
      info "fetched async transactions response is not a json object"
      self.status.wallet2.onAsyncTransactionFetched(address, transactions)
      return

    transactions = responseObject["transactions"].to(seq[Transaction])
    address = responseObject["address"].getStr

    if(self.receivedTransactions.address.len == 0):
      self.receivedTransactions.address = address
      let ids = transactions.map(tx => tx.id)
      self.receivedTransactions.transactionIds = ids
    elif (self.receivedTransactions.address == address):
      transactions.keepIf(proc(tx: Transaction): bool = 
        self.receivedTransactions.transactionIds.contains(tx.id))
      let ids = transactions.map(tx => tx.id)
      self.receivedTransactions.transactionIds.add(ids)

    self.status.wallet2.onAsyncTransactionFetched(address, transactions)

  proc asyncFetchInitialTransactions*(self: WalletService, address: string) =
    ## Asynchronous request for the initial set of transactions for passed address.
    self.receivedTransactions.address = ""
    self.receivedTransactions.transactionIds = @[]
    let arg = AsyncFetchTransactionsTaskArg(
      tptr: cast[ByteAddress](asyncFetchTransactionTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncTransactionFetched",
      address: address,
      toBlock: stint.fromHex(Uint256, "0x0"),
      limit: TransactionsPageSize,
      loadMore: false
    )
    self.threadpool.start(arg)

  proc asyncFetchMoreTransactions*(self: WalletService, address, blockNumber: string) =
    ## Asynchronous request for the next set of transactions for passed address, 
    ## starting from block with blockNumber.
    let arg = AsyncFetchTransactionsTaskArg(
      tptr: cast[ByteAddress](asyncFetchTransactionTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncTransactionFetched",
      address: address,
      toBlock: stint.fromHex(Uint256, blockNumber),
      limit: TransactionsPageSize,
      loadMore: true
    )
    self.threadpool.start(arg)