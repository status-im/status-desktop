import Tables, NimQml, chronicles, sequtils, sugar, stint, strutils, json, strformat, algorithm, math
import ../../../backend/transactions as transactions
import ../../../backend/backend
import ../../../backend/eth

import ../ens/utils as ens_utils
from ../../common/account_constants import ZERO_ADDRESS
import ../../common/conversion as common_conversion

import ../../../app/core/[main]
import ../../../app/core/signals/types
import ../../../app/core/tasks/[qt, threadpool]
import ../wallet_account/service as wallet_account_service
import ../network/service as network_service
import ../token/service as token_service
import ../settings/service as settings_service
import ../eth/dto/transaction as transaction_data_dto
import ../eth/dto/[method_dto, coder, method_dto]
import ./dto as transaction_dto
import ./cryptoRampDto
import ../eth/utils as eth_utils
import ../../common/conversion

export transaction_dto

logScope:
  topics = "transaction-service"

include async_tasks
include ../../common/json_utils

# Signals which may be emitted by this service:
const SIGNAL_TRANSACTIONS_LOADED* = "transactionsLoaded"
const SIGNAL_TRANSACTION_SENT* = "transactionSent"

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

type
  TransactionSentArgs* = ref object of Args
    result*: string

type SuggestedFees = object
  gasPrice: float
  baseFee: float
  maxPriorityFeePerGas: float
  maxFeePerGasL: float 
  maxFeePerGasM: float
  maxFeePerGasH: float

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
    settingsService: settings_service.Service
    tokenService: token_service.Service

  # Forward declaration
  proc checkPendingTransactions*(self: Service)
  proc checkPendingTransactions*(self: Service, address: string)

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      walletAccountService: wallet_account_service.Service,
      networkService: network_service.Service,
      settingsService: settings_service.Service,
      tokenService: token_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.walletAccountService = walletAccountService
    result.networkService = networkService
    result.settingsService = settingsService
    result.tokenService = tokenService

  proc doConnect*(self: Service) =
    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      if(data.eventType == "newblock"):
        for acc in data.accounts:
          self.checkPendingTransactions(acc)

  proc init*(self: Service) =
    self.doConnect()

  proc checkRecentHistory*(self: Service) =
    try:
      let addresses = self.walletAccountService.getWalletAccounts().map(a => a.address)
      transactions.checkRecentHistory(addresses)
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription
      return
  
  proc getTransactionReceipt*(self: Service, transactionHash: string): JsonNode =
    try:
      let response = transactions.getTransactionReceipt(transactionHash)
      result =  response.result
    except Exception as e:
      let errDescription = e.msg
      error "error getting transaction receipt: ", errDescription
  
  proc deletePendingTransaction*(self: Service, transactionHash: string) =
    try:
      discard transactions.deletePendingTransaction(transactionHash)
    except Exception as e:
      let errDescription = e.msg
      error "error deleting pending transaction: ", errDescription
  
  proc confirmTransactionStatus(self: Service, pendingTransactions: JsonNode) =
    for trx in pendingTransactions.getElems():
      let transactionReceipt = self.getTransactionReceipt(trx["hash"].getStr)
      if transactionReceipt.kind != JNull:
        self.deletePendingTransaction(trx["hash"].getStr)
        let ev = TransactionMinedArgs(
                  data: trx["additionalData"].getStr,
                  transactionHash: trx["hash"].getStr,
                  success: transactionReceipt{"status"}.getStr == "0x1",
                  revertReason: ""
                )
        self.events.emit(parseEnum[PendingTransactionTypeDto](trx["type"].getStr).event, ev)

  proc getPendingTransactions*(self: Service): JsonNode =
    try:
      # this may be improved (need to add some checkings) but due to removing `status-lib` dependencies, channges made
      # in this go are as minimal as possible
      let response = backend.getPendingTransactions()
      return response.result
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription
      return

  proc getPendingOutboundTransactionsByAddress*(self: Service, address: string): JsonNode =
    try:
      result = transactions.getPendingOutboundTransactionsByAddress(address).result
    except Exception as e:
      let errDescription = e.msg
      error "error getting pending txs by address: ", errDescription, address

  proc checkPendingTransactions*(self: Service) =
    # TODO move this to a thread
    let pendingTransactions = self.getPendingTransactions()
    if (pendingTransactions.kind == JArray and pendingTransactions.len > 0):
      self.confirmTransactionStatus(pendingTransactions)

  proc checkPendingTransactions*(self: Service, address: string) =
    self.confirmTransactionStatus(self.getPendingOutboundTransactionsByAddress(address))

  proc trackPendingTransaction*(self: Service, hash: string, fromAddress: string, toAddress: string, trxType: string, 
    data: string) =
    try:
      discard transactions.trackPendingTransaction(hash, fromAddress, toAddress, trxType, data)
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription

  proc getTransfersByAddress*(self: Service, address: string, toBlock: Uint256, limit: int, loadMore: bool = false): seq[TransactionDto] =
    try:
      let limitAsHex = "0x" & eth_utils.stripLeadingZeros(limit.toHex)
      let response = transactions.getTransfersByAddress(address, toBlock, limitAsHex, loadMore)

      result = map(
        response.result.getElems(),
        proc(x: JsonNode): TransactionDto = x.toTransactionDto()
      )
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription
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
    if assetAddress != ZERO_ADDRESS and not assetAddress.isEmptyOrWhitespace:
      var tx = buildTokenTransaction(
        parseAddress(from_addr),
        parseAddress(assetAddress)
      )
      let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
      let network = self.networkService.getNetwork(networkType)
      let token = self.tokenService.findTokenByAddress(network, parseAddress(assetAddress))

      if token == nil:
        raise newException(ValueError, fmt"Could not find ERC-20 contract with address '{assetAddress}' for the current network")

      let transfer = Transfer(to: parseAddress(to), value: conversion.eth2Wei(parseFloat(value), token.decimals))
      let transferproc = ERC20_procS.toTable["transfer"]
      var success: bool
      try:
        let gas = transferproc.estimateGas(tx, transfer, success)

        let res = fromHex[int](gas)
        return $(%* { "result": res, "success": success })
      except Exception as e:
        error "Error estimating gas", msg = e.msg
        return $(%* { "result": "-1", "success": false, "error": { "message": e.msg } })

    var tx = ens_utils.buildTransaction(
      parseAddress(from_addr),
      eth2Wei(parseFloat(value), 18),
      data = data
    )
    tx.to = parseAddress(to).some
    try:
      response = eth.estimateGas(%*[%tx])
      let res = fromHex[int](response.result.getStr)
    except Exception as e:
      error "Error estimating gas", msg = e.msg
      return $(%* { "result": "-1", "success": false })
    

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
      let eip1559Enabled = self.networkService.isEIP1559Enabled()
      eth_utils.validateTransactionInput(from_addr, to_addr, assetAddress = "", value, gas,
        gasPrice, data = "", eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, uuid)

      # TODO move this to another thread
      var tx = ens_utils.buildTransaction(parseAddress(from_addr), eth2Wei(parseFloat(value), 18),
          gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)
      tx.to = parseAddress(to_addr).some

      let json: JsonNode = %tx
      let response = eth.sendTransaction($json, password)

      # only till it is moved to another thred
      # if response.error != nil:
      #   raise newException(Exception, response.error.message)

      let output = %* { "result": %($response),  "success": %(response.error.isNil), "uuid": %uuid }
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(result: $output))

      self.trackPendingTransaction($response, from_addr, to_addr,
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
      let eip1559Enabled = self.networkService.isEIP1559Enabled()
      eth_utils.validateTransactionInput(from_addr, to_addr, assetAddress, value, gas,
        gasPrice, data = "", eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, uuid)

      # TODO move this to another thread
      let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
      let network = self.networkService.getNetwork(networkType)
      let token = self.tokenService.findTokenByAddress(network, parseAddress(assetAddress))

      var tx = ens_utils.buildTokenTransaction(parseAddress(from_addr), parseAddress(assetAddress),
        gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)

      var success: bool
      let transfer = Transfer(to: parseAddress(to_addr),
        value: conversion.eth2Wei(parseFloat(value), token.decimals))
      let transferproc = ERC20_procS.toTable["transfer"]
      let response = transferproc.send(tx, transfer, password, success)

      let output = %* { "result": %response,  "success": %success, "uuid": %uuid }
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(result: $output))

      self.trackPendingTransaction(response, from_addr, to_addr,
        $PendingTransactionTypeDto.WalletTransfer, data = "")
    except Exception as e:
      error "Error sending token transfer transaction", msg = e.msg
      return false
    return true

  proc suggestedFees*(self: Service): SuggestedFees =
    let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
    let network = self.networkService.getNetwork(networkType)
    let response = eth.suggestedFees(network.chainId).result

    return SuggestedFees(
      gasPrice: parseFloat(response{"gasPrice"}.getStr),
      baseFee: parseFloat(response{"baseFee"}.getStr),
      maxPriorityFeePerGas: parseFloat(response{"maxPriorityFeePerGas"}.getStr),
      maxFeePerGasL: parseFloat(response{"maxFeePerGasLow"}.getStr),
      maxFeePerGasM: parseFloat(response{"maxFeePerGasMedium"}.getStr),
      maxFeePerGasH: parseFloat(response{"maxFeePerGasHigh"}.getStr)
    ) 

  proc fetchCryptoServices*(self: Service): seq[CryptoRampDto] =
    try:
      let response = transactions.fetchCryptoServices()

      if not response.error.isNil:
        raise newException(ValueError, "Error fetching crypto services" & response.error.message)

      return response.result.getElems().map(x => x.toCryptoRampDto())
    except Exception as e:
      error "Error fetching crypto services", message = e.msg
      return @[]
