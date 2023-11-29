import NimQml, Tables, json, sequtils, chronicles, strutils, sets, stint

import httpclient

import app/core/[main]
import app/core/tasks/[qt, threadpool]

import web3/ethtypes, web3/conversions, stew/byteutils, nimcrypto, json_serialization

import backend/stickers as status_stickers
import backend/chat as status_chat
import backend/response_type
import backend/eth as status_eth
import backend/helpers/helpers
import backend/backend as status_go_backend
import backend/wallet_connect as status_wallet_connect
import backend/wallet as status_wallet

import ./dto/stickers
import ../ens/utils as ens_utils
import ../token/service as token_service
import ../settings/service as settings_service
import ../eth/dto/transaction
import ../wallet_account/service as wallet_account_service
import ../transaction/service as transaction_service
import ../network/service as network_service
import ../chat/service as chat_service
import app_service/common/types
import app_service/common/utils as common_utils
import ../eth/utils as status_utils

export StickerDto
export StickerPackDto

include async_tasks

logScope:
  topics = "stickers-service"

type
  StickerPackLoadedArgs* = ref object of Args
    stickerPack*: StickerPackDto
    isInstalled*: bool
    isBought*: bool
    isPending*: bool
  StickerGasEstimatedArgs* = ref object of Args
    estimate*: int
    uuid*: string
  GasPriceArgs* = ref object of Args
    gasPrice*: string
  StickerTransactionArgs* = ref object of Args
    transactionHash*: string
    packID*: string
    transactionType*: string
  StickerPackInstalledArgs* = ref object of Args
    packId*: string
  StickersArgs* = ref object of Args
    stickers*: seq[StickerDto]
  StickerPacksArgs* = ref object of Args
    packs*: Table[string, StickerPackDto]
  StickerBuyResultArgs* = ref object of Args
    chainId*: int
    txHash*: string
    error*: string

