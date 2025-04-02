import Tables, NimQml, chronicles, sequtils, sugar, stint, strutils, json, stew/shims/strformat

import backend/collectibles as collectibles
import backend/transactions as transactions
import backend/backend
import backend/eth
import backend/wallet

import app/core/[main]
import app/core/signals/types
import app/core/tasks/[qt, threadpool]
import app/global/global_singleton
import app/global/app_signals

import app_service/common/wallet_constants as common_wallet_constants
import app_service/common/utils as common_utils
import app_service/common/types as common_types
import app_service/service/currency/service as currency_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/token/service as token_service
import app_service/service/settings/service as settings_service
import app_service/service/eth/utils as eth_utils
import ./dto as transaction_dto
import ./dtoV2
import ./dto_conversion
import ./router_transactions_dto

import app/modules/shared_models/currency_amount

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
const SIGNAL_TRANSACTION_STATUS_CHANGED* = "transactionStatusChanged"

const InternalErrorCode* = -1

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
    sendType*: SendType
    suggestedRoutes*: SuggestedRoutesDto
    # this should be the only one used when old send modal code is removed
    routes*: seq[TransactionPathDtoV2]
    errCode*: string
    errDescription*: string
    # Below fields used for community related tx
    costPerPath*: seq[CostPerPath]
    totalCostEthCurrency*: CurrencyAmount
    totalCostFiatCurrency*: CurrencyAmount

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
    currencyService: currency_service.Service
    networkService: network_service.Service
    settingsService: settings_service.Service
    tokenService: token_service.Service
    lastRequestForSuggestedRoutes: tuple[uuid: string, sendType: SendType]

  ## Forward declarations
  proc suggestedRoutesReady(self: Service, uuid: string, route: seq[TransactionPathDtoV2], routeRaw: string, errCode: string, errDescription: string)
  proc sendTransactionsSignal(self: Service, sendDetails: SendDetailsDto, sentTransactions: seq[RouterSentTransaction] = @[])

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      currencyService: currency_service.Service,
      networkService: network_service.Service,
      settingsService: settings_service.Service,
      tokenService: token_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.currencyService = currencyService
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
      vptr: cast[uint](self.vptr),
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

  proc updateCommunityRoute(self: Service, data: var SuggestedRoutesArgs, route: seq[TransactionPathDtoV2]) =
    let ethFormat = self.currencyService.getCurrencyFormat(common_wallet_constants.ETH_SYMBOL)
    let currencyFormat = self.currencyService.getCurrencyFormat(self.settingsService.getCurrency())
    let fiatPriceForSymbol = self.tokenService.getPriceBySymbol(ethFormat.symbol)
    var totalFee: UInt256
    for p in route:
      let feeInEth = wei2Eth(p.txTotalFee)
      let ethFeeAsFloat = parseFloat(feeInEth)
      let fiatFeeAsFloat = ethFeeAsFloat * fiatPriceForSymbol
      data.costPerPath.add(CostPerPath(
        contractUniqueKey: common_utils.contractUniqueKey(p.fromChain.chainId, p.usedContractAddress),
        costEthCurrency: newCurrencyAmount(ethFeeAsFloat, ethFormat.symbol, int(ethFormat.displayDecimals), ethFormat.stripTrailingZeroes),
        costFiatCurrency: newCurrencyAmount(fiatFeeAsFloat, currencyFormat.symbol, int(currencyFormat.displayDecimals), currencyFormat.stripTrailingZeroes)
      ))
      totalFee += p.txTotalFee
    let totalFeeInEth = wei2Eth(totalFee)
    let totalEthFeeAsFloat = parseFloat(totalFeeInEth)
    data.totalCostEthCurrency = newCurrencyAmount(totalEthFeeAsFloat, ethFormat.symbol, int(ethFormat.displayDecimals), ethFormat.stripTrailingZeroes)
    let totalFiatFeeAsFloat = totalEthFeeAsFloat * fiatPriceForSymbol
    data.totalCostFiatCurrency = newCurrencyAmount(totalFiatFeeAsFloat, currencyFormat.symbol, int(currencyFormat.displayDecimals), currencyFormat.stripTrailingZeroes)

  proc emitSuggestedRoutesReadySignal*(self: Service, data: SuggestedRoutesArgs) =
    if self.lastRequestForSuggestedRoutes.uuid != data.uuid:
      error "cannot emit suggested routes ready signal, uuid mismatch"
      return
    self.events.emit(SIGNAL_SUGGESTED_ROUTES_READY, data)

  proc suggestedRoutesReady(self: Service, uuid: string, route: seq[TransactionPathDtoV2], routeRaw: string, errCode: string, errDescription: string) =
    if self.lastRequestForSuggestedRoutes.uuid != uuid:
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
    var data = SuggestedRoutesArgs(
      uuid: uuid,
      sendType: self.lastRequestForSuggestedRoutes.sendType,
      suggestedRoutes: suggestedDto,
      routes: route,
      errCode: errCode,
      errDescription: errDescription
    )

    if self.lastRequestForSuggestedRoutes.sendType == SendType.CommunityBurn or
      self.lastRequestForSuggestedRoutes.sendType == SendType.CommunityDeployAssets or
      self.lastRequestForSuggestedRoutes.sendType == SendType.CommunityDeployCollectibles or
      self.lastRequestForSuggestedRoutes.sendType == SendType.CommunityDeployOwnerToken or
      self.lastRequestForSuggestedRoutes.sendType == SendType.CommunityMintTokens or
      self.lastRequestForSuggestedRoutes.sendType == SendType.CommunityRemoteBurn or
      self.lastRequestForSuggestedRoutes.sendType == SendType.CommunitySetSignerPubKey:
        self.updateCommunityRoute(data, route)

    self.emitSuggestedRoutesReadySignal(data)

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
    extraParamsTable: Table[string, string] = initTable[string, string]()) =

    self.lastRequestForSuggestedRoutes = (uuid, sendType)

    let
      bigAmountIn = common_utils.stringToUint256(amountIn)
      bigAmountOut = common_utils.stringToUint256(amountOut)
      amountInHex = "0x" & eth_utils.stripLeadingZeros(bigAmountIn.toHex)
      amountOutHex = "0x" & eth_utils.stripLeadingZeros(bigAmountOut.toHex)

    try:
      let err = wallet.suggestedRoutesAsync(uuid, ord(sendType), accountFrom, accountTo, amountInHex, amountOutHex, token,
        tokenIsOwnerToken, toToken, disabledFromChainIDs, disabledToChainIDs, extraParamsTable)
      if err.len > 0:
        raise newException(CatchableError, "err fetching the best route: " & err)
    except CatchableError as e:
      error "suggestedRoutes", exception=e.msg
      self.suggestedRoutesReady(uuid, @[], "", $InternalErrorCode, e.msg)

  proc suggestedCommunityRoutes*(self: Service, uuid: string, sendType: SendType, chainId: int, accountFrom: string,
    communityId: string, signerPubKey: string = "", tokenIds: seq[string] = @[], walletAddresses: seq[string] = @[],
    transferDetails: seq[JsonNode] = @[], signature: string = "", ownerTokenParameters: JsonNode = JsonNode(),
    masterTokenParameters: JsonNode = JsonNode(), deploymentParameters: JsonNode = JsonNode()) =
    self.lastRequestForSuggestedRoutes = (uuid, sendType)
    try:
      let
        disabledFromChainIDs = self.networkService.getDisabledChainIdsForEnabledChainIds(@[chainId])
        disabledToChainIDs = disabledFromChainIDs

      let err = wallet.suggestedRoutesAsyncForCommunities(
        uuid,
        ord(sendType),
        accountFrom,
        disabledFromChainIDs,
        disabledToChainIDs,
        communityId,
        signerPubKey,
        tokenIds,
        walletAddresses,
        tokenDeploymentSignature = signature,
        ownerTokenParameters,
        masterTokenParameters,
        deploymentParameters,
        transferDetails
      )
      if err.len > 0:
        raise newException(CatchableError, "err fetching the best route for deploying owner: " & err)
    except Exception as e:
      error "Error loading fees", msg = e.msg
      self.suggestedRoutesReady(uuid, @[], "", $InternalErrorCode, e.msg)

  proc stopSuggestedRoutesAsyncCalculation*(self: Service) =
    try:
      discard wallet.stopSuggestedRoutesAsyncCalculation()
    except CatchableError as e:
      error "stopSuggestedRoutesAsyncCalculation", exception=e.msg

  proc setFeeMode*(self: Service, feeMode: int, routerInputParamsUuid: string, pathName: string, chainId: int,
    isApprovalTx: bool, communityId: string): string =
    try:
      let err = wallet.setFeeMode(feeMode, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId)
      if err.len > 0:
        raise newException(CatchableError, err)
    except CatchableError as e:
      error "setFeeMode", exception=e.msg
      return e.msg

  proc setCustomTxDetails*(self: Service, nonce: int, gasAmount: int, maxFeesPerGas: string, priorityFee: string,
    routerInputParamsUuid: string, pathName: string, chainId: int, isApprovalTx: bool, communityId: string): string =
    try:
      let
        bigMaxFeesPerGas = common_utils.stringToUint256(maxFeesPerGas)
        bigPriorityFee = common_utils.stringToUint256(priorityFee)
        maxFeesPerGasHex = "0x" & eth_utils.stripLeadingZeros(bigMaxFeesPerGas.toHex)
        priorityFeeHex = "0x" & eth_utils.stripLeadingZeros(bigPriorityFee.toHex)

      let err = wallet.setCustomTxDetails(nonce, gasAmount, maxFeesPerGasHex, priorityFeeHex, routerInputParamsUuid, pathName,
        chainId, isApprovalTx, communityId)
      if err.len > 0:
        raise newException(CatchableError, err)
    except CatchableError as e:
      error "setCustomTxDetails", exception=e.msg
      return e.msg

  proc getEstimatedTime*(self: Service, chainId: int, maxFeePerGas: string): EstimatedTime =
    try:
      let response = backend.getTransactionEstimatedTime(chainId, maxFeePerGas).result.getInt
      return EstimatedTime(response)
    except Exception as e:
      error "Error estimating transaction time", message = e.msg
      return EstimatedTime.Unknown

  proc getEstimatedTimeV2*(self: Service, chainId: int, maxFeePerGas: string, priorityFee: string): int =
    try:
      let
        bigMaxFeePerGas = common_utils.stringToUint256(maxFeePerGas)
        bigPriorityFee = common_utils.stringToUint256(priorityFee)
        maxFeePerGasHex = "0x" & eth_utils.stripLeadingZeros(bigMaxFeePerGas.toHex)
        priorityFeeHex = "0x" & eth_utils.stripLeadingZeros(bigPriorityFee.toHex)
      return backend.getTransactionEstimatedTimeV2(chainId, maxFeePerGasHex, priorityFeeHex).result.getInt
    except Exception as e:
      error "Error estimating transaction time", message = e.msg
      return 0

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
