import Tables, stint
import eventemitter
import ./controller_interface
import ./io_interface
import ../../../../app_service/service/stickers/service as stickers_service
import ../../../../app_service/service/eth/utils as eth_utils

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    stickerService: stickers_service.Service

# Forward declaration
method obtainAvailableStickerPacks*[T](self: Controller[T])
method getInstalledStickerPacks*[T](self: Controller[T]): Table[int, StickerPackDto]

proc newController*[T](
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    stickerService: stickers_service.Service
    ): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.events = events
  result.stickerService = stickerService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) =
  let recentStickers = self.stickerService.getRecentStickers()
  for sticker in recentStickers:
    self.delegate.addRecentStickerToList(sticker)

  self.events.on("network:disconnected") do(e: Args):
    self.delegate.clearStickerPacks()
    let installedStickerPacks = self.getInstalledStickerPacks()
    self.delegate.populateInstalledStickerPacks(installedStickerPacks)

  self.events.on("network:connected") do(e: Args):
    self.delegate.clearStickerPacks()
    self.obtainAvailableStickerPacks()

  self.events.on(SIGNAL_STICKER_PACK_LOADED) do(e: Args):
    let args = StickerPackLoadedArgs(e)
    self.delegate.addStickerPackToList(
      args.stickerPack,
      args.isInstalled,
      args.isBought,
      args.isPending
    )

  self.events.on(SIGNAL_ALL_STICKER_PACKS_LOADED) do(e: Args):
    self.delegate.allPacksLoaded()

  self.events.on(SIGNAL_STICKER_GAS_ESTIMATED) do(e: Args):
    let args = StickerGasEstimatedArgs(e)
    self.delegate.gasEstimateReturned(args.estimate, args.uuid)

method buy*[T](self: Controller[T], packId: int, address: string, price: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): tuple[response: string, success: bool] =
  self.stickerService.buy(packId, address, price, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password)

method estimate*[T](self: Controller[T], packId: int, address: string, price: string, uuid: string) =
  self.stickerService.estimate(packId, address, price, uuid)

method getInstalledStickerPacks*[T](self: Controller[T]): Table[int, StickerPackDto] =
  self.stickerService.getInstalledStickerPacks()

method getPurchasedStickerPacks*[T](self: Controller[T], address: string): seq[int] =
  self.stickerService.getPurchasedStickerPacks(address)

method obtainAvailableStickerPacks*[T](self: Controller[T]) =
  self.stickerService.obtainAvailableStickerPacks()

method getNumInstalledStickerPacks*[T](self: Controller[T]): int =
  self.stickerService.getNumInstalledStickerPacks()

method installStickerPack*[T](self: Controller[T], packId: int) =
  self.stickerService.installStickerPack(packId)

method uninstallStickerPack*[T](self: Controller[T], packId: int) =
  self.stickerService.uninstallStickerPack(packId)

method removeRecentStickers*[T](self: Controller[T], packId: int) =
  self.stickerService.removeRecentStickers(packId)

method sendSticker*[T](
    self: Controller[T],
    channelId: string,
    replyTo: string,
    sticker: StickerDto,
    preferredUsername: string) =
  self.stickerService.sendSticker(channelId, replyTo, sticker, preferredUsername)

method decodeContentHash*[T](self: Controller[T], hash: string): string =
  eth_utils.decodeContentHash(hash)

method wei2Eth*[T](self: Controller[T], price: Stuint[256]): string =
  eth_utils.wei2Eth(price)
