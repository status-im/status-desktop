import NimQml, Tables, stint, sugar, sequtils, json, strutils, strformat, parseutils, chronicles
import ./io_interface, ./view, ./controller, ./item, ./models/sticker_pack_list
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/stickers/service as stickers_service
import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/common/conversion as service_conversion
import ../../../../app_service/service/wallet_account/service_interface as wallet_account_service

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
    stickersService: stickers_service.Service,
    settingsService: settings_Service.ServiceInterface,
    walletAccountService: wallet_account_service.ServiceInterface
    ): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, events, stickersService, settingsService, walletAccountService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("stickersModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  self.controller.init()
  let signingPhrase = self.controller.getSigningPhrase()
  let stickerMarketAddress = self.controller.getStickerMarketAddress()
  self.view.load(signingphrase, stickerMarketAddress)

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method viewDidLoad*[T](self: Module[T]) =
  self.moduleLoaded = true
  self.delegate.stickersDidLoad()

method buy*[T](self: Module[T], packId: string, address: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): tuple[response: string, success: bool] =
  return self.controller.buy(packId, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password)

method getInstalledStickerPacks*[T](self: Module[T]): Table[string, StickerPackDto] =
  self.controller.getInstalledStickerPacks()

method obtainMarketStickerPacks*[T](self: Module[T]) =
  self.controller.obtainMarketStickerPacks()

method getNumInstalledStickerPacks*[T](self: Module[T]): int =
  self.controller.getNumInstalledStickerPacks()

method installStickerPack*[T](self: Module[T], packId: string) =
  self.controller.installStickerPack(packId)

method uninstallStickerPack*[T](self: Module[T], packId: string) =
  self.controller.uninstallStickerPack(packId)

method removeRecentStickers*[T](self: Module[T], packId: string) =
  self.controller.removeRecentStickers(packId)

method decodeContentHash*[T](self: Module[T], hash: string): string =
  self.controller.decodeContentHash(hash)

method wei2Eth*[T](self: Module[T], price: Stuint[256]): string =
  self.controller.wei2Eth(price)

method sendSticker*[T](self: Module[T], channelId: string, replyTo: string, sticker: Item) =
  let stickerDto = StickerDto(hash: sticker.getHash, packId: sticker.getPackId)
  self.controller.sendSticker(
    channelId,
    replyTo,
    stickerDto,
    singletonInstance.userProfile.getEnsName())

method estimate*[T](self: Module[T], packId: string, address: string, price: string, uuid: string) =
  self.controller.estimate(packId, address, price, uuid)

method addRecentStickerToList*[T](self: Module[T], sticker: StickerDto) =
  self.view.addRecentStickerToList(initItem(sticker.hash, sticker.packId, sticker.url))

method clearStickerPacks*[T](self: Module[T]) =
  self.view.clearStickerPacks()

method allPacksLoaded*[T](self: Module[T]) =
  self.view.allPacksLoaded()

method populateInstalledStickerPacks*[T](self: Module[T], stickers: Table[string, StickerPackDto]) =
  var stickerPackItems: seq[PackItem] = @[]
  for stickerPack in stickers.values:
    stickerPackItems.add(initPackItem(
      stickerPack.id,
      stickerPack.name,
      stickerPack.author,
      stickerPack.price,
      stickerPack.preview,
      stickerPack.stickers.map(s => initItem(s.hash, s.packId, s.url)),
      stickerPack.thumbnail
    ))
  self.view.populateInstalledStickerPacks(stickerPackItems)

method gasEstimateReturned*[T](self: Module[T], estimate: int, uuid: string) =
  self.view.gasEstimateReturned(estimate, uuid)

method addStickerPackToList*[T](self: Module[T], stickerPack: StickerPackDto, isInstalled: bool, isBought: bool, isPending: bool) =
  let stickerPackItem = initPackItem(
          stickerPack.id,
          stickerPack.name,
          stickerPack.author,
          stickerPack.price,
          stickerPack.preview,
          stickerPack.stickers.map(s => initItem(s.hash, s.packId, s.url)),
          stickerPack.thumbnail
        )
  self.view.addStickerPackToList(stickerPackItem, isInstalled, isBought, isPending)

method getSNTBalance*[T](self: Module[T]): string =
  return self.controller.getSNTBalance()

method getWalletDefaultAddress*[T](self: Module[T]): string =
  return self.controller.getWalletDefaultAddress()

method getCurrentCurrency*[T](self: Module[T]): string =
  return self.controller.getCurrentCurrency()

method getFiatValue*[T](self: Module[T], cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string =
  if (cryptoBalance == "" or cryptoSymbol == "" or fiatSymbol == ""):
    return "0.00"

  let price = self.controller.getPrice(cryptoSymbol, fiatSymbol)
  let value = parseFloat(cryptoBalance) * price
  return fmt"{value:.2f}"

method getGasEthValue*[T](self: Module[T], gweiValue: string, gasLimit: string): string {.slot.} =
  var gasLimitInt:int

  if(gasLimit.parseInt(gasLimitInt) == 0):
    info "an error occurred parsing gas limit", methodName="getGasEthValue"
    return ""

  # The following check prevents app crash, cause we're trying to promote
  # gasLimitInt to unsigned 256 int, and this number must be a positive number,
  # because of overflow.
  var gwei = gweiValue.parseFloat()
  if (gwei < 0):
    gwei = 0

  if (gasLimitInt < 0):
    gasLimitInt = 0

  let weiValue = service_conversion.gwei2Wei(gwei) * gasLimitInt.u256
  let ethValue = service_conversion.wei2Eth(weiValue)
  return fmt"{ethValue}"

method getStatusToken*[T](self: Module[T]): string =
  return self.controller.getStatusToken()

method fetchGasPrice*[T](self: Module[T]) =
  self.controller.fetchGasPrice()

method gasPriceFetched*[T](self: Module[T], gasPrice: string) =
  self.view.setGasPrice(gasPrice)

method stickerTransactionConfirmed*[T](self: Module[T], trxType: string, packID: string, transactionHash: string) =
  self.view.stickerPacks.updateStickerPackInList(packID, true, false)
  self.controller.installStickerPack(packID)
  self.view.emitTransactionCompletedSignal(true, transactionHash, packID, trxType, "")

method stickerTransactionReverted*[T](self: Module[T], trxType: string, packID: string, transactionHash: string,
  revertReason: string) =
  self.view.stickerPacks.updateStickerPackInList(packID, false, false)
  self.view.emitTransactionCompletedSignal(false, transactionHash, packID, trxType, revertReason)
