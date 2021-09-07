import NimQml
import json, chronicles

import ../../tasks/[qt, threadpool]
import ../../../status/[status, wallet2]
import ../../../status/libstatus/wallet as status_wallet

include async_tasks

logScope:
  topics = "wallet-async-service"

QtObject:
  type WalletService* = ref object of QObject
    status: Status
    threadpool: ThreadPool

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

  