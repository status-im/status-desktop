import NimQml, Tables, json, sequtils, chronicles, strutils, atomics, sets, strutils, tables, stint, strformat

import httpclient

import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]

import web3/ethtypes, web3/conversions, stew/byteutils, nimcrypto, json_serialization, chronicles
import json, tables, json_serialization

import ../../../backend/stickers as status_stickers
import ../../../backend/chat as status_chat
import ../../../backend/response_type
import ../../../backend/eth as status_eth
import ../../../backend/backend as status_go_backend
import ./dto/stickers
import ../ens/utils as ens_utils
import ../token/service as token_service
import ../settings/service as settings_service
import ../eth/dto/transaction
import ../wallet_account/service as wallet_account_service
import ../transaction/service as transaction_service
import ../network/service as network_service
import ../chat/service as chat_service
import ../../common/types
import ../network/types as network_types
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
    revertReason*: string

# Signals which may be emitted by this service:
const SIGNAL_STICKER_PACK_LOADED* = "stickerPackLoaded"
const SIGNAL_ALL_STICKER_PACKS_LOADED* = "allStickerPacksLoaded"
const SIGNAL_STICKER_GAS_ESTIMATED* = "stickerGasEstimated"
const SIGNAL_INSTALLED_STICKER_PACKS_LOADED* = "installedStickerPacksLoaded"
const SIGNAL_STICKER_TRANSACTION_CONFIRMED* = "stickerTransactionConfirmed"
const SIGNAL_STICKER_TRANSACTION_REVERTED* = "stickerTransactionReverted"

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

  proc getInstalledStickerPacks*(self: Service): Table[string, StickerPackDto] =
    result = initTable[string, StickerPackDto]()
    try:
      let installedResponse = status_stickers.installed()
      for (packID, stickerPackJson) in installedResponse.result.pairs():
        result[packID] = stickerPackJson.toStickerPackDto()
    except RpcException:
      error "Error obtaining installed stickers", message = getCurrentExceptionMsg()
    
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

  proc revertTransaction(self: Service, trxType: string, packID: string, transactionHash: string, revertReason: string) =
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
      let data = StickerTransactionArgs(transactionHash: transactionHash, packID: packID, transactionType: $trxType,
        revertReason: revertReason)
      self.events.emit(SIGNAL_STICKER_TRANSACTION_REVERTED, data)
    except:
      error "Error reverting sticker transaction", message = getCurrentExceptionMsg()

  proc init*(self: Service) =
    # TODO redo the connect check when the network is refactored
    # if self.status.network.isConnected:
    self.obtainMarketStickerPacks() # TODO: rename this to obtain sticker market items

    self.events.on(PendingTransactionTypeDto.BuyStickerPack.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      if receivedData.success:
        self.confirmTransaction($PendingTransactionTypeDto.BuyStickerPack, receivedData.data, receivedData.transactionHash)
      else:
        self.revertTransaction($PendingTransactionTypeDto.BuyStickerPack, receivedData.data, receivedData.transactionHash,
        receivedData.revertReason)

  proc buildTransaction*(
    source: Address,
    gas = "",
    gasPrice = "",
    isEIP1559Enabled = false,
    maxPriorityFeePerGas = "",
    maxFeePerGas = "",
  ): TransactionDataDto =
    result = TransactionDataDto(
      source: source,
      value: (0.u256).some,
      gas: (if gas.isEmptyOrWhitespace: Quantity.none else: Quantity(cast[uint64](parseFloat(gas).toUInt64)).some)
    )
    if isEIP1559Enabled:
      result.maxPriorityFeePerGas = if maxFeePerGas.isEmptyOrWhitespace: Uint256.none else: gwei2Wei(parseFloat(maxPriorityFeePerGas)).some
      result.maxFeePerGas = (if maxFeePerGas.isEmptyOrWhitespace: Uint256.none else: gwei2Wei(parseFloat(maxFeePerGas)).some)
    else:
      result.gasPrice = (if gasPrice.isEmptyOrWhitespace: int.none else: gwei2Wei(parseFloat(gasPrice)).truncate(int).some)

  proc getStatusToken*(self: Service): TokenDto =
    let networkDto = self.networkService.getNetworkForStickers()

    return self.tokenService.findTokenBySymbol(networkDto, networkDto.sntSymbol())

  proc buyPack*(self: Service, packId: string, address, gas, gasPrice: string, eip1559Enabled: bool, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, success: var bool): tuple[txHash: string, error: string] =
    let
      chainId = self.networkService.getNetworkForStickers().chainId
      txData = buildTransaction(parseAddress(address), gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)

    try:
      let transactionResponse = status_stickers.buy(chainId, %txData, packId, password)
      let transactionHash = transactionResponse.result.getStr()
      let sntContract = self.getStatusToken()
      self.transactionService.trackPendingTransaction(
        transactionHash,
        address,
        $sntContract.address,
        $PendingTransactionTypeDto.BuyStickerPack,
        packId,
        chainId,
      )
      return (txHash: transactionHash, error: "")
    except ValueError:
      let message = getCurrentExceptionMsg()
      var error = message
      if message.contains("could not decrypt key with given password"):
        error = "could not decrypt key with given password"
      error "Error sending transaction", message
      return (txHash: "", error: error)
    except RpcException:
      error "Error sending transaction", message = getCurrentExceptionMsg()

  proc buy*(self: Service, packId: string, address: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, eip1559Enabled: bool): tuple[response: string, success: bool] =
    try:
      status_utils.validateTransactionInput(address, address, "", "0", gas, gasPrice, "", eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, "ok")
    except Exception as e:
      error "Error buying sticker pack", msg = e.msg
      return (response: e.msg, success: false)

    var success: bool
    var (response, err) = self.buyPack(packId, address, gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, password, success)

    if err != "":
      response = err
      success = false
    else:
      success = true

    result = (response: $response, success: success)

  proc setMarketStickerPacks*(self: Service, availableStickersJSON: string) {.slot.} =
    let availableStickers = JSON.decode($availableStickersJSON, seq[StickerPackDto])

    for stickerPack in availableStickers:
      if self.marketStickerPacks.contains(stickerPack.id): continue
      let isBought = stickerPack.status == StickerPackStatus.Purchased
      self.marketStickerPacks[stickerPack.id] = stickerPack
      self.events.emit(SIGNAL_STICKER_PACK_LOADED, StickerPackLoadedArgs(
        stickerPack: stickerPack,
        isInstalled: false,
        isBought: isBought,
        isPending: false
      ))


    let chainId = self.networkService.getNetworkForStickers().chainId
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
      running: cast[ByteAddress](addr self.threadpool.running)
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
      error "Error obtaining installed stickers", message = getCurrentExceptionMsg()

  proc getNumInstalledStickerPacks*(self: Service): int =
    try:
      let installedResponse = status_stickers.installed()
      return installedResponse.result.len
    except RpcException:
      error "Error obtaining installed stickers", message = getCurrentExceptionMsg()
    return 0

  proc installStickerPack*(self: Service, packId: string) =
    let chainId = self.networkService.getNetworkForStickers().chainId
    if not self.marketStickerPacks.hasKey(packId):
      return
    let installResponse = status_stickers.install(chainId, packId)
    
  proc uninstallStickerPack*(self: Service, packId: string) =
    try:
      let installedResponse = status_stickers.uninstall(packId)
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
        communityId = "", # communityId is not ncessary when sending a sticker
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

    let balances = status_go_backend.getTokensBalancesForChainIDs(@[network.chainId], @[account], @[token.addressAsString()]).result
    return ens_utils.hex2Token(balances{account}{token.addressAsString()}.getStr, token.decimals)