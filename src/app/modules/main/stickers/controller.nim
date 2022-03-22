import Tables, stint

import ./controller_interface
import ./io_interface

import ../../../core/eventemitter
import ../../../../app_service/service/node/service as node_service
import ../../../../app_service/service/stickers/service as stickers_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/eth/utils as eth_utils
import ../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    stickerService: stickers_service.Service
    settingsService: settings_service.Service
    walletAccountService: wallet_account_service.Service
    disconnected: bool

# Forward declaration
method obtainMarketStickerPacks*[T](self: Controller[T])
method getInstalledStickerPacks*[T](self: Controller[T]): Table[string, StickerPackDto]

proc newController*[T](
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    stickerService: stickers_service.Service,
    settingsService: settings_service.Service,
    walletAccountService: wallet_account_service.Service
    ): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.events = events
  result.stickerService = stickerService
  result.settingsService = settingsService
  result.walletAccountService = walletAccountService
  result.disconnected = false

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) =
  let recentStickers = self.stickerService.getRecentStickers()
  for sticker in recentStickers:
    self.delegate.addRecentStickerToList(sticker)

  let installedStickers = self.stickerService.getInstalledStickerPacks()
  self.delegate.populateInstalledStickerPacks(installedStickers)

  self.events.on(SIGNAL_NETWORK_DISCONNECTED) do(e: Args):
    self.disconnected = true
    self.delegate.clearStickerPacks()
    let installedStickerPacks = self.getInstalledStickerPacks()
    self.delegate.populateInstalledStickerPacks(installedStickerPacks)

  self.events.on(SIGNAL_NETWORK_CONNECTED) do(e: Args):
    if self.disconnected:
      let installedStickers = self.stickerService.getInstalledStickerPacks()
      self.delegate.populateInstalledStickerPacks(installedStickers)
      self.delegate.clearStickerPacks()
      self.obtainMarketStickerPacks()
      self.disconnected = false

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

  self.events.on(SIGNAL_GAS_PRICE_FETCHED) do(e:Args):
    let args = GasPriceArgs(e)
    self.delegate.gasPriceFetched(args.gasPrice)

  self.events.on(SIGNAL_STICKER_GAS_ESTIMATED) do(e: Args):
    let args = StickerGasEstimatedArgs(e)
    self.delegate.gasEstimateReturned(args.estimate, args.uuid)

  self.events.on(SIGNAL_STICKER_TRANSACTION_CONFIRMED) do(e:Args):
    let args = StickerTransactionArgs(e)
    self.delegate.stickerTransactionConfirmed(args.transactionType, args.packID, args.transactionHash)

  self.events.on(SIGNAL_STICKER_TRANSACTION_REVERTED) do(e:Args):
    let args = StickerTransactionArgs(e)
    self.delegate.stickerTransactionReverted(args.transactionType, args.packID, args.transactionHash, args.revertReason)

method buy*[T](self: Controller[T], packId: string, address: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): tuple[response: string, success: bool] =
  self.stickerService.buy(packId, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password)

method estimate*[T](self: Controller[T], packId: string, address: string, price: string, uuid: string) =
  self.stickerService.estimate(packId, address, price, uuid)

method getInstalledStickerPacks*[T](self: Controller[T]): Table[string, StickerPackDto] =
  self.stickerService.getInstalledStickerPacks()

method obtainMarketStickerPacks*[T](self: Controller[T]) =
  self.stickerService.obtainMarketStickerPacks()

method getNumInstalledStickerPacks*[T](self: Controller[T]): int =
  self.stickerService.getNumInstalledStickerPacks()

method installStickerPack*[T](self: Controller[T], packId: string) =
  self.stickerService.installStickerPack(packId)

method uninstallStickerPack*[T](self: Controller[T], packId: string) =
  self.stickerService.uninstallStickerPack(packId)

method removeRecentStickers*[T](self: Controller[T], packId: string) =
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

method getSigningPhrase*[T](self: Controller[T]): string =
  return self.settingsService.getSigningPhrase()

method getStickerMarketAddress*[T](self: Controller[T]): string =
  return self.stickerService.getStickerMarketAddress()

method getSNTBalance*[T](self: Controller[T]): string =
  return self.stickerService.getSNTBalance()

method getWalletDefaultAddress*[T](self: Controller[T]): string =
  return self.walletAccountService.getWalletAccount(0).address

method getCurrentCurrency*[T](self: Controller[T]): string =
  return self.settingsService.getCurrency()

method getPrice*[T](self: Controller[T], crypto: string, fiat: string): float64 =
  return self.walletAccountService.getPrice(crypto, fiat)

method getStatusToken*[T](self: Controller[T]): string =
  return self.stickerService.getStatusToken()

method fetchGasPrice*[T](self: Controller[T]) =
  self.stickerService.fetchGasPrice()
