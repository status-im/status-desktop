import Tables, NimQml, chronicles, sequtils, sugar, stint, strutils, json, stew/shims/strformat

import backend/collectibles as collectibles
import backend/transactions as transactions
import backend/backend
import backend/eth
import backend/wallet

import app_service/common/utils as common_utils
import app_service/common/types as common_types

import app/core/[main]
import app/core/signals/types
import app/core/tasks/[qt, threadpool]
import app/global/global_singleton
import app/global/app_signals

import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/token/service as token_service
import app_service/service/settings/service as settings_service
import ./dto as transaction_dto
import ./dtoV2
import ./dto_conversion
import ./router_transactions_dto
import app_service/service/eth/utils as eth_utils


export transaction_dto, router_transactions_dto
export transactions.TransactionsSignatures

logScope:
  topics = "transaction-service"

include async_tasks
include app_service/common/json_utils

# Signals which may be emitted by this service:
const SIGNAL_SIGN_ROUTER_TRANSACTIONS* = "signRouterTransactions"
const SIGNAL_SENDING_TRANSACTIONS_STARTED* = "sendingTransactionsStarted"
const SIGNAL_TRANSACTION_SENT* = "transactionSent"
const SIGNAL_SUGGESTED_ROUTES_READY* = "suggestedRoutesReady"
const SIGNAL_HISTORY_NON_ARCHIVAL_NODE* = "historyNonArchivalNode"
const SIGNAL_HISTORY_ERROR* = "historyError"
const SIGNAL_TRANSACTION_DECODED* = "transactionDecoded"
const SIGNAL_OWNER_TOKEN_SENT* = "ownerTokenSent"
const SIGNAL_TRANSACTION_STATUS_CHANGED* = "transactionStatusChanged"

const InternalErrorCode = -1

type TokenTransferMetadata* = object
  tokenName*: string
  isOwnerToken*: bool

proc `%`*(self: TokenTransferMetadata): JsonNode =
  result = %* {
    "tokenName": self.tokenName,
    "isOwnerToken": self.isOwnerToken,
  }

proc toTokenTransferMetadata*(jsonObj: JsonNode): TokenTransferMetadata =
  result = TokenTransferMetadata()
  discard jsonObj.getProp("tokenName", result.tokenName)
  discard jsonObj.getProp("isOwnerToken", result.isOwnerToken)

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
    txType*: SendType
    fromAddress*: string
    toAddress*: string
    fromTokenKey*: string
    fromAmount*: string
    toTokenKey*: string
    toAmount*: string

proc `$`*(self: TransactionMinedArgs): string =
  try:
    fmt"""TransactionMinedArgs(
      transactionHash: {$self.transactionHash},
      chainId: {$self.chainId},
      success: {$self.success},
      data: {self.data},
      txType: {$self.txType},
      fromAddress: {$self.fromAddress},
      toAddress: {$self.toAddress},
      fromTokenKey: {$self.fromTokenKey},
      fromAmount: {$self.fromAmount},
      toTokenKey: {$self.toTokenKey},
      toAmount: {$self.toAmount},
      )"""
  except ValueError:
    raiseAssert "static fmt"

type
  OwnerTokenSentArgs* = ref object of Args
    chainId*: int
    txHash*: string
    tokenName*: string
    uuid*: string
    status*: ContractTransactionStatus

type
  SuggestedRoutesArgs* = ref object of Args
    uuid*: string
    suggestedRoutes*: SuggestedRoutesDto
    # this should be the only one used when old send modal code is removed
    routes*: seq[TransactionPathDtoV2]
    errCode*: string
    errDescription*: string

type
  TransactionDecodedArgs* = ref object of Args
    dataDecoded*: string
    txHash*: string

type
  RouterTransactionsForSigningArgs* = ref object of Args
    data*: RouterTransactionsForSigningDto

