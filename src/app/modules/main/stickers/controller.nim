import Tables, stint, json

import ./io_interface

import ../../../core/eventemitter
import ../../../../app_service/service/node/service as node_service
import ../../../../app_service/service/stickers/service as stickers_service
import ../../../../app_service/service/token/service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/network/service as network_service
import ../../../../app_service/service/eth/utils as eth_utils
import ../../../../app_service/service/wallet_account/service as wallet_account_service


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    stickerService: stickers_service.Service
    settingsService: settings_service.Service
    networkService: network_service.Service
    walletAccountService: wallet_account_service.Service
    disconnected: bool

# Forward declaration
proc obtainMarketStickerPacks*(self: Controller)
proc getInstalledStickerPacks*(self: Controller): Table[string, StickerPackDto]

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    stickerService: stickers_service.Service,
    settingsService: settings_service.Service,
    walletAccountService: wallet_account_service.Service,
    networkService: network_service.Service,
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.stickerService = stickerService
  result.settingsService = settingsService
  result.networkService = networkService
  result.walletAccountService = walletAccountService
  result.disconnected = false

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
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

  self.events.on(SIGNAL_STICKER_GAS_ESTIMATED) do(e: Args):
    let args = StickerGasEstimatedArgs(e)
    self.delegate.gasEstimateReturned(args.estimate, args.uuid)

  self.events.on(SIGNAL_STICKER_TRANSACTION_CONFIRMED) do(e:Args):
    let args = StickerTransactionArgs(e)
    self.delegate.stickerTransactionConfirmed(args.transactionType, args.packID, args.transactionHash)

  self.events.on(SIGNAL_STICKER_TRANSACTION_REVERTED) do(e:Args):
    let args = StickerTransactionArgs(e)
    self.delegate.stickerTransactionReverted(args.transactionType, args.packID, args.transactionHash, args.revertReason)

proc buy*(self: Controller, packId: string, address: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, eip1559Enabled: bool): tuple[response: string, success: bool] =
  self.stickerService.buy(packId, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, eip1559Enabled)

proc estimate*(self: Controller, packId: string, address: string, price: string, uuid: string) =
  self.stickerService.estimate(packId, address, price, uuid)

proc getInstalledStickerPacks*(self: Controller): Table[string, StickerPackDto] =
  self.stickerService.getInstalledStickerPacks()

proc obtainMarketStickerPacks*(self: Controller) =
  self.stickerService.obtainMarketStickerPacks()

proc getNumInstalledStickerPacks*(self: Controller): int =
  self.stickerService.getNumInstalledStickerPacks()

proc installStickerPack*(self: Controller, packId: string) =
  self.stickerService.installStickerPack(packId)

proc uninstallStickerPack*(self: Controller, packId: string) =
  self.stickerService.uninstallStickerPack(packId)

proc removeRecentStickers*(self: Controller, packId: string) =
  self.stickerService.removeRecentStickers(packId)

proc sendSticker*(
    self: Controller,
    channelId: string,
    replyTo: string,
    sticker: StickerDto,
    preferredUsername: string) =
  self.stickerService.sendSticker(channelId, replyTo, sticker, preferredUsername)

proc decodeContentHash*(self: Controller, hash: string): string =
  eth_utils.decodeContentHash(hash)

proc wei2Eth*(self: Controller, price: Stuint[256]): string =
  eth_utils.wei2Eth(price)

proc getSigningPhrase*(self: Controller): string =
  return self.settingsService.getSigningPhrase()

proc getStickerMarketAddress*(self: Controller): string =
  return self.stickerService.getStickerMarketAddress()

proc getSNTBalance*(self: Controller): string =
  return self.stickerService.getSNTBalance()

proc getWalletDefaultAddress*(self: Controller): string =
  return self.walletAccountService.getWalletAccount(0).address

proc getCurrentCurrency*(self: Controller): string =
  return self.settingsService.getCurrency()

proc getPrice*(self: Controller, crypto: string, fiat: string): float64 =
  return self.walletAccountService.getPrice(crypto, fiat)

proc getChainIdForStickers*(self: Controller): int =
  return self.networkService.getNetworkForStickers().chainId

proc getStatusToken*(self: Controller): string =
  let token = self.stickerService.getStatusToken()

  let jsonObj = %* {
    "name": token.name,
    "symbol": token.symbol,
    "address": token.addressAsString()
  }
  return $jsonObj