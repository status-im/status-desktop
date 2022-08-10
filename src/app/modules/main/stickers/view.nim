import NimQml, json, strutils, json_serialization

import ./models/[sticker_list, sticker_pack_list]
import ./io_interface, ./item
import ../../../../app_service/service/eth/utils as eth_utils

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      packsLoaded*: bool
      stickerPacks*: StickerPackList
      recentStickers*: StickerList
      signingPhrase: string
      stickersMarketAddress: string

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.stickerPacks = newStickerPackList(result.delegate)
    result.recentStickers = newStickerList(result.delegate)

  proc load*(self: View, signingPhrase: string, stickersMarketAddress: string) =
    self.signingPhrase = signingPhrase
    self.stickersMarketAddress = stickersMarketAddress
    self.delegate.viewDidLoad()

  proc addStickerPackToList*(self: View, stickerPack: PackItem, isInstalled, isBought, isPending: bool) =
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

  proc estimate*(self: View, packId: string, address: string, price: string, uuid: string) {.slot.} =
    self.delegate.estimate(packId, address, price, uuid)

  proc gasEstimateReturned*(self: View, estimate: int, uuid: string) {.signal.}

  proc buy*(self: View, packId: string, address: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, eip1559Enabled: bool): string {.slot.} =
    let responseTuple = self.delegate.buy(packId, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, eip1559Enabled)
    let response = responseTuple.response
    let success = responseTuple.success
    if success:
      self.stickerPacks.updateStickerPackInList(packId, false, true)
      self.transactionWasSent(response)

    result = $(%*{
      "success": success,
      "result": response
    })

  proc stickerPacksLoaded*(self: View) {.signal.}

  proc installedStickerPacksUpdated*(self: View) {.signal.}

  proc clearStickerPacks*(self: View) =
    self.stickerPacks.clear()

  proc populateInstalledStickerPacks*(self: View, installedStickerPacks: seq[PackItem]) =
    for stickerPack in installedStickerPacks:
      self.addStickerPackToList(stickerPack, isInstalled = true, isBought = true, isPending = false)

  proc getNumInstalledStickerPacks(self: View): int {.slot.} =
    self.delegate.getNumInstalledStickerPacks()

  QtProperty[int] numInstalledStickerPacks:
    read = getNumInstalledStickerPacks
    notify = installedStickerPacksUpdated

  proc install*(self: View, packId: string) {.slot.} =
    self.delegate.installStickerPack(packId)
    self.stickerPacks.updateStickerPackInList(packId, true, false)
    self.installedStickerPacksUpdated()

  proc resetBuyAttempt*(self: View, packId: string) {.slot.} =
    self.stickerPacks.updateStickerPackInList(packId, false, false)

  proc uninstall*(self: View, packId: string) {.slot.} =
    self.delegate.uninstallStickerPack(packId)
    self.delegate.removeRecentStickers(packId)
    self.stickerPacks.updateStickerPackInList(packId, false, false)
    self.recentStickers.removeStickersFromList(packId)
    self.installedStickerPacksUpdated()
    self.recentStickersUpdated()

  proc addRecentStickerToList*(self: View, sticker: Item) =
    self.recentStickers.addStickerToList(sticker)

  proc getAllPacksLoaded(self: View): bool {.slot.} =
    self.packsLoaded

  QtProperty[bool] packsLoaded:
    read = getAllPacksLoaded
    notify = stickerPacksLoaded

  proc allPacksLoaded*(self: View) =
    self.packsLoaded = true
    self.stickerPacksLoaded()
    self.installedStickerPacksUpdated()

  proc send*(self: View, channelId: string, hash: string, replyTo: string, pack: string, url: string) {.slot.} =
    let sticker = initItem(hash, pack, url)
    self.addRecentStickerToList(sticker)
    self.delegate.sendSticker(channelId, replyTo, sticker)

  proc getSigningPhrase(self: View): QVariant {.slot.} =
    return newQVariant(self.signingPhrase)

  proc getStickersMarketAddress(self: View): string {.slot.} =
    return self.stickersMarketAddress

  proc getSNTBalance*(self: View): string {.slot.} =
    return self.delegate.getSNTBalance()

  proc getChainIdForStickers*(self: View): int {.slot.} =
    return self.delegate.getChainIdForStickers()
  
  proc getWalletDefaultAddress*(self: View): string {.slot.} =
    return self.delegate.getWalletDefaultAddress()

  proc getCurrentCurrency*(self: View): string {.slot.} =
    return self.delegate.getCurrentCurrency()

  proc getFiatValue*(self: View, cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string {.slot.} =
    return self.delegate.getFiatValue(cryptoBalance, cryptoSymbol, fiatSymbol)

  proc getGasEthValue*(self: View, gweiValue: string, gasLimit: string): string {.slot.} =
    return self.delegate.getGasEthValue(gweiValue, gasLimit)

  proc getStatusToken*(self: View): string {.slot.} =
    return self.delegate.getStatusToken()

  proc transactionCompleted(self: View, success: bool, txHash: string, packID: string, trxType: string,
    revertReason: string) {.signal.}
  proc emitTransactionCompletedSignal*(self: View, success: bool, txHash: string, packID: string, trxType: string,
    revertReason: string) =
    self.transactionCompleted(success, txHash, packID, trxType, revertReason)
