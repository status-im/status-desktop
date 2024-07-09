import Tables, NimQml, chronicles, sequtils, sugar, stint, strutils, json, stew/shims/strformat

import backend/collectibles as collectibles
import backend/transactions as transactions
import backend/backend
import backend/eth

import app_service/service/ens/utils as ens_utils
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
import app_service/service/eth/dto/transaction as transaction_data_dto
import app_service/service/eth/dto/[coder, method_dto]
import ./dto as transaction_dto
import ./dtoV2
import ./dto_conversion
import ./cryptoRampDto
import app_service/service/eth/utils as eth_utils


export transaction_dto
export transactions.TransactionsSignatures

logScope:
  topics = "transaction-service"

include async_tasks
include app_service/common/json_utils

# Signals which may be emitted by this service:
const SIGNAL_TRANSACTION_SENT* = "transactionSent"
const SIGNAL_SUGGESTED_ROUTES_READY* = "suggestedRoutesReady"
const SIGNAL_HISTORY_NON_ARCHIVAL_NODE* = "historyNonArchivalNode"
const SIGNAL_HISTORY_ERROR* = "historyError"
const SIGNAL_CRYPTO_SERVICES_READY* = "cryptoServicesReady"
const SIGNAL_TRANSACTION_DECODED* = "transactionDecoded"
const SIGNAL_OWNER_TOKEN_SENT* = "ownerTokenSent"
const SIGNAL_TRANSACTION_SENDING_COMPLETE* = "transactionSendingComplete"

const SIMPLE_TX_BRIDGE_NAME = "Transfer"
const HOP_TX_BRIDGE_NAME = "Hop"
const ERC721_TRANSFER_NAME = "ERC721Transfer"
const ERC1155_TRANSFER_NAME = "ERC1155Transfer"
const SWAP_PARASWAP_NAME = "Paraswap"

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

proc `$`*(self: TransactionMinedArgs): string =
  try:
    fmt"""TransactionMinedArgs(
      transactionHash: {$self.transactionHash},
      chainId: {$self.chainId},
      success: {$self.success},
      data: {self.data},
      )"""
  except ValueError:
    raiseAssert "static fmt"