type
  TransactionArgs* = ref object of Args
    status*: string
    sendDetails*: SendDetailsDto
    sentTransaction*: RouterSentTransaction

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    networkService: network_service.Service
    settingsService: settings_service.Service
    tokenService: token_service.Service
    uuidOfTheLastRequestForSuggestedRoutes: string

  ## Forward declarations
  proc suggestedRoutesReady(self: Service, uuid: string, route: seq[TransactionPathDtoV2], routeRaw: string, errCode: string, errDescription: string)
  proc sendTransactionsSignal(self: Service, sendDetails: SendDetailsDto, sentTransactions: seq[RouterSentTransaction] = @[])

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

    self.events.on(SignalType.WalletSuggestedRoutes.event) do(e:Args):
      var data = WalletSignal(e)
      self.tokenService.updateTokenPrices(data.updatedPrices)
      self.suggestedRoutesReady(data.uuid, data.bestRoute, data.bestRouteRaw, data.errorCode, data.error)

    self.events.on(SignalType.WalletRouterSendingTransactionsStarted.event) do(e:Args):
      var data = WalletSignal(e)
      self.events.emit(SIGNAL_SENDING_TRANSACTIONS_STARTED, TransactionArgs(
        status: TxStatusSending,
        sendDetails: data.routerTransactionsSendingDetails
      ))

    self.events.on(SignalType.WalletRouterSignTransactions.event) do(e:Args):
      var data = WalletSignal(e)
      if data.routerTransactionsForSigning.sendDetails.errorResponse.isNil and
        not data.routerTransactionsForSigning.signingDetails.isNil:
          self.events.emit(SIGNAL_SIGN_ROUTER_TRANSACTIONS, RouterTransactionsForSigningArgs(data: data.routerTransactionsForSigning))
          return
      self.sendTransactionsSignal(data.routerTransactionsForSigning.sendDetails)

    self.events.on(SignalType.WalletRouterTransactionsSent.event) do(e:Args):
      var data = WalletSignal(e)
      self.sendTransactionsSignal(data.routerSentTransactions.sendDetails, data.routerSentTransactions.sentTransactions)

    self.events.on(SignalType.WalletTransactionStatusChanged.event) do(e:Args):
      var data = WalletSignal(e)
      if data.transactionStatusChange.isNil:
        return
      for tx in data.transactionStatusChange.sentTransactions:
        self.events.emit(SIGNAL_TRANSACTION_STATUS_CHANGED, TransactionArgs(
          status: data.transactionStatusChange.status,
          sendDetails: data.transactionStatusChange.sendDetails,
          sentTransaction: tx
        ))

    # TODO: handle this for community related tx (minting, airdropping...)
    # self.events.on(PendingTransactionTypeDto.WalletTransfer.event) do(e: Args):
    #   try:
    #     var receivedData = TransactionMinedArgs(e)
    #     let tokenMetadata = receivedData.data.parseJson().toTokenTransferMetadata()
    #     if tokenMetadata.isOwnerToken:
    #       let status = if receivedData.success: ContractTransactionStatus.Completed else: ContractTransactionStatus.Failed
    #       self.events.emit(SIGNAL_OWNER_TOKEN_SENT, OwnerTokenSentArgs(chainId: receivedData.chainId, txHash: receivedData.transactionHash, tokenName: tokenMetadata.tokenName, status: status))
    #     self.events.emit(SIGNAL_TRANSACTION_SENDING_COMPLETE, receivedData)
    #   except Exception as e:
    #     debug "Not the owner token transfer", msg=e.msg

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

  proc extractRpcErrorMessage(self: Service, errorMessage: string): string =
    var startIndex = errorMessage.find("message:")
    if startIndex < 0:
      return errorMessage
    startIndex += 8
    let endIndex = errorMessage.rfind("]")
    return errorMessage[startIndex..endIndex-1]

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
          txType: SendType(watchTxResult["txType"].getInt),
          fromAddress: address,
          toAddress: watchTxResult["toAddress"].getStr,
          fromTokenKey: watchTxResult["fromTokenKey"].getStr,
          fromAmount: watchTxResult["fromAmount"].getStr,
          toTokenKey: watchTxResult["toTokenKey"].getStr,
          toAmount: watchTxResult["toAmount"].getStr,
        )
        self.events.emit(parseEnum[PendingTransactionTypeDto](watchTxResult["trxType"].getStr).event, ev)
        transactions.checkRecentHistory(@[chainId], @[address])

  proc watchTransaction*(
    self: Service, hash: string, fromAddress: string, toAddress: string, trxType: string, data: string, chainId: int,
    fromTokenKey: string = "", fromAmount: string = "", toTokenKey: string = "", toAmount: string = "", txType: SendType = SendType.Transfer
  ) =
    let arg = WatchTransactionTaskArg(
      chainId: chainId,
      hash: hash,
      address: fromAddress,
      trxType: trxType,
      txType: ord(txType),
      fromTokenKey: fromTokenKey,
      fromAmount: fromAmount,
      toTokenKey: toTokenKey,
      toAmount: toAmount,
      data: data,
      tptr: watchTransactionTask,
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
      tptr: fetchDecodedTxDataTask,
      vptr: cast[ByteAddress](self.vptr),
      data: data,
      txHash: txHash,
      slot: "onFetchDecodedTxData",
    )
    self.threadpool.start(arg)

  proc sendTransactionsSignal(self: Service, sendDetails: SendDetailsDto, sentTransactions: seq[RouterSentTransaction] = @[]) =
    # While preparing the tx in the Send modal user cannot see the address, it's revealed once the tx is sent
    # (there are few places where we display the toast from and link to the etherscan where the address can be seen)
    # that's why we need to mark the addresses as shown here (safer).
    self.events.emit(MARK_WALLET_ADDRESSES_AS_SHOWN, WalletAddressesArgs(addresses: @[sendDetails.fromAddress, sendDetails.toAddress]))

    if sentTransactions.len == 0:
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionArgs(sendDetails: sendDetails))
      return

    for tx in sentTransactions:
      if sendDetails.ownerTokenBeingSent:
        self.events.emit(SIGNAL_OWNER_TOKEN_SENT, OwnerTokenSentArgs(
          chainId: tx.fromChain,
          txHash: tx.hash,
          uuid: sendDetails.uuid,
          tokenName: tx.fromToken,
          status: ContractTransactionStatus.InProgress
        ))
      else:
        self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionArgs(
          status: TxStatusSending, # here should be TxStatusPending state, but that's not what Figma wants
          sendDetails: sendDetails,
          sentTransaction: tx
        ))

  proc suggestedFees*(self: Service, chainId: int): SuggestedFeesDto =
    try:
      let response = eth.suggestedFees(chainId).result
      return response.toSuggestedFeesDto()
    except Exception as e:
      error "Error getting suggested fees", msg = e.msg

  proc suggestedRoutesReady(self: Service, uuid: string, route: seq[TransactionPathDtoV2], routeRaw: string, errCode: string, errDescription: string) =
    if self.uuidOfTheLastRequestForSuggestedRoutes != uuid:
      return

    # TODO: refactor sending modal part of the app, but for now since we're integrating the router v2 just map params to the old dto
    var oldRoute = convertToOldRoute(route)

    let suggestedDto = SuggestedRoutesDto(
      best: addFirstSimpleBridgeTxFlag(oldRoute),
      rawBest: routeRaw,
      gasTimeEstimate: getFeesTotal(oldRoute),
      amountToReceive: getTotalAmountToReceive(oldRoute),
      toNetworks: getToNetworksList(oldRoute),
    )
    self.events.emit(SIGNAL_SUGGESTED_ROUTES_READY, SuggestedRoutesArgs(
      uuid: uuid,
      suggestedRoutes: suggestedDto,
      routes: route,
      errCode: errCode,
      errDescription: errDescription
    ))

  proc suggestedRoutes*(self: Service,
    uuid: string,
    sendType: SendType,
    accountFrom: string,
    accountTo: string,
    token: string,
    tokenIsOwnerToken: bool,
    amountIn: string,
    toToken: string = "",
    amountOut: string = "",
    disabledFromChainIDs: seq[int] = @[],
    disabledToChainIDs: seq[int] = @[],
    lockedInAmounts: Table[string, string] = initTable[string, string](),
    extraParamsTable: Table[string, string] = initTable[string, string]()) =

    self.uuidOfTheLastRequestForSuggestedRoutes = uuid

    let
      bigAmountIn = common_utils.stringToUint256(amountIn)
      bigAmountOut = common_utils.stringToUint256(amountOut)
      amountInHex = "0x" & eth_utils.stripLeadingZeros(bigAmountIn.toHex)
      amountOutHex = "0x" & eth_utils.stripLeadingZeros(bigAmountOut.toHex)

    try:
      let res = eth.suggestedRoutesAsync(uuid, ord(sendType), accountFrom, accountTo, amountInHex, amountOutHex, token,
        tokenIsOwnerToken, toToken, disabledFromChainIDs, disabledToChainIDs, lockedInAmounts, extraParamsTable)
    except CatchableError as e:
      error "suggestedRoutes", exception=e.msg
      self.suggestedRoutesReady(uuid, @[], "", $InternalErrorCode, e.msg)

  proc stopSuggestedRoutesAsyncCalculation*(self: Service) =
    try:
      discard eth.stopSuggestedRoutesAsyncCalculation()
    except CatchableError as e:
      error "stopSuggestedRoutesAsyncCalculation", exception=e.msg

  proc getEstimatedTime*(self: Service, chainId: int, maxFeePerGas: string): EstimatedTime =
    try:
      let response = backend.getTransactionEstimatedTime(chainId, maxFeePerGas).result.getInt
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

  proc getEstimatedLatestBlockNumber*(self: Service, chainId: int): string =
    try:
      return $eth.getEstimatedLatestBlockNumber(chainId).result
    except Exception as e:
      error "Error getting estimated latest block number", message = e.msg
      return ""

