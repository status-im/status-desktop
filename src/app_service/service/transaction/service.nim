import NimQml, chronicles, sequtils, sugar, stint, strutils, json, strformat
import status/transactions as transactions
import status/wallet as status_wallet
import status/eth

import ../ens/utils as ens_utils
from ../../common/account_constants import ZERO_ADDRESS

import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]
import ../wallet_account/service as wallet_account_service
import ../eth/service as eth_service
import ../network/service as network_service
import ../settings/service as settings_service
import ../eth/dto/transaction as transaction_data_dto
import ../eth/dto/[contract, method_dto]
import ./dto as transaction_dto
import ../eth/utils as eth_utils
import ../../common/conversion

export transaction_dto

logScope:
  topics = "transaction-service"

include async_tasks
include ../../common/json_utils

# Signals which may be emitted by this service:
const SIGNAL_TRANSACTIONS_LOADED* = "transactionsLoaded"

type 
  TransactionMinedArgs* = ref object of Args
    data*: string
    transactionHash*: string
    success*: bool
    revertReason*: string

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
    ethService: eth_service.ServiceInterface
    networkService: network_service.ServiceInterface
    settingsService: settings_service.ServiceInterface

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      walletAccountService: wallet_account_service.ServiceInterface,
      ethService: eth_service.ServiceInterface,
      networkService: network_service.ServiceInterface,
      settingsService: settings_service.ServiceInterface
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.walletAccountService = walletAccountService
    result.ethService = ethService
    result.networkService = networkService
    result.settingsService = settingsService

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
    try:
      # this may be improved (need to add some checkings) but due to removing `status-lib` dependencies, channges made
      # in this go are as minimal as possible
      let response = status_wallet.getPendingTransactions()
      return response.result.getStr
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc trackPendingTransaction*(self: Service, hash: string, fromAddress: string, toAddress: string, trxType: string, 
    data: string) =
    try:
      discard transactions.trackPendingTransaction(hash, fromAddress, toAddress, trxType, data)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc getTransfersByAddress*(self: Service, address: string, toBlock: Uint256, limit: int, loadMore: bool = false): seq[TransactionDto] =
    try:
      let limitAsHex = "0x" & eth_utils.stripLeadingZeros(limit.toHex)
      let response = transactions.getTransfersByAddress(address, toBlock, limitAsHex, loadMore)

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

  proc estimateGas*(
      self: Service,
      from_addr: string,
      to: string,
      assetAddress: string,
      value: string,
      data: string = ""
    ): string {.slot.} =
    var response: RpcResponse[JsonNode]
    # TODO make this async
    try:
      if assetAddress != ZERO_ADDRESS and not assetAddress.isEmptyOrWhitespace:
        var tx = buildTokenTransaction(
            parseAddress(from_addr),
            parseAddress(assetAddress)
          )
        let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
        let network = self.networkService.getNetwork(networkType)
        let contract = self.ethService.findErc20Contract(network.chainId, parseAddress(assetAddress))
        if contract == nil:
          raise newException(ValueError, fmt"Could not find ERC-20 contract with address '{assetAddress}' for the current network")

        let transfer = Transfer(to: parseAddress(to), value: conversion.eth2Wei(parseFloat(value), contract.decimals))
        let transferMethod = contract.getMethod("transfer")
        var success: bool
        let gas = transferMethod.estimateGas(tx, transfer, success)

        let res = fromHex[int](gas)
        result = $(%* { "result": res, "success": success })
      else:
        var tx = ens_utils.buildTransaction(
          parseAddress(from_addr),
          eth2Wei(parseFloat(value), 18),
          data = data
        )
        tx.to = parseAddress(to).some
        response = eth.estimateGas(%*[%tx])

        let res = fromHex[int](response.result.getStr)
        result = $(%* { "result": %res, "success": true })
    except Exception as e:
      error "Error estimating gas", msg = e.msg
      result = $(%* { "result": "-1", "success": false, "error": { "message": e.msg } })
    
  proc transferEth*(
      self: Service,
      from_addr: string,
      to_addr: string,
      value: string,
      gas: string,
      gasPrice: string,
      maxPriorityFeePerGas: string,
      maxFeePerGas: string,
      password: string,
      uuid: string
    ): bool {.slot.} =
    try:
      let eip1559Enabled = self.settingsService.isEIP1559Enabled()
      eth_utils.validateTransactionInput(from_addr, to_addr, assetAddress = "", value, gas,
        gasPrice, data = "", eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, uuid)

      # TODO move this to another thread
      var tx = ens_utils.buildTransaction(parseAddress(from_addr), eth2Wei(parseFloat(value), 18),
          gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)
      tx.to = parseAddress(to_addr).some

      let json: JsonNode = %tx
      let response = eth.sendTransaction($json, password)
      if response.error != nil:
        raise newException(Exception, response.error.message)

      self.trackPendingTransaction(response.result.getStr, from_addr, to_addr,
        $PendingTransactionTypeDto.WalletTransfer, data = "")
    except Exception as e:
      error "Error sending eth transfer transaction", msg = e.msg
      return false
    return true

  proc transferTokens*(
      self: Service,
      from_addr: string,
      to_addr: string,
      assetAddress: string,
      value: string,
      gas: string,
      gasPrice: string,
      maxPriorityFeePerGas: string,
      maxFeePerGas: string,
      password: string,
      uuid: string
      ): bool =
    try:
      let eip1559Enabled = self.settingsService.isEIP1559Enabled()
      eth_utils.validateTransactionInput(from_addr, to_addr, assetAddress, value, gas,
        gasPrice, data = "", eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, uuid)

      # TODO move this to another thread
      let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
      let network = self.networkService.getNetwork(networkType)
      let contract = self.eth_service.findErc20Contract(network.chainId, parseAddress(assetAddress))

      var tx = ens_utils.buildTokenTransaction(parseAddress(from_addr), parseAddress(assetAddress),
        gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)

      var success: bool
      let transfer = Transfer(to: parseAddress(to_addr),
        value: conversion.eth2Wei(parseFloat(value), contract.decimals))
      let transferMethod = contract.getMethod("transfer")
      let response = transferMethod.send(tx, transfer, password, success)

      self.trackPendingTransaction(response, from_addr, to_addr,
        $PendingTransactionTypeDto.WalletTransfer, data = "")
    except Exception as e:
      error "Error sending token transfer transaction", msg = e.msg
      return false
    return true