import Tables, stint
import ../../../../app_service/service/stickers/service as stickers_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method buy*(self: AccessInterface, packId: int, address: string, price: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): tuple[response: string, success: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method getInstalledStickerPacks*(self: AccessInterface): Table[int, StickerPackDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getPurchasedStickerPacks*(self: AccessInterface, address: string): seq[int] {.base.} =
  raise newException(ValueError, "No implementation available")

method obtainAvailableStickerPacks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNumInstalledStickerPacks*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method estimate*(self: AccessInterface, packId: int, address: string, price: string, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method installStickerPack*(self: AccessInterface, packId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method uninstallStickerPack*(self: AccessInterface, packId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeRecentStickers*(self: AccessInterface, packId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method decodeContentHash*(self: AccessInterface, hash: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method wei2Eth*(self: AccessInterface, price: Stuint[256]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method sendSticker*(self: AccessInterface, channelId: string, replyTo: string, sticker: StickerDto, preferredUsername: string) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this
  ## module.
  DelegateInterface* = concept c
