import # global deps
  tables, strutils, sequtils, sugar

import # project deps
  chronicles, eth/common/eth_types, eventemitter
from eth/common/utils import parseAddress

import # local deps
  libstatus/types, libstatus/eth/contracts as status_contracts,
  libstatus/stickers as status_stickers, transactions
from libstatus/utils as libstatus_utils import eth2Wei, gwei2Wei, toUInt64

logScope:
  topics = "stickers-model"

type
    StickersModel* = ref object
      events*: EventEmitter
      recentStickers*: seq[Sticker]
      availableStickerPacks*: Table[int, StickerPack]
      installedStickerPacks*: Table[int, StickerPack]
      purchasedStickerPacks*: seq[int]

    StickerArgs* = ref object of Args
      sticker*: Sticker
      save*: bool

# forward declaration
proc addStickerToRecent*(self: StickersModel, sticker: Sticker, save: bool = false)

proc newStickersModel*(events: EventEmitter): StickersModel =
  result = StickersModel()
  result.events = events
  result.recentStickers = @[]
  result.availableStickerPacks = initTable[int, StickerPack]()
  result.installedStickerPacks = initTable[int, StickerPack]()
  result.purchasedStickerPacks = @[]

proc init*(self: StickersModel) =
  self.events.on("stickerSent") do(e: Args):
    var evArgs = StickerArgs(e)
    self.addStickerToRecent(evArgs.sticker, evArgs.save)

proc buildTransaction(self: StickersModel, packId: Uint256, address: EthAddress, price: Uint256, approveAndCall: var ApproveAndCall[100], sntContract: var Contract, gas = "", gasPrice = ""): EthSend =
  sntContract = status_contracts.getContract("snt")
  let
    stickerMktContract = status_contracts.getContract("sticker-market")
    buyToken = BuyToken(packId: packId, address: address, price: price)
    buyTxAbiEncoded = stickerMktContract.methods["buyToken"].encodeAbi(buyToken)
  approveAndCall = ApproveAndCall[100](to: stickerMktContract.address, value: price, data: DynamicBytes[100].fromHex(buyTxAbiEncoded))
  transactions.buildTokenTransaction(address, sntContract.address, gas, gasPrice)

proc estimateGas*(self: StickersModel, packId: int, address: string, price: string): int =
  var
    approveAndCall: ApproveAndCall[100]
    sntContract = status_contracts.getContract("snt")
    tx = self.buildTransaction(
      packId.u256,
      parseAddress(address),
      eth2Wei(parseFloat(price), 18), # SNT
      approveAndCall,
      sntContract
    )
  try:
    let response = sntContract.methods["approveAndCall"].estimateGas(tx, approveAndCall)
    result = fromHex[int](response)
  except RpcException as e:
    raise

proc buyPack*(self: StickersModel, packId: int, address, price, gas, gasPrice, password: string): string =
  var
    sntContract: Contract
    approveAndCall: ApproveAndCall[100]
    tx = self.buildTransaction(
      packId.u256,
      parseAddress(address),
      eth2Wei(parseFloat(price), 18), # SNT
      approveAndCall,
      sntContract,
      gas,
      gasPrice
    )
  try:
    result = sntContract.methods["approveAndCall"].send(tx, approveAndCall, password)
  except RpcException as e:
    raise

proc getStickerMarketAddress*(self: StickersModel): EthAddress =
  result = status_contracts.getContract("sticker-market").address

proc getPurchasedStickerPacks*(self: StickersModel, address: EthAddress): seq[int] =
  try:
    let
      balance = status_stickers.getBalance(address)
      tokenIds = toSeq[0..<balance].map(idx => status_stickers.tokenOfOwnerByIndex(address, idx.u256))
      purchasedPackIds = tokenIds.map(tokenId => status_stickers.getPackIdFromTokenId(tokenId.u256))
    self.purchasedStickerPacks = self.purchasedStickerPacks.concat(purchasedPackIds)
    result = self.purchasedStickerPacks
  except RpcException:
    error "Error getting purchased sticker packs", message = getCurrentExceptionMsg()
    result = @[]

proc getInstalledStickerPacks*(self: StickersModel): Table[int, StickerPack] =
  if self.installedStickerPacks != initTable[int, StickerPack]():
    return self.installedStickerPacks

  self.installedStickerPacks = status_stickers.getInstalledStickerPacks()
  result = self.installedStickerPacks

proc getAvailableStickerPacks*(self: StickersModel): Table[int, StickerPack] = status_stickers.getAvailableStickerPacks()

proc getRecentStickers*(self: StickersModel): seq[Sticker] =
  result = status_stickers.getRecentStickers()

proc installStickerPack*(self: StickersModel, packId: int) =
  if not self.availableStickerPacks.hasKey(packId):
    return
  let pack = self.availableStickerPacks[packId]
  self.installedStickerPacks[packId] = pack
  status_stickers.saveInstalledStickerPacks(self.installedStickerPacks)

proc removeRecentStickers*(self: StickersModel, packId: int) =
  self.recentStickers.keepItIf(it.packId != packId)
  status_stickers.saveRecentStickers(self.recentStickers)

proc uninstallStickerPack*(self: StickersModel, packId: int) =
  if not self.installedStickerPacks.hasKey(packId):
    return
  let pack = self.availableStickerPacks[packId]
  self.installedStickerPacks.del(packId)
  status_stickers.saveInstalledStickerPacks(self.installedStickerPacks)

proc addStickerToRecent*(self: StickersModel, sticker: Sticker, save: bool = false) =
  self.recentStickers.insert(sticker, 0)
  self.recentStickers = self.recentStickers.deduplicate()
  if self.recentStickers.len > 24:
    self.recentStickers = self.recentStickers[0..23] # take top 24 most recent
  if save:
    status_stickers.saveRecentStickers(self.recentStickers)