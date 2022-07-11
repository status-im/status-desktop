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
  EstimatedTime* {.pure.} = enum
    Unknown = 0
    LessThanOneMin
    LessThanThreeMins
    LessThanFiveMins
    MoreThanFiveMins

type
  TransactionMinedArgs* = ref object of Args
    data*: string
    transactionHash*: string
    chainId*: int
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
  eip1559Enabled: bool

# Initial version of suggested routes is a list of network where the tx is possible
type SuggestedRoutes = object
  networks: seq[NetworkDto]

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
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
      networkService: network_service.Service,
      settingsService: settings_service.Service,
      tokenService: token_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
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
  
  proc getTransactionReceipt*(self: Service, chainId: int, transactionHash: string): JsonNode =
    try:
      let response = transactions.getTransactionReceipt(chainId, transactionHash)
      result = response.result
    except Exception as e:
      let errDescription = e.msg
      error "error getting transaction receipt: ", errDescription
  
  proc deletePendingTransaction*(self: Service, chainId: int, transactionHash: string) =
    try:
      discard transactions.deletePendingTransaction(chainId, transactionHash)
    except Exception as e:
      let errDescription = e.msg
      error "error deleting pending transaction: ", errDescription
  
  proc confirmTransactionStatus(self: Service, pendingTransactions: JsonNode) =
    for trx in pendingTransactions.getElems():
      let transactionReceipt = self.getTransactionReceipt(trx["network_id"].getInt, trx["hash"].getStr)
      if transactionReceipt.kind != JNull:
        self.deletePendingTransaction(trx["network_id"].getInt, trx["hash"].getStr)
        let ev = TransactionMinedArgs(
                  data: trx["additionalData"].getStr,
                  transactionHash: trx["hash"].getStr,
                  chainId: trx["network_id"].getInt,
                  success: transactionReceipt{"status"}.getStr == "0x1",
                  revertReason: ""
                )
        self.events.emit(parseEnum[PendingTransactionTypeDto](trx["type"].getStr).event, ev)

  proc getPendingTransactions*(self: Service): JsonNode =
    try:
      let chainIds = self.networkService.getNetworks().map(a => a.chainId)
      let response = backend.getPendingTransactionsByChainIDs(chainIds)
      return response.result
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription
      return

  proc getPendingOutboundTransactionsByAddress*(self: Service, address: string): JsonNode =
    try:
      let chainIds = self.networkService.getNetworks().map(a => a.chainId)
      result = transactions.getPendingOutboundTransactionsByAddress(chainIds, address).result
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
    data: string, chainId: int) =
    try:
      discard transactions.trackPendingTransaction(hash, fromAddress, toAddress, trxType, data, chainId)
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription

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
    for networks in self.networkService.getNetworks():
      let arg = LoadTransactionsTaskArg(
        address: address,
        tptr: cast[ByteAddress](loadTransactionsTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "setTrxHistoryResult",
        toBlock: toBlock,
        limit: limit,
        loadMore: loadMore,
        chainId: networks.chainId,
      )
      self.threadpool.start(arg)

  proc estimateGas*(
    self: Service,
    from_addr: string,
    to: string,
    assetSymbol: string,
    value: string,
    chainId: string,
    data: string = "",
  ): string {.slot.} =
    var response: RpcResponse[JsonNode]
    var success: bool
    # TODO make this async
    let network = self.networkService.getNetwork(parseInt(chainId))

    if network.nativeCurrencySymbol == assetSymbol:
      var tx = ens_utils.buildTransaction(
        parseAddress(from_addr),
        eth2Wei(parseFloat(value), 18),
        data = data
      )
      tx.to = parseAddress(to).some
      try:
        response = eth.estimateGas(parseInt(chainId), %*[%tx])
        let res = fromHex[int](response.result.getStr)
        return $(%* { "result": res, "success": true })
      except Exception as e:
        error "Error estimating gas", msg = e.msg
        return $(%* { "result": "-1", "success": false, "error": { "message": e.msg } })

    let token = self.tokenService.findTokenBySymbol(network, assetSymbol)
    if token == nil:
      raise newException(ValueError, fmt"Could not find ERC-20 contract with symbol '{assetSymbol}' for the current network")

    var tx = buildTokenTransaction(
      parseAddress(from_addr),
      token.address,
    )
          
    let transfer = Transfer(to: parseAddress(to), value: conversion.eth2Wei(parseFloat(value), token.decimals))
    let transferproc = ERC20_procS.toTable["transfer"]
    try:
      let gas = transferproc.estimateGas(parseInt(chainId), tx, transfer, success)
      let res = fromHex[int](gas)
      return $(%* { "result": res, "success": success })
    except Exception as e:
      error "Error estimating gas", msg = e.msg
      return $(%* { "result": "-1", "success": false, "error": { "message": e.msg } })    

  proc transferEth(
      self: Service,
      from_addr: string,
      to_addr: string,
      value: string,
      gas: string,
      gasPrice: string,
      maxPriorityFeePerGas: string,
      maxFeePerGas: string,
      password: string,
      chainId: string,
      uuid: string,
      eip1559Enabled: bool,
  ): bool {.slot.} =
    try:
      eth_utils.validateTransactionInput(from_addr, to_addr, assetAddress = "", value, gas,
        gasPrice, data = "", eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, uuid)

      var tx = ens_utils.buildTransaction(parseAddress(from_addr), eth2Wei(parseFloat(value), 18),
          gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)
      tx.to = parseAddress(to_addr).some
      
      let response = transactions.createMultiTransaction(
        MultiTransactionDto(
          fromAddress: from_addr,
          toAddress: to_addr,
          fromAsset: "ETH",
          toAsset: "ETH",
          fromAmount:  "0x" & tx.value.unsafeGet.toHex,
          multiTxtype: MultiTransactionType.MultiTransactionSend,
        ), 
        {chainId: @[tx]}.toTable,
        password,
      )
      let output = %* { "result": response.result{"hashes"}{chainId}[0].getStr,  "success": %(response.error.isNil), "uuid": %uuid }
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(result: $output))
    except Exception as e:
      error "Error sending eth transfer transaction", msg = e.msg
      return false
    return true

  proc transferTokens*(
    self: Service,
    from_addr: string,
    to_addr: string,
    tokenSymbol: string,
    value: string,
    gas: string,
    gasPrice: string,
    maxPriorityFeePerGas: string,
    maxFeePerGas: string,
    password: string,
    chainId: string,
    uuid: string,
    eip1559Enabled: bool,
  ): bool =
    # TODO move this to another thread
    try:
      let network = self.networkService.getNetwork(parseInt(chainId))
      let token = self.tokenService.findTokenBySymbol(network, tokenSymbol)

      eth_utils.validateTransactionInput(from_addr, to_addr, token.addressAsString(), value, gas,
        gasPrice, data = "", eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, uuid)
      
      var tx = ens_utils.buildTokenTransaction(parseAddress(from_addr), token.address,
        gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)

      let weiValue = conversion.eth2Wei(parseFloat(value), token.decimals)
      let transfer = Transfer(
        to: parseAddress(to_addr),
        value: weiValue,
      )

      tx.data = ERC20_procS.toTable["transfer"].encodeAbi(transfer)
      let response = transactions.createMultiTransaction(
        MultiTransactionDto(
          fromAddress: from_addr,
          toAddress: to_addr,
          fromAsset: tokenSymbol,
          toAsset: tokenSymbol,
          fromAmount:  "0x" & weiValue.toHex,
          multiTxtype: MultiTransactionType.MultiTransactionSend,
        ), 
        {chainId: @[tx]}.toTable,
        password,
      )
      let txHash = response.result.getStr
      let output = %* { "result": response.result{"hashes"}{chainId}[0].getStr, "success":true, "uuid": %uuid }
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(result: $output))
    except Exception as e:
      error "Error sending token transfer transaction", msg = e.msg
      return false
    return true

  proc transfer*(
    self: Service,
    from_addr: string,
    to_addr: string,
    assetSymbol: string,
    value: string,
    gas: string,
    gasPrice: string,
    maxPriorityFeePerGas: string,
    maxFeePerGas: string,
    password: string,
    chainId: string,
    uuid: string,
    eip1559Enabled: bool,
  ): bool =
    let network = self.networkService.getNetwork(parseInt(chainId))

    if network.nativeCurrencySymbol == assetSymbol:
      return self.transferEth(from_addr, to_addr, value, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, chainId, uuid, eip1559Enabled)

    return self.transferTokens(from_addr, to_addr, assetSymbol, value, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, chainId, uuid, eip1559Enabled)

  proc suggestedFees*(self: Service, chainId: int): SuggestedFees =
    let response = eth.suggestedFees(chainId).result
    return SuggestedFees(
      gasPrice: parseFloat(response{"gasPrice"}.getStr),
      baseFee: parseFloat(response{"baseFee"}.getStr),
      maxPriorityFeePerGas: parseFloat(response{"maxPriorityFeePerGas"}.getStr),
      maxFeePerGasL: parseFloat(response{"maxFeePerGasLow"}.getStr),
      maxFeePerGasM: parseFloat(response{"maxFeePerGasMedium"}.getStr),
      maxFeePerGasH: parseFloat(response{"maxFeePerGasHigh"}.getStr),
      eip1559Enabled: response{"eip1559Enabled"}.getbool,
    )

  proc suggestedRoutes*(self: Service, account: string, amount: float64, token: string, disabledChainIDs: seq[uint64]): SuggestedRoutes =
    let response = eth.suggestedRoutes(account, amount, token, disabledChainIDs)
    return SuggestedRoutes(
      networks: Json.decode($response.result{"networks"}, seq[NetworkDto])
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

  proc addToAllTransactionsAndSetNewMinMax(self: Service, myTip: float, numOfTransactionWithTipLessThanMine: var int, 
    transactions: JsonNode) =
    if transactions.kind != JArray:
      return
    for t in transactions:
      let gasPriceUnparsed = $fromHex(Stuint[256], t{"gasPrice"}.getStr)
      let gasPrice = parseFloat(wei2gwei(gasPriceUnparsed))
      if gasPrice < myTip:
        numOfTransactionWithTipLessThanMine.inc

  proc getEstimatedTime*(self: Service, chainId: int, maxFeePerGas: string): EstimatedTime =
    try:
      let response = backend.getTransactionEstimatedTime(chainId, maxFeePerGas.parseFloat).result.getInt
      return EstimatedTime(response)
    except Exception as e:
      error "Error estimating transaction time", message = e.msg
      return EstimatedTime.Unknown