# Signals which may be emitted by this service:
const SIGNAL_STICKER_PACK_LOADED* = "stickerPackLoaded"
const SIGNAL_ALL_STICKER_PACKS_LOADED* = "allStickerPacksLoaded"
const SIGNAL_ALL_STICKER_PACKS_LOAD_FAILED* = "allStickerPacksLoadFailed"
const SIGNAL_STICKER_GAS_ESTIMATED* = "stickerGasEstimated"
const SIGNAL_STICKER_TRANSACTION_CONFIRMED* = "stickerTransactionConfirmed"
const SIGNAL_STICKER_TRANSACTION_REVERTED* = "stickerTransactionReverted"
const SIGNAL_STICKER_PACK_INSTALLED* = "stickerPackInstalled"
const SIGNAL_LOAD_RECENT_STICKERS_STARTED* = "loadRecentStickersStarted"
const SIGNAL_LOAD_RECENT_STICKERS_FAILED* = "loadRecentStickersFailed"
const SIGNAL_LOAD_RECENT_STICKERS_DONE* = "loadRecentStickersDone"
const SIGNAL_LOAD_INSTALLED_STICKER_PACKS_STARTED* = "loadInstalledStickerPacksStarted"
const SIGNAL_LOAD_INSTALLED_STICKER_PACKS_FAILED* = "loadInstalledStickerPacksFailed"
const SIGNAL_LOAD_INSTALLED_STICKER_PACKS_DONE* = "loadInstalledStickerPacksDone"

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    marketStickerPacks*: Table[string, StickerPackDto]
    recentStickers*: seq[StickerDto]
    events: EventEmitter
    settingsService: settings_service.Service
    walletAccountService: wallet_account_service.Service
    transactionService: transaction_service.Service
    networkService: network_service.Service
    chatService: chat_service.Service
    tokenService: token_service.Service
    installedStickerPacks: Table[string, StickerPackDto]

  # Forward declaration
  proc obtainMarketStickerPacks*(self: Service)

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      settingsService: settings_service.Service,
      walletAccountService: wallet_account_service.Service,
      transactionService: transaction_service.Service,
      networkService: network_service.Service,
      chatService: chat_service.Service,
      tokenService: token_service.Service
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.walletAccountService = walletAccountService
    result.transactionService = transactionService
    result.networkService = networkService
    result.tokenService = tokenService
    result.chatService = chatService
    result.marketStickerPacks = initTable[string, StickerPackDto]()
    result.recentStickers = @[]
    result.installedStickerPacks = initTable[string, StickerPackDto]()

  proc getInstalledStickerPacks*(self: Service): Table[string, StickerPackDto] =
    return self.installedStickerPacks

  proc getStickerMarketAddress*(self: Service): string =
    try:
      let chainId = self.networkService.getNetworkForStickers().chainId
      let response = status_stickers.stickerMarketAddress(chainId)
      return response.result.getStr()
    except RpcException:
      error "Error obtaining sticker market address", message = getCurrentExceptionMsg()

  proc confirmTransaction(self: Service, trxType: string, packID: string, transactionHash: string) =
    try:
      if not self.marketStickerPacks.contains(packID):
        let pendingStickerPacksResponse = status_stickers.pending()
        for (pID, stickerPackJson) in pendingStickerPacksResponse.result.pairs():
          if packID != pID: continue
          self.marketStickerPacks[packID] = stickerPackJson.toStickerPackDto()
          self.marketStickerPacks[packID].status = StickerPackStatus.Purchased
          self.events.emit(SIGNAL_STICKER_PACK_LOADED, StickerPackLoadedArgs(
                  stickerPack: self.marketStickerPacks[packID],
                  isInstalled: false,
                  isBought: true,
                  isPending: false
                ))

      discard status_stickers.removePending(packID)
      self.marketStickerPacks[packID].status = StickerPackStatus.Purchased
      let data = StickerTransactionArgs(transactionHash: transactionHash, packID: packID, transactionType: $trxType)
      self.events.emit(SIGNAL_STICKER_TRANSACTION_CONFIRMED, data)
    except:
      error "Error confirming sticker transaction", message = getCurrentExceptionMsg()

  proc revertTransaction(self: Service, trxType: string, packID: string, transactionHash: string) =
    try:
      if not self.marketStickerPacks.contains(packID):
        let pendingStickerPacksResponse = status_stickers.pending()
        for (pID, stickerPackJson) in pendingStickerPacksResponse.result.pairs():
          if packID != pID: continue
          self.marketStickerPacks[packID] = stickerPackJson.toStickerPackDto()
          self.marketStickerPacks[packID].status = StickerPackStatus.Available
          self.events.emit(SIGNAL_STICKER_PACK_LOADED, StickerPackLoadedArgs(
                  stickerPack: self.marketStickerPacks[packID],
                  isInstalled: false,
                  isBought: false,
                  isPending: false
                ))
      discard status_stickers.removePending(packID)
      self.marketStickerPacks[packID].status = StickerPackStatus.Available
      let data = StickerTransactionArgs(transactionHash: transactionHash, packID: packID, transactionType: $trxType)
      self.events.emit(SIGNAL_STICKER_TRANSACTION_REVERTED, data)
    except:
      error "Error reverting sticker transaction", message = getCurrentExceptionMsg()

  proc init*(self: Service) =
    self.events.on(PendingTransactionTypeDto.BuyStickerPack.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      if receivedData.success:
        self.confirmTransaction($PendingTransactionTypeDto.BuyStickerPack, receivedData.data, receivedData.transactionHash)
      else:
        self.revertTransaction($PendingTransactionTypeDto.BuyStickerPack, receivedData.data, receivedData.transactionHash)

  proc getStatusToken*(self: Service): TokenDto =
    let networkDto = self.networkService.getNetworkForStickers()
    return self.tokenService.findTokenBySymbol(networkDto.chainId, networkDto.sntSymbol())

  proc setMarketStickerPacks*(self: Service, strickersJSON: string) {.slot.} =
    let stickersResult = Json.decode(strickersJSON, tuple[packs: seq[StickerPackDto], error: string])

    if stickersResult.error != "":
      self.events.emit(SIGNAL_ALL_STICKER_PACKS_LOAD_FAILED, Args())
      return

    let availableStickers = stickersResult.packs

    for stickerPack in availableStickers:
      if self.marketStickerPacks.contains(stickerPack.id): continue

      self.marketStickerPacks[stickerPack.id] = stickerPack
      self.events.emit(SIGNAL_STICKER_PACK_LOADED, StickerPackLoadedArgs(
        stickerPack: stickerPack,
        isInstalled: false,
        isBought: stickerPack.status == StickerPackStatus.Purchased,
        isPending: false
      ))

    let pendingStickerPacksResponse = status_stickers.pending()
    for (packID, stickerPackJson) in pendingStickerPacksResponse.result.pairs():
        if self.marketStickerPacks.contains(packID): continue
        self.marketStickerPacks[packID] = stickerPackJson.toStickerPackDto()
        self.events.emit(SIGNAL_STICKER_PACK_LOADED, StickerPackLoadedArgs(
          stickerPack: self.marketStickerPacks[packID],
          isInstalled: false,
          isBought: false,
          isPending: true
        ))
    self.events.emit(SIGNAL_ALL_STICKER_PACKS_LOADED, Args())

  proc obtainMarketStickerPacks*(self: Service) =
    let chainId = self.networkService.getNetworkForStickers().chainId

    let arg = ObtainMarketStickerPacksTaskArg(
      tptr: cast[ByteAddress](obtainMarketStickerPacksTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setMarketStickerPacks",
      chainId: chainId,
    )
    self.threadpool.start(arg)

  proc setGasEstimate*(self: Service, estimateJson: string) {.slot.} =
    let estimateResult = Json.decode(estimateJson, tuple[estimate: int, uuid: string])
    self.events.emit(SIGNAL_STICKER_GAS_ESTIMATED, StickerGasEstimatedArgs(estimate: estimateResult.estimate, uuid: estimateResult.uuid))

  # the [T] here is annoying but the QtObject template only allows for one type
  # definition so we'll need to setup the type, task, and helper outside of body
  # passed to `QtObject:`
  proc estimate*(self: Service, packId: string, address: string, price: string, uuid: string) =
    let chainId = self.networkService.getNetworkForStickers().chainId

    let arg = EstimateTaskArg(
      tptr: cast[ByteAddress](estimateTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setGasEstimate",
      packId: packId,
      uuid: uuid,
      chainId: chainId,
      fromAddress: address
    )
    self.threadpool.start(arg)

  proc addStickerToRecent*(self: Service, sticker: StickerDto, save: bool = false) =
    try:
      discard status_stickers.addRecent(sticker.packId, sticker.hash)
    except RpcException:
      error "Error adding recent sticker", message = getCurrentExceptionMsg()

  proc getPackIdForSticker*(packs: Table[string, StickerPackDto], hash: string): string =
    for packId, pack in packs.pairs:
      if pack.stickers.any(proc(sticker: StickerDto): bool = return sticker.hash == hash):
        return packId
    return "0"

  proc getRecentStickers*(self: Service): seq[StickerDto] =
    try:
      let recentResponse = status_stickers.recent()
      for stickerJson in recentResponse.result:
        result = stickerJson.toStickerDto() & result
    except RpcException:
      error "Error getting recent stickers", message = getCurrentExceptionMsg()

  proc asyncLoadRecentStickers*(self: Service) =
    self.events.emit(SIGNAL_LOAD_RECENT_STICKERS_STARTED, Args())
    try:
      let arg = AsyncGetRecentStickersTaskArg(
        tptr: cast[ByteAddress](asyncGetRecentStickersTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onAsyncGetRecentStickersDone"
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading recent stickers", msg = e.msg

  proc onAsyncGetRecentStickersDone*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson
      if (rpcResponseObj{"error"}.kind != JNull):
        let error = Json.decode($rpcResponseObj["error"], RpcError)
        error "error loading recent stickers", msg = error.message
        return

      let recentStickers = map(rpcResponseObj{"result"}.getElems(), toStickerDto)
      self.events.emit(SIGNAL_LOAD_RECENT_STICKERS_DONE, StickersArgs(stickers: recentStickers))
    except Exception as e:
      let errMsg = e.msg
      error "error: ", errMsg
      self.events.emit(SIGNAL_LOAD_RECENT_STICKERS_FAILED, Args())

  proc asyncLoadInstalledStickerPacks*(self: Service) =
    self.events.emit(SIGNAL_LOAD_INSTALLED_STICKER_PACKS_STARTED, Args())
    try:
      let arg = AsyncGetInstalledStickerPacksTaskArg(
        tptr: cast[ByteAddress](asyncGetInstalledStickerPacksTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onAsyncGetInstalledStickerPacksDone"
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading installed sticker packs", msg = e.msg

  proc onAsyncGetInstalledStickerPacksDone*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson
      if (rpcResponseObj{"error"}.kind != JNull):
        let error = Json.decode($rpcResponseObj["error"], RpcError)
        error "error loading installed sticker packs", msg = error.message
        return

      for (packID, stickerPackJson) in rpcResponseObj{"result"}.pairs():
        self.installedStickerPacks[packID] = stickerPackJson.toStickerPackDto()
      self.events.emit(SIGNAL_LOAD_INSTALLED_STICKER_PACKS_DONE, StickerPacksArgs(packs: self.installedStickerPacks))
    except Exception as e:
      let errMsg = e.msg
      error "error: ", errMsg
      self.events.emit(SIGNAL_LOAD_INSTALLED_STICKER_PACKS_FAILED, Args())

  proc getNumInstalledStickerPacks*(self: Service): int =
    try:
      let installedResponse = status_stickers.installed()
      return installedResponse.result.len
    except RpcException:
      error "Error getting installed stickers number", message = getCurrentExceptionMsg()
    return 0

  proc installStickerPack*(self: Service, packId: string) =
    let arg = InstallStickerPackTaskArg(
      tptr: cast[ByteAddress](installStickerPackTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onStickerPackInstalled",
      chainId: self.networkService.getNetworkForStickers().chainId,
      packId: packId,
    )
    self.threadpool.start(arg)

  proc onStickerPackInstalled*(self: Service, installedPackJson: string) {.slot.} =
    let installedPack = Json.decode(installedPackJson, tuple[packId: string, installed: bool])
    if installedPack.installed:
      if self.marketStickerPacks.hasKey(installedPack.packId):
        self.marketStickerPacks[installedPack.packId].status = StickerPackStatus.Installed
      self.events.emit(SIGNAL_STICKER_PACK_INSTALLED, StickerPackInstalledArgs(
        packId: installedPack.packId
      ))
    else:
      error "Sticker pack did not get installed", packId = installedPack.packId

  proc uninstallStickerPack*(self: Service, packId: string) =
    try:
      discard status_stickers.uninstall(packId)
    except RpcException:
      error "Error removing installed sticker", message = getCurrentExceptionMsg()

  proc sendSticker*(
      self: Service,
      chatId: string,
      replyTo: string,
      sticker: StickerDto,
      preferredUsername: string) =
    let response = status_chat.sendChatMessage(
        chatId,
        "Update to latest version to see a nice sticker here!",
        replyTo,
        ContentType.Sticker.int,
        preferredUsername,
        linkPreviews = @[],
        communityId = "", # communityId is not necessary when sending a sticker
        sticker.hash,
        sticker.packId)
    discard self.chatService.processMessageUpdateAfterSend(response)
    self.addStickerToRecent(sticker)

  proc removeRecentStickers*(self: Service, packId: string) =
    self.recentStickers.keepItIf(it.packId != packId)

  proc clearRecentStickers*(self: Service) =
    try:
      discard status_stickers.clearRecentStickers()
    except RpcException:
      error "Error removing recent stickers", message = getCurrentExceptionMsg()

  proc getSNTBalance*(self: Service): string =
    let token = self.getStatusToken()
    let account = self.walletAccountService.getWalletAccount(0).address
    let network = self.networkService.getNetworkForStickers()

    let info = getTokenBalanceForAccount(network.chainId, account, token.address)
    if info.isNone:
      return "0"
    return ens_utils.hex2Token(info.get().rawBalance.toString(16), token.decimals)

  # proc prepareTxForBuyingStickers*(self: Service, chainId: int, packId: string, address: string): JsonNode =
  proc prepareTxForBuyingStickers*(self: Service, chainId: int, packId: string, address: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string,
    maxFeePerGas: string, eip1559Enabled: bool): JsonNode =
    try:
      var prepareTxResponse = status_stickers.prepareTxForBuyingStickers(chainId, address, packId)
      if not prepareTxResponse.error.isNil:
        error "error occurred", procName="prepareTxForBuyingStickers", msg = prepareTxResponse.error.message
        return

      prepareTxResponse.result["gas"] = %* (if gas.isEmptyOrWhitespace: Quantity.none else: Quantity(cast[uint64](parseFloat(gas).toUInt64)).some)
      if eip1559Enabled:
        let maxPriorityFeePerGasFinal = if maxPriorityFeePerGas.isEmptyOrWhitespace: Uint256.none else: gwei2Wei(parseFloat(maxPriorityFeePerGas)).some
        let maxFeePerGasFinal = if maxFeePerGas.isEmptyOrWhitespace: Uint256.none else: gwei2Wei(parseFloat(maxFeePerGas)).some
        prepareTxResponse.result["maxPriorityFeePerGas"] = %* ("0x" & maxPriorityFeePerGasFinal.unsafeGet.toHex)
        prepareTxResponse.result["maxFeePerGas"] = %* ("0x" & maxFeePerGasFinal.unsafeGet.toHex)
      else:
        let gasPriceFinal = if gasPrice.isEmptyOrWhitespace: int.none else: gwei2Wei(parseFloat(gasPrice)).truncate(int).some
        prepareTxResponse.result["gasPrice"] = %* ("0x" & gasPriceFinal.unsafeGet.toHex.stripLeadingZeros)

      var buildTxResponse: JsonNode
      let err = status_wallet.buildTransaction(buildTxResponse, chainId, $prepareTxResponse.result)
      if err.len > 0:
        error "error occurred", procName="prepareTxForBuyingStickers", msg = err
        return

      return buildTxResponse
    except Exception as e:
      error "error occurred", procName="prepareTxForBuyingStickers", msg = e.msg

  proc signBuyingStickersTxLocally*(self: Service, data, account, hashedPasssword: string): string =
    try:
      var response: JsonNode
      let err = status_wallet.signMessage(response, data, account, hashedPasssword)
      if err.len > 0 or response.isNil:
        error "error occurred", procName="signBuyingStickersTxLocally", msg = err
        return
      return response.getStr()
    except Exception as e:
      error "error occurred", procName="signBuyingStickersTxLocally", msg = e.msg

  proc sendBuyingStickersTxWithSignatureAndWatch*(self: Service, chainId: int, txData: JsonNode, packId: string,
    signature: string): StickerBuyResultArgs =
    result = StickerBuyResultArgs(chainId: chainId)
    try:
      if txData.isNil:
        result.error = "txData is nil"
        error "error occurred", procName="sendBuyingStickersTxWithSignatureAndWatch", msg = result.error
        return
      if not txData.hasKey("from") or txData["from"].getStr().len == 0:
        result.error = "from address is empty"
        error "error occurred", procName="sendBuyingStickersTxWithSignatureAndWatch", msg = result.error
        return
      if not txData.hasKey("to") or txData["to"].getStr().len == 0:
        result.error = "to address is empty"
        error "error occurred", procName="sendBuyingStickersTxWithSignatureAndWatch", msg = result.error
        return

      var finalSignature = signature
      if finalSignature.startsWith("0x"):
        finalSignature = finalSignature[2..^1]

      var txResponse: JsonNode
      let err = status_wallet.sendTransactionWithSignature(txResponse, chainId, $PendingTransactionTypeDto.BuyStickerPack,
        $txData, finalSignature)
      if err.len > 0 or txResponse.isNil:
        result.error = err
        error "error occurred", procName="sendBuyingStickersTxWithSignatureAndWatch", msg = result.error
        return

      let
        transactionHash = txResponse.getStr()
        fromAddress = txData["from"].getStr()
        toAddress = txData["to"].getStr()

      let addPendingResponse = status_stickers.addPending(chainId, packId)
      if not addPendingResponse.error.isNil:
        result.error = addPendingResponse.error.message
        error "error occurred", procName="sendBuyingStickersTxWithSignatureAndWatch", msg = result.error
        return

      let sntContract = self.getStatusToken()
      self.transactionService.watchTransaction(
        transactionHash,
        fromAddress,
        toAddress,
        $PendingTransactionTypeDto.BuyStickerPack,
        packId,
        chainId,
      )

      result.txHash = transactionHash
    except Exception as e:
      result.error = e.msg
      error "error occurred", procName="sendBuyingStickersTxWithSignatureAndWatch", msg = result.error
