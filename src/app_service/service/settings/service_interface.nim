import json
import tables
import ./dto/settings as settings_dto
import ../stickers/dto/stickers as stickers_dto
import ../../../app/core/fleets/fleet_configuration

export settings_dto
export stickers_dto

# Default values:
const DEFAULT_CURRENT_NETWORK* = "mainnet_rpc"
const DEFAULT_CURRENCY* = "usd"
const DEFAULT_TELEMETRY_SERVER_URL* = "https://telemetry.status.im"
const DEFAULT_FLEET* = $Fleet.Prod

type
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method saveAddress*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getAddress*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveCurrency*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrency*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveCurrentNetwork*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentNetwork*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveDappsAddress*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getDappsAddress*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveEip1581Address*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getEip1581Address*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveInstallationId*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getInstallationId*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method savePreferredName*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getPreferredName*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveNewEnsUsername*(self: ServiceInterface, username: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getEnsUsernames*(self: ServiceInterface): seq[string] {.base.} =
  raise newException(ValueError, "No implementation available")

method saveKeyUid*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeyUid*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveLatestDerivedPath*(self: ServiceInterface, value: int): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getLatestDerivedPath*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method saveLinkPreviewRequestEnabled*(self: ServiceInterface, value: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getLinkPreviewRequestEnabled*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method saveMessagesFromContactsOnly*(self: ServiceInterface, value: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessagesFromContactsOnly*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method saveMnemonic*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMnemonic*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveName*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getName*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method savePhotoPath*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getPhotoPath*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method savePreviewPrivacy*(self: ServiceInterface, value: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getPreviewPrivacy*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method savePublicKey*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getPublicKey*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveSigningPhrase*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getSigningPhrase*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveDefaultSyncPeriod*(self: ServiceInterface, value: int): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getDefaultSyncPeriod*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method saveSendPushNotifications*(self: ServiceInterface, value: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getSendPushNotifications*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method saveAppearance*(self: ServiceInterface, value: int): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getAppearance*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method saveProfilePicturesShowTo*(self: ServiceInterface, value: int): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getProfilePicturesShowTo*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method saveProfilePicturesVisibility*(self: ServiceInterface, value: int): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getProfilePicturesVisibility*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method saveUseMailservers*(self: ServiceInterface, value: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getUseMailservers*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method saveWalletRootAddress*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletRootAddress*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveSendStatusUpdates*(self: ServiceInterface, value: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getSendStatusUpdates*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method saveTelemetryServerUrl*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getTelemetryServerUrl*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveFleet*(self: ServiceInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getFleetAsString*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getFleet*(self: ServiceInterface): Fleet {.base.} =
  raise newException(ValueError, "No implementation available")

method getAvailableNetworks*(self: ServiceInterface): seq[Network] {.base.} =
  raise newException(ValueError, "No implementation available")

method getAvailableCustomNetworks*(self: ServiceInterface): seq[Network] {.base.} =
  raise newException(ValueError, "No implementation available")

method addCustomNetwork*(self: ServiceInterface, network: Network): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentNetworkDetails*(self: ServiceInterface): Network {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentNetworkId*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentUserStatus*(self: ServiceInterface): CurrentUserStatus {.base.} =
  raise newException(ValueError, "No implementation available")

method getPinnedMailserver*(self: ServiceInterface, fleet: Fleet): string {.base.} =
  raise newException(ValueError, "No implementation available")

method pinMailserver*(self: ServiceInterface, address: string, fleet: Fleet): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method unpinMailserver*(self: ServiceInterface, fleet: Fleet): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletVisibleTokens*(self: ServiceInterface): Table[int, seq[string]] {.base.} =
  raise newException(ValueError, "No implementation available")

method saveWalletVisibleTokens*(self: ServiceInterface, tokens: Table[int, seq[string]]): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getRecentStickers*(self: ServiceInterface): seq[string] {.base.} =
  raise newException(ValueError, "No implementation available")

method getInstalledStickerPacks*(self: ServiceInterface): Table[string, StickerPackDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method saveNodeConfiguration*(self: ServiceInterface, value: JsonNode): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method saveWakuBloomFilterMode*(self: ServiceInterface, value: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method saveAutoMessageEnabled*(self: ServiceInterface, value: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method autoMessageEnabled*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getWakuBloomFilterMode*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")
