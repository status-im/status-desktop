import Tables, stint
import ../../../../app_service/service/stickers/service as stickers_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method buy*(self: AccessInterface, packId: string, address: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): tuple[response: string, success: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method getInstalledStickerPacks*(self: AccessInterface): Table[string, StickerPackDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method obtainMarketStickerPacks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNumInstalledStickerPacks*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method estimate*(self: AccessInterface, packId: string, address: string, price: string, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method installStickerPack*(self: AccessInterface, packId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method uninstallStickerPack*(self: AccessInterface, packId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeRecentStickers*(self: AccessInterface, packId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method decodeContentHash*(self: AccessInterface, hash: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method wei2Eth*(self: AccessInterface, price: Stuint[256]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method sendSticker*(self: AccessInterface, channelId: string, replyTo: string, sticker: StickerDto, preferredUsername: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSigningPhrase*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getStickerMarketAddress*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getSNTBalance*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletDefaultAddress*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentCurrency*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getPrice*(self: AccessInterface, crypto: string, fiat: string): float64 {.base.} =
  raise newException(ValueError, "No implementation available")

method getStatusToken*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchGasPrice*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method gasPriceFetched*(self: AccessInterface, gasPrice: string) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this
  ## module.
  DelegateInterface* = concept c
