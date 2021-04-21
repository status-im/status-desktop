import NimQml, tables, json, chronicles, sets, strutils
import ../../../status/[status, stickers]
import ../../../status/libstatus/[types, utils]
import ../../../status/libstatus/stickers as status_stickers
import ../../../status/libstatus/wallet as status_wallet
import sticker_pack_list, sticker_list, chat_item
import ../../../status/tasks/[qt, task_runner_impl]

logScope:
  topics = "stickers-view"

type
  EstimateTaskArg = ref object of QObjectTaskArg
    packId: int
    address: string
    price: string
    uuid: string
  ObtainAvailableStickerPacksTaskArg = ref object of QObjectTaskArg

# The pragmas `{.gcsafe, nimcall.}` in this context do not force the compiler
# to accept unsafe code, rather they work in conjunction with the proc
# signature for `type Task` in tasks/common.nim to ensure that the proc really
# is gcsafe and that a helpful error message is displayed
const estimateTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[EstimateTaskArg](argEncoded)
  var success: bool
  var estimate = estimateGas(arg.packId, arg.address, arg.price,
    success)
  if not success:
    estimate = 325000
  let tpl: tuple[estimate: int, uuid: string] = (estimate, arg.uuid)
  arg.finish(tpl)

# the [T] here is annoying but the QtObject template only allows for one type
# definition so we'll need to setup the type, task, and helper outside of body
# passed to `QtObject:`
proc estimate[T](self: T, slot: string, packId: int, address: string, price: string,
                   uuid: string) =
  let arg = EstimateTaskArg(
    tptr: cast[ByteAddress](estimateTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    packId: packId,
    address: address,
    price: price,
    uuid: uuid
  )
  self.status.tasks.threadpool.start(arg)

const obtainAvailableStickerPacksTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[ObtainAvailableStickerPacksTaskArg](argEncoded)
  let availableStickerPacks = status_stickers.getAvailableStickerPacks()
  var packs: seq[StickerPack] = @[]
  for packId, stickerPack in availableStickerPacks.pairs:
    packs.add(stickerPack)
  arg.finish(%*(packs))

proc obtainAvailableStickerPacks[T](self: T, slot: string) =
  let arg = ObtainAvailableStickerPacksTaskArg(
    tptr: cast[ByteAddress](obtainAvailableStickerPacksTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot)
  self.status.tasks.threadpool.start(arg)

QtObject:
  type StickersView* = ref object of QObject
    status: Status
    activeChannel: ChatItemView
    stickerPacks*: StickerPackList
    recentStickers*: StickerList

  proc setup(self: StickersView) =
    self.QObject.setup

  proc delete*(self: StickersView) =
    self.QObject.delete

  proc newStickersView*(status: Status, activeChannel: ChatItemView): StickersView =
    new(result, delete)
    result = StickersView()
    result.status = status
    result.stickerPacks = newStickerPackList()
    result.recentStickers = newStickerList()
    result.activeChannel = activeChannel
    result.setup

  proc addStickerPackToList*(self: StickersView, stickerPack: StickerPack, isInstalled, isBought, isPending: bool) =
    self.stickerPacks.addStickerPackToList(stickerPack, newStickerList(stickerPack.stickers), isInstalled, isBought, isPending)

  proc getStickerPackList(self: StickersView): QVariant {.slot.} =
    newQVariant(self.stickerPacks)

  QtProperty[QVariant] stickerPacks:
    read = getStickerPackList

  proc transactionWasSent*(self: StickersView, txResult: string) {.signal.}

  proc transactionCompleted*(self: StickersView, success: bool, txHash: string, revertReason: string = "") {.signal.}

  proc estimate*(self: StickersView, packId: int, address: string, price: string, uuid: string) {.slot.} =
    self.estimate("setGasEstimate", packId, address, price, uuid)

  proc gasEstimateReturned*(self: StickersView, estimate: int, uuid: string) {.signal.}

  proc setGasEstimate*(self: StickersView, estimateJson: string) {.slot.} =
    let estimateResult = Json.decode(estimateJson, tuple[estimate: int, uuid: string])
    self.gasEstimateReturned(estimateResult.estimate, estimateResult.uuid)

  proc buy*(self: StickersView, packId: int, address: string, price: string, gas: string, gasPrice: string, password: string): string {.slot.} =
    var success: bool
    let response = self.status.stickers.buyPack(packId, address, price, gas, gasPrice, password, success)
    # TODO:
    # check if response["error"] is not null and handle the error
    result = $(%* { "result": %response, "success": %success })
    if success:
      self.stickerPacks.updateStickerPackInList(packId, false, true)
      self.transactionWasSent(response)

  proc obtainAvailableStickerPacks*(self: StickersView) =
    self.obtainAvailableStickerPacks("setAvailableStickerPacks")

  proc stickerPacksLoaded*(self: StickersView) {.signal.}

  proc installedStickerPacksUpdated*(self: StickersView) {.signal.}

  proc recentStickersUpdated*(self: StickersView) {.signal.}

  proc clearStickerPacks*(self: StickersView) =
    self.stickerPacks.clear()

  proc populateOfflineStickerPacks*(self: StickersView) =
    let installedStickerPacks = self.status.stickers.getInstalledStickerPacks()
    for stickerPack in installedStickerPacks.values:
      self.addStickerPackToList(stickerPack, isInstalled = true, isBought = true, isPending = false)

  proc setAvailableStickerPacks*(self: StickersView, availableStickersJSON: string) {.slot.} =
    let
      accounts = status_wallet.getWalletAccounts() # TODO: make generic
      installedStickerPacks = self.status.stickers.getInstalledStickerPacks()
    var
      purchasedStickerPacks: seq[int]
    for account in accounts:
      let address = parseAddress(account.address)
      purchasedStickerPacks = self.status.stickers.getPurchasedStickerPacks(address)
    let availableStickers = JSON.decode($availableStickersJSON, seq[StickerPack])

    let pendingTransactions = status_wallet.getPendingTransactions()
    var pendingStickerPacks = initHashSet[int]()
    if (pendingTransactions != ""):
      for trx in pendingTransactions.parseJson["result"].getElems():
        if trx["type"].getStr == $PendingTransactionType.BuyStickerPack:
          pendingStickerPacks.incl(trx["additionalData"].getStr.parseInt)

    for stickerPack in availableStickers:
      let isInstalled = installedStickerPacks.hasKey(stickerPack.id)
      let isBought = purchasedStickerPacks.contains(stickerPack.id)
      let isPending = pendingStickerPacks.contains(stickerPack.id) and not isBought
      self.status.stickers.availableStickerPacks[stickerPack.id] = stickerPack
      self.addStickerPackToList(stickerPack, isInstalled, isBought, isPending)
    self.stickerPacksLoaded()
    self.installedStickerPacksUpdated()

  proc getNumInstalledStickerPacks(self: StickersView): int {.slot.} =
    self.status.stickers.installedStickerPacks.len

  QtProperty[int] numInstalledStickerPacks:
    read = getNumInstalledStickerPacks
    notify = installedStickerPacksUpdated

  proc install*(self: StickersView, packId: int) {.slot.} =
    self.status.stickers.installStickerPack(packId)
    self.stickerPacks.updateStickerPackInList(packId, true, false)
    self.installedStickerPacksUpdated()

  proc resetBuyAttempt*(self: StickersView, packId: int) {.slot.} =
    self.stickerPacks.updateStickerPackInList(packId, false, false)

  proc uninstall*(self: StickersView, packId: int) {.slot.} =
    self.status.stickers.uninstallStickerPack(packId)
    self.status.stickers.removeRecentStickers(packId)
    self.stickerPacks.updateStickerPackInList(packId, false, false)
    self.recentStickers.removeStickersFromList(packId)
    self.installedStickerPacksUpdated()
    self.recentStickersUpdated()

  proc getRecentStickerList*(self: StickersView): QVariant {.slot.} =
    result = newQVariant(self.recentStickers)

  QtProperty[QVariant] recent:
    read = getRecentStickerList
    notify = recentStickersUpdated

  proc addRecentStickerToList*(self: StickersView, sticker: Sticker) =
    self.recentStickers.addStickerToList(sticker)
    self.recentStickersUpdated()

  proc send*(self: StickersView, hash: string, pack: int) {.slot.} =
    let sticker = Sticker(hash: hash, packId: pack)
    self.addRecentStickerToList(sticker)
    self.status.chat.sendSticker(self.activeChannel.id, sticker)
