import Tables, NimQml, chronicles, sequtils, sugar, stint, strutils, json, strformat, algorithm

import ../../../backend/collectibles as collectibles
import ../../../backend/transactions as transactions
import ../../../backend/backend
import ../../../backend/eth

import ../ens/utils as ens_utils
import ../../common/conversion as common_conversion

import ../../../app/core/[main]
import ../../../app/core/signals/types
import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/global/global_singleton
import ../wallet_account/service as wallet_account_service
import ../network/service as network_service
import ../token/service as token_service
import ../settings/service as settings_service
import ../eth/dto/transaction as transaction_data_dto
import ../eth/dto/[coder, method_dto]
import ./dto as transaction_dto
import ./cryptoRampDto
import ../eth/utils as eth_utils
import ../../common/conversion
import ../../../constants as main_constants


export transaction_dto

logScope:
  topics = "transaction-service"

include async_tasks
include ../../common/json_utils

# Maximum number of collectibles to be fetched at a time
const collectiblesLimit = 200 

# Signals which may be emitted by this service:
const SIGNAL_TRANSACTION_SENT* = "transactionSent"
const SIGNAL_SUGGESTED_ROUTES_READY* = "suggestedRoutesReady"
const SIGNAL_HISTORY_NON_ARCHIVAL_NODE* = "historyNonArchivalNode"
const SIGNAL_HISTORY_ERROR* = "historyError"
const SIGNAL_CRYPTO_SERVICES_READY* = "cryptoServicesReady"
const SIGNAL_TRANSACTION_DECODED* = "transactionDecoded"

const SIMPLE_TX_BRIDGE_NAME = "Simple"
const HOP_TX_BRIDGE_NAME = "Hop"

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

proc `$`*(self: TransactionMinedArgs): string =
  result = fmt"""TransactionMinedArgs(
    transactionHash: {$self.transactionHash},
    chainId: {$self.chainId},
    success: {$self.success},
    data: {self.data},
    ]"""

type
  TransactionSentArgs* = ref object of Args
    chainId*: int
    txHash*: string
    uuid*: string
    error*: string

type
  SuggestedRoutesArgs* = ref object of Args
    suggestedRoutes*: SuggestedRoutesDto

type
  CryptoServicesArgs* = ref object of Args
    data*: seq[CryptoRampDto]
