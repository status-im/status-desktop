import chronicles, sequtils, sugar, stint, json
import status/statusgo_backend_new/transactions as transactions

import ../wallet_account/service as wallet_account_service
import ./service_interface, ./dto

export service_interface

logScope:
  topics = "transaction-service"

import ../../../app_service/[main]
import ../../../app_service/tasks/[qt, threadpool]

type
  LoadTransactionsTaskArg* = ref object of QObjectTaskArg
    address: string
    toBlock: Uint256
    limit: int
    loadMore: bool

const loadTransactionsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[LoadTransactionsTaskArg](argEncoded)
    output = %*{
      "address": arg.address,
      "history": transactions.getTransfersByAddress(arg.address, arg.toBlock, arg.limit, arg.loadMore),
      "loadMore": arg.loadMore
    }
  arg.finish(output)

type 
  Service* = ref object of service_interface.ServiceInterface
    walletAccountService: wallet_account_service.ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(walletAccountService: wallet_account_service.ServiceInterface): Service =
  result = Service()
  result.walletAccountService = walletAccountService

method init*(self: Service) =
  discard

method checkRecentHistory*(self: Service) =
  try:
    let addresses = self.walletAccountService.getWalletAccounts().map(a => a.address)
    transactions.checkRecentHistory(addresses)
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getTransfersByAddress*(self: Service, address: string, toBlock: Uint256, limit: int, loadMore: bool = false): seq[TransactionDto] =
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

method getTransfersByAddressTemp*(self: Service, address: string, toBlock: Uint256, limit: int, loadMore: bool = false): string =
  try:
    let resp = transactions.getTransfersByAddress(address, toBlock, limit, loadMore)
    return $(%*{
      "address": address,
      "history": resp,
      "loadMore": loadMore
    })
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return