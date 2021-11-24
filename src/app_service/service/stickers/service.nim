import NimQml, Tables, json, sequtils, chronicles, strutils, atomics, sets, strutils, tables, stint
import status/types/[sticker, network_type, setting, transaction, network]

import httpclient
import eventemitter
import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]

import
  web3/ethtypes, web3/conversions, stew/byteutils, nimcrypto, json_serialization, chronicles
import json, tables, json_serialization

import status/statusgo_backend_new/stickers as status_stickers
import status/statusgo_backend_new/transactions as transactions
import status/statusgo_backend_new/response_type
import status/statusgo_backend_new/eth
import ./dto/stickers
import ../eth/service as eth_service
import ../settings/service as settings_service
import ../wallet_account/service as wallet_account_service
import ../transaction/service as transaction_service
import ../network/service as network_service
import ../chat/service as chat_service

import ../eth/utils as status_utils

import ../eth/dto/edn_dto as edn_helper

# TODO Remove those imports once chat is refactored
import status/statusgo_backend/chat as status_chat

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

# Signals which may be emitted by this service:
const SIGNAL_STICKER_PACK_LOADED* = "SIGNAL_STICKER_PACK_LOADED"
const SIGNAL_ALL_STICKER_PACKS_LOADED* = "SIGNAL_ALL_STICKER_PACKS_LOADED"
const SIGNAL_STICKER_GAS_ESTIMATED* = "SIGNAL_STICKER_GAS_ESTIMATED"

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    availableStickerPacks*: Table[int, StickerPackDto]
    purchasedStickerPacks*: seq[int]
    recentStickers*: seq[StickerDto]
    events: EventEmitter
    ethService: eth_service.Service
    settingsService: settings_service.Service
    walletAccountService: wallet_account_service.Service
    transactionService: transaction_service.Service
    networkService: network_service.Service
    chatService: chat_service.Service

  # Forward declaration
  proc obtainAvailableStickerPacks*(self: Service)

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      ethService: eth_service.Service,
      settingsService: settings_service.Service,
      walletAccountService: wallet_account_service.Service,
      transactionService: transaction_service.Service,
      networkService: network_service.Service,
      chatService: chat_service.Service
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.ethService = ethService
    result.settingsService = settingsService
    result.walletAccountService = walletAccountService
    result.transactionService = transactionService
    result.networkService = networkService
    result.chatService = chatService
    result.availableStickerPacks = initTable[int, StickerPackDto]()
    result.purchasedStickerPacks = @[]
    result.recentStickers = @[]

  proc init*(self: Service) =
    self.obtainAvailableStickerPacks()
    # TODO redo the connect check when the network is refactored
    # if self.status.network.isConnected:
    #   self.obtainAvailableStickerPacks()
    # else:
    #   let installedStickerPacks = self.getInstalledStickerPacks()
    #   self.delegate.populateInstalledStickerPacks(installedStickerPacks) # use emit instead
    
  proc getInstalledStickerPacks*(self: Service): Table[int, StickerPackDto] =
    self.settingsService.getInstalledStickerPacks()

  proc buildTransaction(
      self: Service,
      packId: Uint256,
      address: Address,
      price: Uint256,
      approveAndCall: var ApproveAndCall[100],
      sntContract: var Erc20ContractDto,
      gas = "",
      gasPrice = "",
      isEIP1559Enabled = false,
      maxPriorityFeePerGas = "",
      maxFeePerGas = ""
      ): TransactionDataDto =
    let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
    let network = self.networkService.getNetwork(networkType)
    sntContract = self.eth_service.findErc20Contract(network.chainId, network.sntSymbol())
    let
      stickerMktContract = self.eth_service.findContract(network.chainId, "sticker-market")
      buyToken = BuyToken(packId: packId, address: address, price: price)
      buyTxAbiEncoded = stickerMktContract.methods["buyToken"].encodeAbi(buyToken)
    approveAndCall = ApproveAndCall[100](to: stickerMktContract.address, value: price, data: DynamicBytes[100].fromHex(buyTxAbiEncoded))
    self.eth_service.buildTokenTransaction(address, sntContract.address, gas, gasPrice, isEIP1559Enabled, maxPriorityFeePerGas, maxFeePerGas)

  proc buyPack*(self: Service, packId: int, address, price, gas, gasPrice: string, isEIP1559Enabled: bool, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, success: var bool): string =
    var
      sntContract: Erc20ContractDto
      approveAndCall: ApproveAndCall[100]
      tx = self.buildTransaction(
        packId.u256,
        parseAddress(address),
        status_utils.eth2Wei(parseFloat(price), 18), # SNT
        approveAndCall,
        sntContract,
        gas,
        gasPrice,
        isEIP1559Enabled,
        maxPriorityFeePerGas,
        maxFeePerGas
      )

    result = sntContract.methods["approveAndCall"].send(tx, approveAndCall, password, success)
    if success:
      discard transactions.trackPendingTransaction(
        result,
        address,
        $sntContract.address,
        transaction.PendingTransactionType.BuyStickerPack,
        $packId
      )

  proc buy*(self: Service, packId: int, address: string, price: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): tuple[response: string, success: bool] =
    let eip1559Enabled = self.settingsService.isEIP1559Enabled()

    try:
      status_utils.validateTransactionInput(address, address, "", price, gas, gasPrice, "", eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, "ok")
    except Exception as e:
      error "Error buying sticker pack", msg = e.msg
      return (response: "", success: false)
    
    var success: bool
    let response = self.buyPack(packId, address, price, gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, password, success)

    result = (response: $response, success: success)
  
  proc getPackIdFromTokenId*(self: Service, chainId: int, tokenId: Stuint[256]): RpcResponse[JsonNode] =
    let
      contract = self.eth_service.findContract(chainId, "sticker-pack")
      tokenPackId = TokenPackId(tokenId: tokenId)

    if contract == nil:
      return
    
    let abi = contract.methods["tokenPackId"].encodeAbi(tokenPackId)

    return status_stickers.getPackIdFromTokenId($contract.address, abi)

  proc tokenOfOwnerByIndex*(self: Service, chainId: int, address: Address, idx: Stuint[256]): RpcResponse[JsonNode] =
    let
      contract = self.eth_service.findContract(chainId, "sticker-pack")
      
    if contract == nil:
      return
    
    let
      tokenOfOwnerByIndex = TokenOfOwnerByIndex(address: address, index: idx)
      data = contract.methods["tokenOfOwnerByIndex"].encodeAbi(tokenOfOwnerByIndex)
    
    status_stickers.tokenOfOwnerByIndex($contract.address, data)

  proc getBalance*(self: Service, chainId: int, address: Address): RpcResponse[JsonNode] =
    let contract = self.eth_service.findContract(chainId, "sticker-pack")
    if contract == nil: return

    let balanceOf = BalanceOf(address: address)
    let data = contract.methods["balanceOf"].encodeAbi(balanceOf)

    return status_stickers.getBalance($contract.address, data)

  proc getPurchasedStickerPacks*(self: Service, address: string): seq[int] =
    try:
      let addressObj = parseAddress(address)


      let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
      let network = self.networkService.getNetwork(networkType)
      let balanceRpcResponse = self.getBalance(network.chainId, addressObj)

      var balance = 0
      if $balanceRpcResponse.result != "0x":
        balance = parseHexInt(balanceRpcResponse.result.getStr)

      var tokenIds: seq[int] = @[]

      for it in toSeq[0..<balance]:
        let response = self.tokenOfOwnerByIndex(network.chainId, addressObj, it.u256)
        var tokenId = 0
        if $response.result != "0x":
          tokenId = parseHexInt(response.result.getStr)
        tokenIds.add(tokenId)

      var purchasedPackIds: seq[int] = @[]
      for tokenId in tokenIds:
        let response = self.getPackIdFromTokenId(network.chainId, tokenId.u256)
        var packId = 0
        if $response.result != "0x":
          packId = parseHexInt(response.result.getStr)
        purchasedPackIds.add(packId) 

      self.purchasedStickerPacks = self.purchasedStickerPacks.concat(purchasedPackIds)
      self.purchasedStickerPacks = self.purchasedStickerPacks.deduplicate()
      result = self.purchasedStickerPacks
    except RpcException:
      error "Error getting purchased sticker packs", message = getCurrentExceptionMsg()
      result = @[]

  proc setAvailableStickerPacks*(self: Service, availableStickersJSON: string) {.slot.} =
    let
      accounts = self.walletAccountService.getWalletAccounts() # TODO: make generic
      installedStickerPacks = self.getInstalledStickerPacks()
    var
      purchasedStickerPacks: seq[int]
    for account in accounts:
      purchasedStickerPacks = self.getPurchasedStickerPacks(account.address)
    let availableStickers = JSON.decode($availableStickersJSON, seq[StickerPackDto])

    let pendingTransactions = self.transactionService.getPendingTransactions()
    var pendingStickerPacks = initHashSet[int]()
    if (pendingTransactions != ""):
      for trx in pendingTransactions.parseJson{"result"}.getElems():
        if trx["type"].getStr == $PendingTransactionType.BuyStickerPack:
          pendingStickerPacks.incl(trx["additionalData"].getStr.parseInt)

    for stickerPack in availableStickers:
      let isInstalled = installedStickerPacks.hasKey(stickerPack.id)
      let isBought = purchasedStickerPacks.contains(stickerPack.id)
      let isPending = pendingStickerPacks.contains(stickerPack.id) and not isBought
      self.availableStickerPacks[stickerPack.id] = stickerPack
      self.events.emit(SIGNAL_STICKER_PACK_LOADED, StickerPackLoadedArgs(
        stickerPack: stickerPack,
        isInstalled: isInstalled,
        isBought: isBought,
        isPending: isPending
      )) 
    self.events.emit(SIGNAL_ALL_STICKER_PACKS_LOADED, Args())

  proc obtainAvailableStickerPacks*(self: Service) =
    let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
    let network = self.networkService.getNetwork(networkType)
    let contract = self.eth_service.findContract(network.chainId, "stickers")
    if (contract == nil):
      return

    let arg = ObtainAvailableStickerPacksTaskArg(
      tptr: cast[ByteAddress](obtainAvailableStickerPacksTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setAvailableStickerPacks",
      contract: contract,
      packCountMethod: contract.methods["packCount"],
      getPackDataMethod: contract.methods["getPackData"],
      running: cast[ByteAddress](addr self.threadpool.running)
    )
    self.threadpool.start(arg)

  proc setGasEstimate*(self: Service, estimateJson: string) {.slot.} =
    let estimateResult = Json.decode(estimateJson, tuple[estimate: int, uuid: string])
    self.events.emit(SIGNAL_STICKER_GAS_ESTIMATED, StickerGasEstimatedArgs(estimate: estimateResult.estimate, uuid: estimateResult.uuid))

  # the [T] here is annoying but the QtObject template only allows for one type
  # definition so we'll need to setup the type, task, and helper outside of body
  # passed to `QtObject:`
  proc estimate*(self: Service, packId: int, address: string, price: string, uuid: string) =
    var
      approveAndCall: ApproveAndCall[100]
      networkType = self.settingsService.getCurrentNetwork().toNetworkType()
      network = self.networkService.getNetwork(networkType)
      sntContract = self.eth_service.findErc20Contract(network.chainId, network.sntSymbol())
      tx = self.buildTransaction(
        packId.u256,
        status_utils.parseAddress(address),
        status_utils.eth2Wei(parseFloat(price), sntContract.decimals),
        approveAndCall,
        sntContract
      )

    var estimateData = sntContract.methods["approveAndCall"]
      .getEstimateGasData(tx, approveAndCall)

    let arg = EstimateTaskArg(
      tptr: cast[ByteAddress](estimateTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setGasEstimate",
      uuid: uuid,
      data: estimateData
    )
    self.threadpool.start(arg)

  proc addStickerToRecent*(self: Service, sticker: StickerDto, save: bool = false) =
    self.recentStickers.insert(sticker, 0)
    self.recentStickers = self.recentStickers.deduplicate()
    if self.recentStickers.len > 24:
      self.recentStickers = self.recentStickers[0..23] # take top 24 most recent
    if save:
      discard self.settingsService.saveRecentStickers(self.recentStickers)

  proc getPackIdForSticker*(packs: Table[int, StickerPackDto], hash: string): int =
    for packId, pack in packs.pairs:
      if pack.stickers.any(proc(sticker: StickerDto): bool = return sticker.hash == hash):
        return packId
    return 0

  proc getRecentStickers*(self: Service): seq[StickerDto] =
    # TODO: this should be a custom `readValue` implementation of nim-json-serialization
    let recentStickers = self.settingsService.getRecentStickers()
    let installedStickers = self.getInstalledStickerPacks()
    var stickers = newSeq[StickerDto]()
    for hash in recentStickers:
      # pack id is not returned from status-go settings, populate here
      let packId = getPackIdForSticker(installedStickers, $hash)
      # .insert instead of .add to effectively reverse the order stickers because
      # stickers are re-reversed when added to the view due to the nature of
      # inserting recent stickers at the front of the list
      stickers.insert(StickerDto(hash: $hash, packId: packId), 0)

    for sticker in stickers:
      self.addStickerToRecent(sticker)

    result = self.recentStickers
      
  proc getNumInstalledStickerPacks*(self: Service): int =
    return self.settingsService.getInstalledStickerPacks().len

  proc installStickerPack*(self: Service, packId: int) =
    if not self.availableStickerPacks.hasKey(packId):
      return
    let pack = self.availableStickerPacks[packId]
    var installedStickerPacks = self.settingsService.getInstalledStickerPacks()
    installedStickerPacks[packId] = pack

    discard self.settingsService.saveRecentStickers(installedStickerPacks)

  proc uninstallStickerPack*(self: Service, packId: int) =
    var installedStickerPacks = self.settingsService.getInstalledStickerPacks()
    if not installedStickerPacks.hasKey(packId):
      return
    installedStickerPacks.del(packId)

    discard self.settingsService.saveRecentStickers(installedStickerPacks)

  proc sendSticker*(self: Service, chatId: string, replyTo: string, sticker: StickerDto) =
    let stickerToSend = Sticker(
        hash: sticker.hash,
        packId: sticker.packId
      )
    # TODO change this to the new chat service call once it is available
    var response = status_chat.sendStickerMessage(chatId, replyTo, stickerToSend)
    self.addStickerToRecent(sticker, true)
    var (chats, messages) = self.chatService.parseChatResponse(response)
    # TODO change this event when the chat is refactored
    self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats))

  proc removeRecentStickers*(self: Service, packId: int) =
    self.recentStickers.keepItIf(it.packId != packId)
    discard self.settingsService.saveRecentStickers(self.recentStickers)