type
  TransactionDecodedArgs* = ref object of Args
    dataDecoded*: string
    txHash*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    networkService: network_service.Service
    settingsService: settings_service.Service
    tokenService: token_service.Service

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

  proc init*(self: Service) =
    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      case data.eventType:
        of transactions.EventNonArchivalNodeDetected:
          self.events.emit(SIGNAL_HISTORY_NON_ARCHIVAL_NODE, Args())
        of transactions.EventFetchingHistoryError:
          self.events.emit(SIGNAL_HISTORY_ERROR, Args())

  proc getPendingTransactions*(self: Service): seq[TransactionDto] =
    try:
      let response = backend.getPendingTransactions().result
      if (response.kind == JArray and response.len > 0):
        return response.getElems().map(x => x.toPendingTransactionDto())

      return @[]
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription
      return

  proc getPendingTransactionsForType*(self: Service, transactionType: PendingTransactionTypeDto): seq[TransactionDto] =
    let allPendingTransactions = self.getPendingTransactions()
    return allPendingTransactions.filter(x => x.typeValue == $transactionType)

  proc watchTransactionResult*(self: Service, watchTxResult: string) {.slot.} =
    let watchTxResult = parseJson(watchTxResult)
    let success = watchTxResult["isSuccessfull"].getBool
    if(success):
      let hash = watchTxResult["hash"].getStr
      let chainId = watchTxResult["chainId"].getInt
      let address = watchTxResult["address"].getStr
      let transactionReceipt = transactions.getTransactionReceipt(chainId, hash).result
      if transactionReceipt != nil and transactionReceipt.kind != JNull:
        let ev = TransactionMinedArgs(
          data: watchTxResult["data"].getStr,
          transactionHash: hash,
          chainId: chainId,
          success: transactionReceipt{"status"}.getStr == "0x1",
        )
        self.events.emit(parseEnum[PendingTransactionTypeDto](watchTxResult["trxType"].getStr).event, ev)
        transactions.checkRecentHistory(@[chainId], @[address])

  proc watchTransaction*(
    self: Service, hash: string, fromAddress: string, toAddress: string, trxType: string, data: string, chainId: int, track: bool = true
  ) =
    let arg = WatchTransactionTaskArg(
      chainId: chainId,
      hash: hash,
      address: fromAddress,
      trxType: trxType,
      data: data,
      tptr: cast[ByteAddress](watchTransactionTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "watchTransactionResult",
    )
    self.threadpool.start(arg)

  proc onFetchDecodedTxData*(self: Service, response: string) {.slot.} =
    var args = TransactionDecodedArgs()
    try:
      let data = parseJson(response)
      if data.hasKey("result"):
        args.dataDecoded = $data["result"]
      if data.hasKey("txHash"):
        args.txHash = data["txHash"].getStr
    except Exception as e:
      error "Error parsing decoded tx input data", msg = e.msg
    self.events.emit(SIGNAL_TRANSACTION_DECODED, args)

  proc fetchDecodedTxData*(self: Service, txHash: string, data: string) =
    let arg = FetchDecodedTxDataTaskArg(
      tptr: cast[ByteAddress](fetchDecodedTxDataTask),
      vptr: cast[ByteAddress](self.vptr),
      data: data,
      txHash: txHash,
      slot: "onFetchDecodedTxData",
    )
    self.threadpool.start(arg)

  proc createApprovalPath*(self: Service, route: TransactionPathDto, from_addr: string, toAddress: Address, gasFees: string): TransactionBridgeDto =
    var txData = TransactionDataDto()
    let approve = Approve(
      to: parseAddress(route.approvalContractAddress),
      value: route.approvalAmountRequired,
    )
    let data = ERC20_procS.toTable["approve"].encodeAbi(approve)
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

    var path = TransactionBridgeDto(bridgeName: SIMPLE_TX_BRIDGE_NAME, chainID: route.fromNetwork.chainId)
    path.simpleTx = txData
    return path

  proc createPath*(self: Service, route: TransactionPathDto, txData: TransactionDataDto, tokenSymbol: string, to_addr: string): TransactionBridgeDto =
    var path = TransactionBridgeDto(bridgeName: route.bridgeName, chainID: route.fromNetwork.chainId)
    var hopTx = TransactionDataDto()
    var cbridgeTx = TransactionDataDto()

    if(route.bridgeName == SIMPLE_TX_BRIDGE_NAME):
      path.simpleTx = txData
    elif(route.bridgeName == HOP_TX_BRIDGE_NAME):
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

    return path

  proc transferEth*(
    self: Service,
    from_addr: string,
    to_addr: string,
    tokenSymbol: string,
    value: string,
    uuid: string,
    routes: seq[TransactionPathDto],
    password: string
  ) =
    try:
      var paths: seq[TransactionBridgeDto] = @[]
      let amountToSend = conversion.eth2Wei(parseFloat(value), 18)
      let toAddress = parseAddress(to_addr)

      for route in routes:
        var txData = TransactionDataDto()
        var gasFees: string = ""

        if( not route.gasFees.eip1559Enabled):
          gasFees = $route.gasFees.gasPrice

        if route.approvalRequired:
          paths.add(self.createApprovalPath(route, from_addr, toAddress, gasFees))

        txData = ens_utils.buildTransaction(parseAddress(from_addr), route.amountIn,
          $route.gasAmount, gasFees, route.gasFees.eip1559Enabled, $route.gasFees.maxPriorityFeePerGas, $route.gasFees.maxFeePerGasM)
        txData.to = parseAddress(to_addr).some

        paths.add(self.createPath(route, txData, tokenSymbol, to_addr))

      let response = transactions.createMultiTransaction(
        MultiTransactionCommandDto(
          fromAddress: from_addr,
          toAddress: to_addr,
          fromAsset: tokenSymbol,
          toAsset: tokenSymbol,
          fromAmount:  "0x" & amountToSend.toHex,
          multiTxType: transactions.MultiTransactionType.MultiTransactionSend,
        ),
        paths,
        password,
      )

      if response.result{"hashes"} != nil:
        for route in routes:
          for hash in response.result["hashes"][$route.fromNetwork.chainID]:
            self.watchTransaction(hash.getStr, from_addr, to_addr, $PendingTransactionTypeDto.WalletTransfer, " ", route.fromNetwork.chainID, track = false)
            self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(chainId: route.fromNetwork.chainID, txHash: hash.getStr, uuid: uuid , error: ""))
    except Exception as e:
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(chainId: 0, txHash: "", uuid: uuid, error: fmt"Error sending token transfer transaction: {e.msg}"))

  proc transferToken*(
    self: Service,
    from_addr: string,
    to_addr: string,
    tokenSymbol: string,
    value: string,
    uuid: string,
    routes: seq[TransactionPathDto],
    password: string,
  ) =
    try:
      var paths: seq[TransactionBridgeDto] = @[]
      var chainID = 0

      if(routes.len > 0):
        chainID = routes[0].fromNetwork.chainID

      let network = self.networkService.getNetwork(chainID)

      let token = self.tokenService.findTokenBySymbol(network.chainId, tokenSymbol)
      let amountToSend = conversion.eth2Wei(parseFloat(value), token.decimals)
      let toAddress = token.address
      let transfer = Transfer(
        to: parseAddress(to_addr),
        value: amountToSend,
      )
      let data = ERC20_procS.toTable["transfer"].encodeAbi(transfer)

      for route in routes:
        var txData = TransactionDataDto()
        var gasFees: string = ""

        if(not route.gasFees.eip1559Enabled):
          gasFees = $route.gasFees.gasPrice

        if route.approvalRequired:
          paths.add(self.createApprovalPath(route, from_addr, toAddress, gasFees))

        txData = ens_utils.buildTokenTransaction(parseAddress(from_addr), toAddress,
          $route.gasAmount, gasFees, route.gasFees.eip1559Enabled, $route.gasFees.maxPriorityFeePerGas, $route.gasFees.maxFeePerGasM)
        txData.data = data

        paths.add(self.createPath(route, txData, tokenSymbol, to_addr))

      let response = transactions.createMultiTransaction(
        MultiTransactionCommandDto(
          fromAddress: from_addr,
          toAddress: to_addr,
          fromAsset: tokenSymbol,
          toAsset: tokenSymbol,
          fromAmount:  "0x" & amountToSend.toHex,
          multiTxType: transactions.MultiTransactionType.MultiTransactionSend,
        ),
        paths,
        password,
      )

      if response.result{"hashes"} != nil:
        for route in routes:
          for hash in response.result["hashes"][$route.fromNetwork.chainID]:
            self.watchTransaction(hash.getStr, from_addr, to_addr, $PendingTransactionTypeDto.WalletTransfer, " ", route.fromNetwork.chainID, track = false)
            self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(chainId: route.fromNetwork.chainID, txHash: hash.getStr, uuid: uuid , error: ""))
    except Exception as e:
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(chainId: 0, txHash: "", uuid: uuid, error: fmt"Error sending token transfer transaction: {e.msg}"))

  proc transfer*(
    self: Service,
    from_addr: string,
    to_addr: string,
    tokenSymbol: string,
    value: string,
    uuid: string,
    selectedRoutes: seq[TransactionPathDto],
    password: string,
  ) =
    try:
      var chainID = 0
      var isEthTx = false

      if(selectedRoutes.len > 0):
        chainID = selectedRoutes[0].fromNetwork.chainID

      let network = self.networkService.getNetwork(chainID)
      if network.nativeCurrencySymbol == tokenSymbol:
        isEthTx = true

      if(isEthTx):
        self.transferEth(from_addr, to_addr, tokenSymbol, value, uuid, selectedRoutes, password)
      else:
        self.transferToken(from_addr, to_addr, tokenSymbol, value, uuid, selectedRoutes, password)

    except Exception as e:
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(chainId: 0, txHash: "", uuid: uuid, error: fmt"Error sending token transfer transaction: {e.msg}"))

  proc suggestedFees*(self: Service, chainId: int): SuggestedFeesDto =
    try:
      let response = eth.suggestedFees(chainId).result
      return response.toSuggestedFeesDto()
    except Exception as e:
      error "Error getting suggested fees", msg = e.msg

  proc suggestedRoutesReady*(self: Service, suggestedRoutes: string) {.slot.} =
    var suggestedRoutesDto: SuggestedRoutesDto = SuggestedRoutesDto()
    try:
      let responseObj = suggestedRoutes.parseJson
      suggestedRoutesDto = responseObj.convertToSuggestedRoutesDto()
    except Exception as e:
      error "error handling suggestedRoutesReady response", errDesription=e.msg
    self.events.emit(SIGNAL_SUGGESTED_ROUTES_READY, SuggestedRoutesArgs(suggestedRoutes: suggestedRoutesDto))

  proc suggestedRoutes*(self: Service, account: string, amount: Uint256, token: string, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs: seq[int], sendType: int, lockedInAmounts: string): SuggestedRoutesDto =
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

  proc onFetchCryptoServices*(self: Service, response: string) {.slot.} =
    let cryptoServices = parseJson(response){"result"}.getElems().map(x => x.toCryptoRampDto())
    self.events.emit(SIGNAL_CRYPTO_SERVICES_READY, CryptoServicesArgs(data: cryptoServices))

  proc fetchCryptoServices*(self: Service) =
    let arg = GetCryptoServicesTaskArg(
      tptr: cast[ByteAddress](getCryptoServicesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onFetchCryptoServices",
    )
    self.threadpool.start(arg)

  proc getEstimatedTime*(self: Service, chainId: int, maxFeePerGas: string): EstimatedTime =
    try:
      let response = backend.getTransactionEstimatedTime(chainId, maxFeePerGas.parseFloat).result.getInt
      return EstimatedTime(response)
    except Exception as e:
      error "Error estimating transaction time", message = e.msg
      return EstimatedTime.Unknown

  proc getLatestBlockNumber*(self: Service, chainId: int): string =
    try:
      let response = eth.getBlockByNumber(chainId, "latest")
      return response.result{"number"}.getStr
    except Exception as e:
      error "Error getting latest block number", message = e.msg
      return ""

proc getMultiTransactions*(transactionIDs: seq[int]): seq[MultiTransactionDto] =
  try:
    let response = transactions.getMultiTransactions(transactionIDs).result

    return response.getElems().map(x => x.toMultiTransactionDto())
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    return
