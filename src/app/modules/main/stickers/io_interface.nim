import Tables
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/stickers/service as stickers_service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method buy*(self: AccessInterface, packId: int, address: string, price: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): tuple[response: string, success: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method getInstalledStickerPacks*(self: AccessInterface): Table[int, StickerPackDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getPurchasedStickerPacks*(self: AccessInterface, address: string): seq[int] {.base.} =
  raise newException(ValueError, "No implementation available")

method obtainAvailableStickerPacks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method addRecentStickerToList*(self: AccessInterface, sticker: StickerDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method clearStickerPacks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNumInstalledStickerPacks*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method allPacksLoaded*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method estimate*(self: AccessInterface, packId: int, address: string, price: string, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method installStickerPack*(self: AccessInterface, packId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method uninstallStickerPack*(self: AccessInterface, packId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeRecentStickers*(self: AccessInterface, packId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method sendSticker*(self: AccessInterface, channelId: string, replyTo: string, sticker: StickerDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method populateInstalledStickerPacks*(self: AccessInterface, stickers: Table[int, StickerPackDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method gasEstimateReturned*(self: AccessInterface, estimate: int, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addStickerPackToList*(self: AccessInterface, stickerPack: StickerPackDto, isInstalled: bool, isBought: bool, isPending: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
    c.stickersDidLoad()
