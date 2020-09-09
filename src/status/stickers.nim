import
  tables, strutils, sequtils, sugar

import
  chronicles, eth/common/eth_types, eventemitter

from eth/common/utils import parseAddress

import
  libstatus/types, libstatus/stickers as status_stickers,
  libstatus/contracts as status_contracts

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

# TODO: Replace this with a more generalised way of estimating gas so can be used for token transfers
proc buyPackGasEstimate*(self: StickersModel, packId: int, address: string, price: string): string =
  let
    priceTyped = eth2Wei(parseFloat(price), 18) # SNT
    hexGas = status_stickers.buyPackGasEstimate(packId.u256, parseAddress(address), priceTyped)
  result = $fromHex[int](hexGas)

proc getStickerMarketAddress*(self: StickersModel): EthAddress =
  result = status_contracts.getContract("sticker-market").address

proc buyStickerPack*(self: StickersModel, packId: int, address, price, gas, gasPrice, password: string): RpcResponse =
  try:
    let
      addressTyped = parseAddress(address)
      priceTyped = eth2Wei(parseFloat(price), 18) # SNT
      gasTyped = cast[uint64](parseFloat(gas).toUInt64)
      gasPriceTyped = gwei2Wei(parseFloat(gasPrice)).truncate(int)
    result = status_stickers.buyPack(packId.u256, addressTyped, priceTyped, gasTyped, gasPriceTyped, password)
  except RpcException as e:
    raise

proc getPurchasedStickerPacks*(self: StickersModel, address: EthAddress): seq[int] =
  if self.purchasedStickerPacks != @[]:
    return self.purchasedStickerPacks

  try:
    var
      balance = status_stickers.getBalance(address)
      tokenIds = toSeq[0..<balance].map(idx => status_stickers.tokenOfOwnerByIndex(address, idx.u256))

    self.purchasedStickerPacks = tokenIds.map(tokenId => status_stickers.getPackIdFromTokenId(tokenId.u256))
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