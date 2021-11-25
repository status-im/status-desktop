import NimQml, json, strutils, tables, json_serialization

import ./models/[sticker_list, sticker_pack_list]
import ./io_interface
import ../../../../app_service/service/stickers/dto/stickers

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      stickerPacks*: StickerPackList
      recentStickers*: StickerList

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.stickerPacks = newStickerPackList(result.delegate)
    result.recentStickers = newStickerList(result.delegate)

  proc addStickerPackToList*(self: View, stickerPack: StickerPackDto, isInstalled, isBought, isPending: bool) =
    self.stickerPacks.addStickerPackToList(
      stickerPack,
      newStickerList(self.delegate, stickerPack.stickers),
      isInstalled,
      isBought,
      isPending
    )

  proc getStickerPackList(self: View): QVariant {.slot.} =
    newQVariant(self.stickerPacks)

  QtProperty[QVariant] stickerPacks:
    read = getStickerPackList

  proc recentStickersUpdated*(self: View) {.signal.}
  proc getRecentStickerList*(self: View): QVariant {.slot.} =
    result = newQVariant(self.recentStickers)

  QtProperty[QVariant] recent:
    read = getRecentStickerList
    notify = recentStickersUpdated

  proc transactionWasSent*(self: View, txResult: string) {.signal.}

  proc transactionCompleted*(self: View, success: bool, txHash: string, revertReason: string = "") {.signal.}

  proc estimate*(self: View, packId: int, address: string, price: string, uuid: string) {.slot.} =
    self.delegate.estimate(packId, address, price, uuid)

  proc gasEstimateReturned*(self: View, estimate: int, uuid: string) {.signal.}

  proc buy*(self: View, packId: int, address: string, price: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): string {.slot.} =
    let responseTuple = self.delegate.buy(packId, address, price, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password)
    let response = responseTuple.response
    let success = responseTuple.success
    if success:
      self.stickerPacks.updateStickerPackInList(packId, false, true)
      self.transactionWasSent(response)

  proc stickerPacksLoaded*(self: View) {.signal.}

  proc installedStickerPacksUpdated*(self: View) {.signal.}

  proc clearStickerPacks*(self: View) =
    self.stickerPacks.clear()

  proc populateInstalledStickerPacks*(self: View, installedStickerPacks: Table[int, StickerPackDto]) =
    for stickerPack in installedStickerPacks.values:
      self.addStickerPackToList(stickerPack, isInstalled = true, isBought = true, isPending = false)


  proc getNumInstalledStickerPacks(self: View): int {.slot.} =
    self.delegate.getNumInstalledStickerPacks()

  QtProperty[int] numInstalledStickerPacks:
    read = getNumInstalledStickerPacks
    notify = installedStickerPacksUpdated

  proc install*(self: View, packId: int) {.slot.} =
    self.delegate.installStickerPack(packId)
    self.stickerPacks.updateStickerPackInList(packId, true, false)
    self.installedStickerPacksUpdated()

  proc resetBuyAttempt*(self: View, packId: int) {.slot.} =
    self.stickerPacks.updateStickerPackInList(packId, false, false)

  proc uninstall*(self: View, packId: int) {.slot.} =
    self.delegate.uninstallStickerPack(packId)
    self.delegate.removeRecentStickers(packId)
    self.stickerPacks.updateStickerPackInList(packId, false, false)
    self.recentStickers.removeStickersFromList(packId)
    self.installedStickerPacksUpdated()
    self.recentStickersUpdated()

  proc addRecentStickerToList*(self: View, sticker: StickerDto) =
    self.recentStickers.addStickerToList(sticker)

  proc allPacksLoaded*(self: View) =
    self.stickerPacksLoaded()
    self.installedStickerPacksUpdated()

  proc send*(self: View, channelId: string, hash: string, replyTo: string, pack: int) {.slot.} =
    let sticker = StickerDto(hash: hash, packId: pack)
    self.addRecentStickerToList(sticker)
    self.delegate.sendSticker(channelId, replyTo, sticker)

