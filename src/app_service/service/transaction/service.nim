import NimQml, chronicles, sequtils, sugar, stint, strutils, json, strformat, algorithm, math
import ../../../backend/transactions as transactions
import ../../../backend/wallet as status_wallet
import ../../../backend/eth

import ../ens/utils as ens_utils
from ../../common/account_constants import ZERO_ADDRESS
import ../../common/conversion as common_conversion

import ../../../app/core/[main]
import ../../../app/core/signals/types
import ../../../app/core/tasks/[qt, threadpool]
import ../wallet_account/service as wallet_account_service
import ../eth/service as eth_service
import ../network/service as network_service
import ../settings/service as settings_service
import ../eth/dto/transaction as transaction_data_dto
import ../eth/dto/[contract, method_dto]
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
  gasPrice: string
  baseFee: float
  maxPriorityFeePerGas: float
  maxFeePerGasL: float 
  maxFeePerGasM: float
  maxFeePerGasH: float

proc cmpUint256(x, y: Uint256): int =
  if x > y: 1
  elif x == y: 0
  else: -1

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    walletAccountService: wallet_account_service.ServiceInterface
    ethService: eth_service.ServiceInterface
    networkService: network_service.ServiceInterface
    settingsService: settings_service.ServiceInterface

    baseFeePerGas: string

  # Forward declaration
  proc checkPendingTransactions*(self: Service)
  proc checkPendingTransactions*(self: Service, address: string)

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

  proc baseFeePerGas*(self: Service): string = 
    return self.baseFeePerGas

  proc setLatestBaseFeePerGas*(self: Service) = 
    let response = eth.getBlockByNumber("latest")
    self.baseFeePerGas = $fromHex(Stuint[256], response.result{"baseFeePerGas"}.getStr)

  proc doConnect*(self: Service) =
    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      if(data.eventType == "newblock"):
        self.setLatestBaseFeePerGas()

        for acc in data.accounts:
          self.checkPendingTransactions(acc)

  proc init*(self: Service) =
    self.doConnect()
    self.setLatestBaseFeePerGas()

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
      let response = status_wallet.getPendingTransactions()
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
      let contract = self.eth_service.findErc20Contract(network.chainId, parseAddress(assetAddress))

      var tx = ens_utils.buildTokenTransaction(parseAddress(from_addr), parseAddress(assetAddress),
        gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)

      var success: bool
      let transfer = Transfer(to: parseAddress(to_addr),
        value: conversion.eth2Wei(parseFloat(value), contract.decimals))
      let transferMethod = contract.getMethod("transfer")
      let response = transferMethod.send(tx, transfer, password, success)

      let output = %* { "result": %response,  "success": %success, "uuid": %uuid }
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(result: $output))

      self.trackPendingTransaction(response, from_addr, to_addr,
        $PendingTransactionTypeDto.WalletTransfer, data = "")
    except Exception as e:
      error "Error sending token transfer transaction", msg = e.msg
      return false
    return true

  proc maxPriorityFeePerGas(self: Service): Uint256 =
    let response = eth.maxPriorityFeePerGas()
    return fromHex(Stuint[256], response.result.getStr)

  proc getGasPrice(self: Service): Uint256 =
    let response = eth.getGasPrice()
    return fromHex(Stuint[256], response.result.getStr)

  proc feeHistory(self: Service, n:int): seq[Uint256] =
    let response = eth.feeHistory(101)
    for it in response.result["baseFeePerGas"]:
      result.add(fromHex(Stuint[256], it.getStr))

    result.sort(cmpUint256)    

  proc suggestedFees*(self: Service): SuggestedFees =
    #[
      0. priority tip always same, the value returned by eth_maxPriorityFeePerGas
      1. slow fee 10th percentile base fee (last 100 blocks) + eth_maxPriorityFeePerGas 
      2. normal fee. 
        if 20th_percentile <= current_base_fee <= 80th_percentile then fee = current_base_fee + eth_maxPriorityFeePerGas. 
        if current_base_fee < 20th_percentile then fee = 20th_percentile + eth_maxPriorityFeePerGas
        if current_base_fee > 80th_percentile then fee = 80th_percentile + eth_maxPriorityFeePerGas
        The idea is to avoid setting too low base fee when price is in a dip and also to avoid overpaying on peak.
        Specific percentiles can be revisit later, it doesn't need to be symmetric because we are mostly interested in not getting stuck and overpaying might not be a huge issue here.
      3. fast fee: current_base_fee + eth_maxPriorityFeePerGas
    ]#

    let maxPriorityFeePerGas = self.maxPriorityFeePerGas()
    let feeHistory = self.feeHistory(101)
    let baseFee = self.baseFeePerGas.u256
    let gasPrice = self.getGasPrice()

    let perc10 = feeHistory[ceil(10/100 * feeHistory.len.float).int - 1]
    let perc20 = feeHistory[ceil(20/100 * feeHistory.len.float).int - 1]
    let perc80 = feeHistory[ceil(80/100 * feeHistory.len.float).int - 1]

    let maxFeePerGasM = if baseFee >= perc20 and baseFee <= perc80:
      baseFee + maxPriorityFeePerGas
    elif baseFee < perc20:
      perc20 + maxPriorityFeePerGas
    else:
      perc80 + maxPriorityFeePerGas

    return SuggestedFees(
      gasPrice: $gasPrice,
      baseFee: parseFloat(common_conversion.wei2gwei($baseFee)),
      maxPriorityFeePerGas: parseFloat(common_conversion.wei2gwei($maxPriorityFeePerGas)),
      maxFeePerGasL: parseFloat(common_conversion.wei2gwei($(perc10 + maxPriorityFeePerGas))),
      maxFeePerGasM: parseFloat(common_conversion.wei2gwei($(maxFeePerGasM))),
      maxFeePerGasH: parseFloat(common_conversion.wei2gwei($(baseFee + maxPriorityFeePerGas)))
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