type
  TransactionSentArgs* = ref object of Args
    chainId*: int
    txHash*: string
    uuid*: string
    error*: string

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

  ## Forward declarations
  proc suggestedRoutesV2Ready(self: Service, uuid: string, route: seq[TransactionPathDtoV2], routeRaw: string, error: string, errCode: string)

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
      self.suggestedRoutesV2Ready(data.uuid, data.bestRoute, data.bestRouteRaw, data.error, data.errorCode)

    self.events.on(PendingTransactionTypeDto.WalletTransfer.event) do(e: Args):
      try:
        var receivedData = TransactionMinedArgs(e)
        let tokenMetadata = receivedData.data.parseJson().toTokenTransferMetadata()
        if tokenMetadata.isOwnerToken:
          let status = if receivedData.success: ContractTransactionStatus.Completed else: ContractTransactionStatus.Failed
          self.events.emit(SIGNAL_OWNER_TOKEN_SENT, OwnerTokenSentArgs(chainId: receivedData.chainId, txHash: receivedData.transactionHash, tokenName: tokenMetadata.tokenName, status: status))
        self.events.emit(SIGNAL_TRANSACTION_SENDING_COMPLETE, receivedData)
      except Exception as e:
        debug "Not the owner token transfer", msg=e.msg

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
    path.transferTx = txData
    return path

  proc createPath*(self: Service, route: TransactionPathDto, txData: TransactionDataDto, tokenSymbol: string, to_addr: string): TransactionBridgeDto =
    var path = TransactionBridgeDto(bridgeName: route.bridgeName, chainID: route.fromNetwork.chainId)
    var hopTx = TransactionDataDto()
    var cbridgeTx = TransactionDataDto()
    var eRC721TransferTx = TransactionDataDto()
    var eRC1155TransferTx = TransactionDataDto()
    var swapTx = TransactionDataDto()

    if(route.bridgeName == SIMPLE_TX_BRIDGE_NAME):
      path.transferTx = txData
    elif(route.bridgeName == HOP_TX_BRIDGE_NAME):
      hopTx = txData
      hopTx.chainID =  route.toNetwork.chainId.some
      hopTx.symbol = tokenSymbol.some
      hopTx.recipient = parseAddress(to_addr).some
      hopTx.amount = route.amountIn.some
      hopTx.bonderFee = route.bonderFees.some
      path.hopTx = hopTx
    elif(route.bridgeName == ERC721_TRANSFER_NAME):
      eRC721TransferTx = txData
      eRC721TransferTx.chainID =  route.toNetwork.chainId.some
      eRC721TransferTx.recipient = parseAddress(to_addr).some
      eRC721TransferTx.tokenID = stint.u256(tokenSymbol).some
      path.eRC721TransferTx = eRC721TransferTx
    elif(route.bridgeName == ERC1155_TRANSFER_NAME):
      eRC1155TransferTx = txData
      eRC1155TransferTx.chainID =  route.toNetwork.chainId.some
      eRC1155TransferTx.recipient = parseAddress(to_addr).some
      eRC1155TransferTx.tokenID = stint.u256(tokenSymbol).some
      eRC1155TransferTx.amount = route.amountIn.some
      path.eRC1155TransferTx = eRC1155TransferTx
    elif(route.bridgeName == SWAP_PARASWAP_NAME):
      swapTx = txData
      swapTx.chainID =  route.fromNetwork.chainId.some
      swapTx.chainIDTo = route.toNetwork.chainId.some
      swapTx.tokenIdFrom = route.fromToken.symbol.some
      swapTx.tokenIdTo = route.toToken.symbol.some
      path.swapTx = swapTx
    else:
      cbridgeTx = txData
      cbridgeTx.chainID =  route.toNetwork.chainId.some
      cbridgeTx.symbol = tokenSymbol.some
      cbridgeTx.recipient = parseAddress(to_addr).some
      cbridgeTx.amount = route.amountIn.some
      path.cbridgeTx = cbridgeTx
    return path

  proc sendTransactionSentSignal(self: Service, fromAddr: string, toAddr: string, uuid: string,
    routes: seq[TransactionPathDto], response: RpcResponse[JsonNode], err: string = "", tokenName = "", isOwnerToken=false) =
    # While preparing the tx in the Send modal user cannot see the address, it's revealed once the tx is sent
    # (there are few places where we display the toast from and link to the etherscan where the address can be seen)
    # that's why we need to mark the addresses as shown here (safer).
    self.events.emit(MARK_WALLET_ADDRESSES_AS_SHOWN, WalletAddressesArgs(addresses: @[fromAddr, toAddr]))

    if err.len > 0:
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(uuid: uuid, error: err))
    elif response.result{"hashes"} != nil:
      for route in routes:
        for hash in response.result["hashes"][$route.fromNetwork.chainID]:
          if isOwnerToken:
            self.events.emit(SIGNAL_OWNER_TOKEN_SENT, OwnerTokenSentArgs(chainId: route.fromNetwork.chainID, txHash: hash.getStr, uuid: uuid, tokenName: tokenName, status: ContractTransactionStatus.InProgress))
          else:
            self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(chainId: route.fromNetwork.chainID, txHash: hash.getStr, uuid: uuid , error: ""))

          let metadata = TokenTransferMetadata(tokenName: tokenName, isOwnerToken: isOwnerToken)
          self.watchTransaction(hash.getStr, fromAddr, toAddr, $PendingTransactionTypeDto.WalletTransfer, $(%metadata), route.fromNetwork.chainID, track = false)

  proc isCollectiblesTransfer(self: Service, sendType: SendType): bool =
    return sendType == ERC721Transfer or sendType == ERC1155Transfer

  proc sendTypeToMultiTxType(sendType: SendType): transactions.MultiTransactionType =
    case sendType
    of SendType.Swap:
      return transactions.MultiTransactionType.MultiTransactionSwap
    of SendType.Approve:
      return transactions.MultiTransactionType.MultiTransactionApprove
    else:
      return transactions.MultiTransactionType.MultiTransactionSend

  proc transferEth(
    self: Service,
    from_addr: string,
    to_addr: string,
    tokenSymbol: string,
    toTokenSymbol: string,
    uuid: string,
    routes: seq[TransactionPathDto],
    password: string,
    sendType: SendType,
    slippagePercentage: Option[float]
  ) =
    try:
      var paths: seq[TransactionBridgeDto] = @[]
      var totalAmountToSend: UInt256
      let toAddress = parseAddress(to_addr)

      for route in routes:
        var txData = TransactionDataDto()
        var gasFees: string = ""

        if( not route.gasFees.eip1559Enabled):
          gasFees = $route.gasFees.gasPrice

        if route.approvalRequired:
          paths.add(self.createApprovalPath(route, from_addr, toAddress, gasFees))

        totalAmountToSend += route.amountIn
        txData = ens_utils.buildTransaction(parseAddress(from_addr), route.amountIn,
          $route.gasAmount, gasFees, route.gasFees.eip1559Enabled, $route.gasFees.maxPriorityFeePerGas, $route.gasFees.maxFeePerGasM)
        txData.to = parseAddress(to_addr).some
        txData.slippagePercentage = slippagePercentage

        paths.add(self.createPath(route, txData, tokenSymbol, to_addr))

      var mtCommand = MultiTransactionCommandDto(
        fromAddress: from_addr,
        toAddress: to_addr,
        fromAsset: tokenSymbol,
        toAsset: toTokenSymbol,
        fromAmount:  "0x" & totalAmountToSend.toHex,
        multiTxType: sendTypeToMultiTxType(sendType),
      )

      let response = transactions.createMultiTransaction(
        mtCommand,
        paths,
        password,
      )

      if password != "":
        self.sendTransactionSentSignal(from_addr, to_addr, uuid, routes, response)
    except Exception as e:
      self.sendTransactionSentSignal(from_addr, to_addr, uuid, @[], RpcResponse[JsonNode](), fmt"Error sending token transfer transaction: {e.msg}")

  proc mustIgnoreApprovalRequests(sendType: SendType): bool =
    # Swap requires approvals to be done in advance in a separate Tx
    return sendType == SendType.Swap

  # in case of collectibles transfer, assetKey is used to get the contract address and token id
  # in case of asset transfer, asset is valid and used to get the asset symbol and contract address
  proc transferToken(
    self: Service,
    from_addr: string,
    to_addr: string,
    assetKey: string,
    asset: TokenBySymbolItem,
    toAssetKey: string,
    toAsset: TokenBySymbolItem,
    uuid: string,
    routes: seq[TransactionPathDto],
    password: string,
    sendType: SendType,
    tokenName: string,
    isOwnerToken: bool,
    slippagePercentage: Option[float]
  ) =
    var
      toContractAddress: Address
      paths: seq[TransactionBridgeDto] = @[]
      totalAmountToSend: UInt256
      mtCommand = MultiTransactionCommandDto(
        fromAddress: from_addr,
        toAddress: to_addr,
        fromAsset: if not asset.isNil: asset.symbol else: assetKey,
        toAsset: if not toAsset.isNil: toAsset.symbol else: toAssetKey,
        multiTxType: sendTypeToMultiTxType(sendType),
      )

    # if collectibles transfer ...
    if asset.isNil:
      let contract_tokenId = assetKey.split(":")
      if contract_tokenId.len == 2:
        toContractAddress = parseAddress(contract_tokenId[0])
        mtCommand.fromAsset = contract_tokenId[1]
        mtCommand.toAsset = contract_tokenId[1]
      else:
        error "Invalid assetKey for collectibles transfer", assetKey=assetKey
        return

    try:
      for route in routes:
        var txData = TransactionDataDto()
        var gasFees: string = ""

        # If not collectible ...
        if not asset.isNil:
          var foundAddress = false
          for addressPerChain in asset.addressPerChainId:
            if addressPerChain.chainId == route.toNetwork.chainId:
              toContractAddress = parseAddress(addressPerChain.address)
              foundAddress = true
              break
          if not foundAddress:
            error "Contract address not found for asset", assetKey=assetKey
            return

        if not route.gasFees.eip1559Enabled:
          gasFees = $route.gasFees.gasPrice

        if route.approvalRequired and not mustIgnoreApprovalRequests(sendType):
          let approvalPath = self.createApprovalPath(route, mtCommand.fromAddress, toContractAddress, gasFees)
          paths.add(approvalPath)

        totalAmountToSend += route.amountIn

        if sendType == SendType.Approve:
          # We only do the approvals
          continue

        let transfer = Transfer(
          to: parseAddress(mtCommand.toAddress),
          value: route.amountIn,
        )
        let data = ERC20_procS.toTable["transfer"].encodeAbi(transfer)

        txData = ens_utils.buildTokenTransaction(
          parseAddress(mtCommand.fromAddress),
          toContractAddress,
          $route.gasAmount,
          gasFees,
          route.gasFees.eip1559Enabled,
          $route.gasFees.maxPriorityFeePerGas,
          $route.gasFees.maxFeePerGasM
          )
        txData.data = data
        txData.slippagePercentage = slippagePercentage

        let path = self.createPath(route, txData, mtCommand.toAsset, mtCommand.toAddress)
        paths.add(path)

      mtCommand.fromAmount =  "0x" & totalAmountToSend.toHex

      let response = transactions.createMultiTransaction(mtCommand, paths, password)

      if password != "":
        self.sendTransactionSentSignal(mtCommand.fromAddress, mtCommand.toAddress, uuid, routes, response, err="", tokenName, isOwnerToken)

    except Exception as e:
      self.sendTransactionSentSignal(mtCommand.fromAddress, mtCommand.toAddress, uuid, @[], RpcResponse[JsonNode](), fmt"Error sending token transfer transaction: {e.msg}")

  proc transfer*(
    self: Service,
    fromAddr: string,
    toAddr: string,
    assetKey: string,
    toAssetKey: string,
    uuid: string,
    selectedRoutes: seq[TransactionPathDto],
    password: string,
    sendType: SendType,
    usePassword: bool,
    doHashing: bool,
    tokenName: string,
    isOwnerToken: bool,
    slippagePercentage: Option[float]
  ) =
    var finalPassword = ""
    if usePassword:
      finalPassword = password
      if doHashing:
        finalPassword = common_utils.hashPassword(password)
    try:
      var chainID = 0

      if(selectedRoutes.len > 0):
        chainID = selectedRoutes[0].fromNetwork.chainID

      # asset == nil means transferToken is executed for a collectibles transfer
      var
        asset: TokenBySymbolItem
        toAsset: TokenBySymbolItem
      if not self.isCollectiblesTransfer(sendType):
        asset = self.tokenService.getTokenBySymbolByTokensKey(assetKey)
        if asset.isNil:
          error "Asset not found for", assetKey=assetKey
          return

        toAsset = asset
        if sendType == Swap:
          toAsset = self.tokenService.getTokenBySymbolByTokensKey(toAssetKey)
          if toAsset.isNil:
            error "Asset not found for", assetKey=assetKey
            return

        let network = self.networkService.getNetworkByChainId(chainID)
        if not network.isNil and network.nativeCurrencySymbol == asset.symbol:
          self.transferEth(fromAddr, toAddr, asset.symbol, toAsset.symbol, uuid, selectedRoutes, finalPassword, sendType, slippagePercentage)
          return

      self.transferToken(fromAddr, toAddr, assetKey, asset, toAssetKey, toAsset, uuid, selectedRoutes, finalPassword,
        sendType, tokenName, isOwnerToken, slippagePercentage)

    except Exception as e:
      self.events.emit(SIGNAL_TRANSACTION_SENT, TransactionSentArgs(chainId: 0, txHash: "", uuid: uuid, error: fmt"Error sending token transfer transaction: {e.msg}"))

  proc proceedWithTransactionsSignatures*(self: Service, fromAddr: string, toAddr: string, uuid: string,
    signatures: TransactionsSignatures, selectedRoutes: seq[TransactionPathDto]) =
    try:
      let response = transactions.proceedWithTransactionsSignatures(signatures)
      self.sendTransactionSentSignal(fromAddr, toAddr, uuid, selectedRoutes, response)
    except Exception as e:
      self.sendTransactionSentSignal(fromAddr, toAddr, uuid, @[], RpcResponse[JsonNode](), fmt"Error proceeding with transactions signatures: {e.msg}")

  proc suggestedFees*(self: Service, chainId: int): SuggestedFeesDto =
    try:
      let response = eth.suggestedFees(chainId).result
      return response.toSuggestedFeesDto()
    except Exception as e:
      error "Error getting suggested fees", msg = e.msg

  proc suggestedRoutesV2Ready(self: Service, uuid: string, route: seq[TransactionPathDtoV2], routeRaw: string, error: string, errCode: string) =
    # TODO: refactor sending modal part of the app, but for now since we're integrating the router v2 just map params to the old dto

    var oldRoute = convertToOldRoute(route)

    let suggestedDto = SuggestedRoutesDto(
      best: addFirstSimpleBridgeTxFlag(oldRoute),
      rawBest: routeRaw,
      gasTimeEstimate: getFeesTotal(oldRoute),
      amountToReceive: getTotalAmountToReceive(oldRoute),
      toNetworks: getToNetworksList(oldRoute),
    )
    self.events.emit(SIGNAL_SUGGESTED_ROUTES_READY, SuggestedRoutesArgs(uuid: uuid, suggestedRoutes: suggestedDto))

  proc suggestedRoutes*(self: Service,
    uuid: string,
    sendType: SendType,
    accountFrom: string,
    accountTo: string,
    token: string,
    amountIn: string,
    toToken: string = "",
    amountOut: string = "",
    disabledFromChainIDs: seq[int] = @[],
    disabledToChainIDs: seq[int] = @[],
    lockedInAmounts: Table[string, string] = initTable[string, string](),
    extraParamsTable: Table[string, string] = initTable[string, string]()) =

    let
      bigAmountIn = common_utils.stringToUint256(amountIn)
      bigAmountOut = common_utils.stringToUint256(amountOut)
      amountInHex = "0x" & eth_utils.stripLeadingZeros(bigAmountIn.toHex)
      amountOutHex = "0x" & eth_utils.stripLeadingZeros(bigAmountOut.toHex)

    try:
      let res = eth.suggestedRoutesV2Async(uuid, ord(sendType), accountFrom, accountTo, amountInHex, amountOutHex, token,
        toToken, disabledFromChainIDs, disabledToChainIDs, lockedInAmounts, extraParamsTable)
    except CatchableError as e:
      error "suggestedRoutes", exception=e.msg

  proc onFetchCryptoServices*(self: Service, response: string) {.slot.} =
    let cryptoServices = parseJson(response){"result"}.getElems().map(x => x.toCryptoRampDto())
    self.events.emit(SIGNAL_CRYPTO_SERVICES_READY, CryptoServicesArgs(data: cryptoServices))

  proc fetchCryptoServices*(self: Service) =
    let arg = GetCryptoServicesTaskArg(
      tptr: getCryptoServicesTask,
      vptr: cast[ByteAddress](self.vptr),
      slot: "onFetchCryptoServices",
    )
    self.threadpool.start(arg)

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
