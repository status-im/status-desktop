import NimQml, Tables, stint

import eventemitter
import ./io_interface, ./view, ./controller
import ../../../global/global_singleton
import ../../../../app_service/service/stickers/service as stickers_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](
    delegate: T,
    events: EventEmitter,
    stickersService: stickers_service.Service
    ): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, events, stickersService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("stickersModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  self.controller.init()
  self.view.load()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method viewDidLoad*[T](self: Module[T]) =
  self.moduleLoaded = true
  self.delegate.stickersDidLoad()

method buy*[T](self: Module[T], packId: int, address: string, price: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): tuple[response: string, success: bool] =
  return self.controller.buy(packId, address, price, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password)

method getInstalledStickerPacks*[T](self: Module[T]): Table[int, StickerPackDto] =
  self.controller.getInstalledStickerPacks()

method getPurchasedStickerPacks*[T](self: Module[T], address: string): seq[int] =
  self.controller.getPurchasedStickerPacks(address)

method obtainAvailableStickerPacks*[T](self: Module[T]) =
  self.controller.obtainAvailableStickerPacks()

method getNumInstalledStickerPacks*[T](self: Module[T]): int =
  self.controller.getNumInstalledStickerPacks()

method installStickerPack*[T](self: Module[T], packId: int) =
  self.controller.installStickerPack(packId)

method uninstallStickerPack*[T](self: Module[T], packId: int) =
  self.controller.uninstallStickerPack(packId)

method removeRecentStickers*[T](self: Module[T], packId: int) =
  self.controller.removeRecentStickers(packId)

method decodeContentHash*[T](self: Module[T], hash: string): string =
  self.controller.decodeContentHash(hash)

method wei2Eth*[T](self: Module[T], price: Stuint[256]): string =
  self.controller.wei2Eth(price)

method sendSticker*[T](self: Module[T], channelId: string, replyTo: string, sticker: StickerDto) =
  self.controller.sendSticker(channelId, replyTo, sticker)

method estimate*[T](self: Module[T], packId: int, address: string, price: string, uuid: string) =
  self.controller.estimate(packId, address, price, uuid)

method addRecentStickerToList*[T](self: Module[T], sticker: StickerDto) =
  self.view.addRecentStickerToList(sticker)

method clearStickerPacks*[T](self: Module[T]) =
  self.view.clearStickerPacks()

method allPacksLoaded*[T](self: Module[T]) =
  self.view.allPacksLoaded()

method populateInstalledStickerPacks*[T](self: Module[T], stickers: Table[int, StickerPackDto]) =
  self.view.populateInstalledStickerPacks(stickers)

method gasEstimateReturned*[T](self: Module[T], estimate: int, uuid: string) =
  self.view.gasEstimateReturned(estimate, uuid)

method addStickerPackToList*[T](self: Module[T], stickerPack: StickerPackDto, isInstalled: bool, isBought: bool, isPending: bool) =
  self.view.addStickerPackToList(stickerPack, isInstalled, isBought, isPending)