proc getMultiTransactions*(transactionIDs: seq[int]): seq[MultiTransactionDto] =
  try:
    let response = transactions.getMultiTransactions(transactionIDs).result

    return response.getElems().map(x => x.toMultiTransactionDto())
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    return

proc signMessage*(self: Service, address: string, hashedPassword: string, hashedMessage: string): tuple[res: string, err: string] =
  var signMsgRes: JsonNode
  let err = wallet.signMessage(signMsgRes,
    hashedMessage,
    address,
    hashedPassword)
  if err.len > 0:
    error "status-go - wallet_signMessage failed", err=err
    result.err = err
    return
  result.res = signMsgRes.getStr
  return

proc buildTransactionsFromRoute*(self: Service, uuid: string, slippagePercentage: float): string =
  var response: JsonNode
  let err = transactions.buildTransactionsFromRoute(response, uuid, slippagePercentage)
  if err.len > 0:
    error "status-go - transfer failed", err=err
    return err
  if response.kind != JNull:
    error "unexpected transfer response"
    return "unexpected transfer response"
  return ""

proc sendRouterTransactionsWithSignatures*(self: Service, uuid: string, signatures: TransactionsSignatures): string =
  var response: JsonNode
  let err = transactions.sendRouterTransactionsWithSignatures(response, uuid, signatures)
  if err.len > 0:
    error "status-go - wallet_sendRouterTransactionsWithSignatures failed", err=err
    return err
  if response.kind != JNull:
    error "unexpected sending transactions response"
    return "unexpected sending transactions response"
  return ""
