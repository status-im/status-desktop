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
const SIGNAL_SUGGESTED_ROUTES_READY* = "suggestedRoutesReady"
const SIGNAL_PENDING_TX_COMPLETED* = "pendingTransactionCompleted"

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

type
  SuggestedRoutesArgs* = ref object of Args
    suggestedRoutes*: string

type
  PendingTxCompletedArgs* = ref object of Args
    txHash*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    networkService: network_service.Service
    settingsService: settings_service.Service
    tokenService: token_service.Service

  # Forward declaration
  proc checkPendingTransactions*(self: Service): seq[TransactionDto]
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

  proc watchTransactionResult*(self: Service, watchTxResult: string) {.slot.} =
    let watchTxResult = parseJson(watchTxResult)
    let txHash = watchTxResult["txHash"].getStr
    let success = watchTxResult["isSuccessfull"].getBool
    if(success):
      self.events.emit(SIGNAL_PENDING_TX_COMPLETED, PendingTxCompletedArgs(txHash: txHash))

  proc watchTransaction*(self: Service, chainId: int, transactionHash: string) =
      let arg = WatchTransactionTaskArg(
        chainId: chainId,
        txHash: transactionHash,
        tptr: cast[ByteAddress](watchTransactionsTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "watchTransactionResult",
      )
      self.threadpool.start(arg)
  
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
  
  proc confirmTransactionStatus(self: Service, pendingTransactions: seq[TransactionDto]) =
    for trx in pendingTransactions:
      let transactionReceipt = self.getTransactionReceipt(trx.chainId, trx.txHash)
      if transactionReceipt != nil and transactionReceipt.kind != JNull:
        self.deletePendingTransaction(trx.chainId, trx.txHash)
        let ev = TransactionMinedArgs(
                  data: trx.additionalData,
                  transactionHash: trx.txHash,
                  chainId: trx.chainId,
                  success: transactionReceipt{"status"}.getStr == "0x1",
                  revertReason: ""
                )
        self.events.emit(parseEnum[PendingTransactionTypeDto](trx.typeValue).event, ev)

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

  proc checkPendingTransactions*(self: Service): seq[TransactionDto] =
    # TODO move this to a thread
    let pendingTransactions = self.getPendingTransactions()
    if (pendingTransactions.kind == JArray and pendingTransactions.len > 0):
      let pendingTxs = pendingTransactions.getElems().map(x => x.toPendingTransactionDto())
      self.confirmTransactionStatus(pendingTxs)
      for tx in pendingTxs:
        self.watchTransaction(tx.chainId, tx.txHash)
      return pendingTxs

  proc checkPendingTransactions*(self: Service, address: string) =
    let pendingTxs = self.getPendingOutboundTransactionsByAddress(address).getElems().map(x => x.toPendingTransactionDto())
    self.confirmTransactionStatus(pendingTxs)

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

  proc transfer*(
    self: Service,
    from_addr: string,
    to_addr: string,
    tokenSymbol: string,
    value: string,
    uuid: string,
    selectedRoutes: string,
    password: string,
  ) =
    try:
      let selRoutes = parseJson(selectedRoutes)
      let routes = selRoutes.getElems().map(x => x.convertToTransactionPathDto())

      var paths: seq[TransactionBridgeDto] = @[]
      var isEthTx = false
      var chainID = 0
      var amountToSend: UInt256
      var toAddress: Address
      var data = ""

      if(routes.len > 0):
        chainID = routes[0].fromNetwork.chainID
      let network = self.networkService.getNetwork(chainID)
      if network.nativeCurrencySymbol == tokenSymbol:
        isEthTx = true

      if(isEthTx):
        amountToSend = conversion.eth2Wei(parseFloat(value), 18)
        toAddress = parseAddress(to_addr)
      else:
        let token = self.tokenService.findTokenBySymbol(network, tokenSymbol)
        amountToSend = conversion.eth2Wei(parseFloat(value), token.decimals)
        toAddress = token.address
        let transfer = Transfer(
          to: parseAddress(to_addr),
          value: amountToSend,
        )
        data = ERC20_procS.toTable["transfer"].encodeAbi(transfer)

      for route in routes:
        var simpleTx = TransactionDataDto()
        var hopTx = TransactionDataDto()
        var cbridgeTx = TransactionDataDto()
        var txData = TransactionDataDto()
        var gasFees: string = ""

        if( not route.gasFees.eip1559Enabled):
          gasFees = $route.gasFees.gasPrice

        if route.approvalRequired:
          let approve = Approve(
            to: parseAddress(route.approvalContractAddress),
            value: route.approvalAmountRequired,
          )
          data = ERC20_procS.toTable["approve"].encodeAbi(approve)
          txData = ens_utils.buildTokenTransaction(
            parseAddress(from_addr),
            toAddress,
            $route.gasAmount,
            gasFees,
            route.gasFees.eip1559Enabled,
            $route.gasFees.maxPriorityFeePerGas,
            $route.gasFees.maxFeePerGasM
          )
          txData.data = data
          var path = TransactionBridgeDto(bridgeName: "Simple", chainID: route.fromNetwork.chainId)
          path.simpleTx = txData
          paths.add(path)

        if(isEthTx) :
          txData = ens_utils.buildTransaction(parseAddress(from_addr), eth2Wei(parseFloat(value), 18),
  $route.gasAmount, gasFees, route.gasFees.eip1559Enabled, $route.gasFees.maxPriorityFeePerGas, $route.gasFees.maxFeePerGasM)
          txData.to = parseAddress(to_addr).some
        else:
          txData = ens_utils.buildTokenTransaction(parseAddress(from_addr), toAddress,
  $route.gasAmount, gasFees, route.gasFees.eip1559Enabled, $route.gasFees.maxPriorityFeePerGas, $route.gasFees.maxFeePerGasM)
          txData.data = data

        var path = TransactionBridgeDto(bridgeName: route.bridgeName, chainID: route.fromNetwork.chainId)
        if(route.bridgeName == "Simple"):
          path.simpleTx = txData
        elif(route.bridgeName == "Hop"):
          hopTx = txData
          hopTx.chainID =  route.toNetwork.chainId.some
          hopTx.symbol = tokenSymbol.some
          hopTx.recipient = parseAddress(to_addr).some
          hopTx.amount = route.amountIn.some
          hopTx.bonderFee = route.bonderFees.some
          path.hopTx = hopTx
        else:
          cbridgeTx = txData
          cbridgeTx.chainID =  route.toNetwork.chainId.some
          cbridgeTx.symbol = tokenSymbol.some
          cbridgeTx.recipient = parseAddress(to_addr).some
          cbridgeTx.amount = route.amountIn.some
          path.cbridgeTx = cbridgeTx

        paths.add(path)

      let response = transactions.createMultiTransaction(
        MultiTransactionDto(
          fromAddress: from_addr,
          toAddress: to_addr,
          fromAsset: tokenSymbol,
          toAsset: tokenSymbol,
          fromAmount:  "0x" & amountToSend.toHex,
          multiTxtype: MultiTransactionType.MultiTransactionSend,
        ),
        paths,
        password,
      )
      # Watch for this transaction to be completed
      if response.result{"hashes"} != nil:
        for hash in response.result["hashes"][$chainID]:
          let txHash = hash.getStr
          self.watchTransaction(chainID, txHash)
      let output = %* {"result": response.result{"hashes"}, "success":true, "uuid": %uuid }
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(result: $output))
    except Exception as e:
      error "Error sending token transfer transaction", msg = e.msg
      let err =  fmt"Error sending token transfer transaction: {e.msg}"
      let output = %* {"success":false, "uuid": %uuid, "error":fmt"Error sending token transfer transaction: {e.msg}"}
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(result: $output))

  proc suggestedFees*(self: Service, chainId: int): SuggestedFeesDto =
    try:
      let response = eth.suggestedFees(chainId).result
      return response.toSuggestedFeesDto()
    except Exception as e:
      error "Error getting suggested fees", msg = e.msg

  proc suggestedRoutesReady*(self: Service, suggestedRoutes: string) {.slot.} =
    self.events.emit(SIGNAL_SUGGESTED_ROUTES_READY, SuggestedRoutesArgs(suggestedRoutes: suggestedRoutes))

  proc suggestedRoutes*(self: Service, account: string, amount: Uint256, token: string, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs: seq[uint64], sendType: int, lockedInAmounts: string): SuggestedRoutesDto =
    let arg = GetSuggestedRoutesTaskArg(
      tptr: cast[ByteAddress](getSuggestedRoutesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "suggestedRoutesReady",
      account: account,
      amount: amount,
      token: token,
      disabledFromChainIDs: disabledFromChainIDs,
      disabledToChainIDs: disabledToChainIDs,
      preferredChainIDs: preferredChainIDs,
      sendType: sendType,
      lockedInAmounts: lockedInAmounts
    )
    self.threadpool.start(arg)

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

  proc getLastTxBlockNumber*(self: Service, chainId: int): string =
    try:
      let response = eth.getBlockByNumber(chainId, "latest")
      return response.result{"number"}.getStr
    except Exception as e:
      error "Error getting latest block number", message = e.msg
      return ""
