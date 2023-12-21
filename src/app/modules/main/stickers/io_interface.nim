import Tables, stint
import ./item

import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/stickers/service as stickers_service
from app_service/service/keycard/service import KeycardEvent

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

method authenticateAndBuy*(self: AccessInterface, packId: string, address: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool){.base.} =
  raise newException(ValueError, "No implementation available")

method getRecentStickers*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadRecentStickers*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getInstalledStickerPacks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method installedStickerPacksLoaded*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method obtainMarketStickerPacks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method addRecentStickerToList*(self: AccessInterface, sticker: StickerDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method clearStickers*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method clearStickerPacks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNumInstalledStickerPacks*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method allPacksLoaded*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method allPacksLoadFailed*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method estimate*(self: AccessInterface, packId: string, address: string, price: string, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method installStickerPack*(self: AccessInterface, packId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onStickerPackInstalled*(self: AccessInterface, packId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method uninstallStickerPack*(self: AccessInterface, packId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method wei2Eth*(self: AccessInterface, price: Stuint[256]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method removeRecentStickers*(self: AccessInterface, packId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method sendSticker*(self: AccessInterface, channelId: string, replyTo: string, sticker: Item) {.base.} =
  raise newException(ValueError, "No implementation available")

method populateInstalledStickerPacks*(self: AccessInterface, stickers: Table[string, StickerPackDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method gasEstimateReturned*(self: AccessInterface, estimate: int, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addStickerPackToList*(self: AccessInterface, stickerPack: StickerPackDto, isInstalled: bool, isBought: bool, isPending: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSNTBalance*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletDefaultAddress*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentCurrency*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getFiatValue*(self: AccessInterface, cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string
  {.base.} =
  raise newException(ValueError, "No implementation available")

method getGasEthValue*(self: AccessInterface, gweiValue: string, gasLimit: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getStatusToken*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getChainIdForStickers*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method stickerTransactionConfirmed*(self: AccessInterface, trxType: string, packID: string, transactionHash: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method stickerTransactionReverted*(self: AccessInterface, trxType: string, packID: string, transactionHash: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeypairAuthenticated*(self: AccessInterface, password: string, pin: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onTransactionSigned*(self: AccessInterface, keycardFlowType: string, keycardEvent: KeycardEvent) {.base.} =
  raise newException(ValueError, "No implementation available")