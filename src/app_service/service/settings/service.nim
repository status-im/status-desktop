import chronicles, json

import service_interface, ./dto/settings
import status/statusgo_backend_new/settings as status_go

export service_interface

logScope:
  topics = "settings-service"

# Setting keys:
const KEY_ADDRESS = "address"
const KEY_CURRENCY = "currency"
const KEY_NETWORKS_CURRENT_NETWORK = "networks/current-network"
const KEY_DAPPS_ADDRESS = "dapps-address"
const KEY_EIP1581_ADDRESS = "eip1581-address"
const KEY_INSTALLATION_ID = "installation-id"
const KEY_KEY_UID = "key-uid"
const KEY_LATEST_DERIVED_PATH = "latest-derived-path"
const KEY_LINK_PREVIEW_REQUEST_ENABLED = "link-preview-request-enabled"
const KEY_MESSAGES_FROM_CONTACTS_ONLY = "messages-from-contacts-only"
const KEY_MNEMONIC = "mnemonic"
const KEY_NAME = "name"
const KEY_PHOTO_PATH = "photo-path"
const KEY_PREVIEW_PRIVACY = "preview-privacy?"
const KEY_PUBLIC_KEY = "public-key"
const KEY_SIGNING_PHRASE = "signing-phrase"
const KEY_DEFAULT_SYNC_PERIOD = "default-sync-period"
const KEY_SEND_PUSH_NOTIFICATIONS = "send-push-notifications?"
const KEY_APPEARANCE = "appearance"
const KEY_PROFILE_PICTURES_SHOW_TO = "profile-pictures-show-to"
const KEY_PROFILE_PICTURES_VISIBILITY = "profile-pictures-visibility"
const KEY_USE_MAILSERVERS = "use-mailservers?"
const KEY_WALLET_ROOT_ADDRESS = "wallet-root-address"
const KEY_SEND_STATUS_UPDATES = "send-status-updates?"
const KEY_TELEMETRY_SERVER_URL = "telemetry-server-url"
const KEY_FLEET = "fleet"
const KEY_WALLET_VISIBLE_TOKENS = "wallet/visible-tokens"
const KEY_NODE_CONFIG = "node-config"
const KEY_WAKU_BLOOM_FILTER_MODE = "waku-bloom-filter-mode"

type
  Service* = ref object of service_interface.ServiceInterface
    settings: SettingsDto

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  try:
    let response = status_go.getSettings()
    self.settings = response.result.toSettingsDto()
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc saveSetting(self: Service, attribute: string, value: string | JsonNode | bool | int): bool =
  let response = status_go.saveSettings(attribute, value)
  if(not response.error.isNil):
    error "error saving settings: ", errDescription = response.error.message
    return false

  return true

method saveAddress*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_ADDRESS, value)):
    self.settings.address = value
    return true
  return false

method getAddress*(self: Service): string =
  return self.settings.address

method saveCurrency*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_CURRENCY, value)):
    self.settings.currency = value
    return true
  return false

method getCurrency*(self: Service): string =
  if(self.settings.currency.len == 0):
    self.settings.currency = DEFAULT_CURRENCY

  return self.settings.currency

method saveCurrentNetwork*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_NETWORKS_CURRENT_NETWORK, value)):
    self.settings.currentNetwork = value
    return true
  return false

method getCurrentNetwork*(self: Service): string =
  if(self.settings.currentNetwork.len == 0):
    self.settings.currentNetwork = DEFAULT_CURRENT_NETWORK

  return self.settings.currentNetwork

method saveDappsAddress*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_DAPPS_ADDRESS, value)):
    self.settings.dappsAddress = value
    return true
  return false

method getDappsAddress*(self: Service): string =
  return self.settings.dappsAddress

method saveEip1581Address*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_EIP1581_ADDRESS, value)):
    self.settings.eip1581Address = value
    return true
  return false

method getEip1581Address*(self: Service): string =
  return self.settings.eip1581Address

method saveInstallationId*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_INSTALLATION_ID, value)):
    self.settings.installationId = value
    return true
  return false

method getInstallationId*(self: Service): string =
  return self.settings.installationId

method saveKeyUid*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_KEY_UID, value)):
    self.settings.keyUid = value
    return true
  return false

method getKeyUid*(self: Service): string =
  return self.settings.keyUid

method saveLatestDerivedPath*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_LATEST_DERIVED_PATH, value)):
    self.settings.latestDerivedPath = value
    return true
  return false

method getLatestDerivedPath*(self: Service): int =
  self.settings.latestDerivedPath

method saveLinkPreviewRequestEnabled*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_LINK_PREVIEW_REQUEST_ENABLED, value)):
    self.settings.linkPreviewRequestEnabled = value
    return true
  return false

method getLinkPreviewRequestEnabled*(self: Service): bool =
  self.settings.linkPreviewRequestEnabled

method saveMessagesFromContactsOnly*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_MESSAGES_FROM_CONTACTS_ONLY, value)):
    self.settings.messagesFromContactsOnly = value
    return true
  return false

method getMessagesFromContactsOnly*(self: Service): bool =
  self.settings.messagesFromContactsOnly

method saveMnemonic*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_MNEMONIC, value)):
    self.settings.mnemonic = value
    return true
  return false

method getMnemonic*(self: Service): string =
  return self.settings.mnemonic

method saveName*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_NAME, value)):
    self.settings.name = value
    return true
  return false

method getName*(self: Service): string =
  return self.settings.name

method savePhotoPath*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_PHOTO_PATH, value)):
    self.settings.photoPath = value
    return true
  return false

method getPhotoPath*(self: Service): string =
  return self.settings.photoPath

method savePreviewPrivacy*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_PREVIEW_PRIVACY, value)):
    self.settings.previewPrivacy = value
    return true
  return false

method getPreviewPrivacy*(self: Service): bool =
  self.settings.previewPrivacy

method savePublicKey*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_PUBLIC_KEY, value)):
    self.settings.publicKey = value
    return true
  return false

method getPublicKey*(self: Service): string =
  return self.settings.publicKey

method saveSigningPhrase*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_SIGNING_PHRASE, value)):
    self.settings.signingPhrase = value
    return true
  return false

method getSigningPhrase*(self: Service): string =
  return self.settings.signingPhrase

method saveDefaultSyncPeriod*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_DEFAULT_SYNC_PERIOD, value)):
    self.settings.defaultSyncPeriod = value
    return true
  return false

method getDefaultSyncPeriod*(self: Service): int =
  self.settings.defaultSyncPeriod

method saveSendPushNotifications*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_SEND_PUSH_NOTIFICATIONS, value)):
    self.settings.sendPushNotifications = value
    return true
  return false

method getSendPushNotifications*(self: Service): bool =
  self.settings.sendPushNotifications

method saveAppearance*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_APPEARANCE, value)):
    self.settings.appearance = value
    return true
  return false

method getAppearance*(self: Service): int =
  self.settings.appearance

method saveProfilePicturesShowTo*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_PROFILE_PICTURES_SHOW_TO, value)):
    self.settings.profilePicturesShowTo = value
    return true
  return false

method getProfilePicturesShowTo*(self: Service): int =
  self.settings.profilePicturesShowTo

method saveProfilePicturesVisibility*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_PROFILE_PICTURES_VISIBILITY, value)):
    self.settings.profilePicturesVisibility = value
    return true
  return false

method getProfilePicturesVisibility*(self: Service): int =
  self.settings.profilePicturesVisibility

method saveUseMailservers*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_USE_MAILSERVERS, value)):
    self.settings.useMailservers = value
    return true
  return false

method getUseMailservers*(self: Service): bool =
  self.settings.useMailservers

method saveWalletRootAddress*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_WALLET_ROOT_ADDRESS, value)):
    self.settings.walletRootAddress = value
    return true
  return false

method getWalletRootAddress*(self: Service): string =
  return self.settings.walletRootAddress

method saveSendStatusUpdates*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_SEND_STATUS_UPDATES, value)):
    self.settings.sendStatusUpdates = value
    return true
  return false

method getSendStatusUpdates*(self: Service): bool =
  self.settings.sendStatusUpdates

method saveTelemetryServerUrl*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_TELEMETRY_SERVER_URL, value)):
    self.settings.telemetryServerUrl = value
    return true
  return false

method getTelemetryServerUrl*(self: Service): string =
  return self.settings.telemetryServerUrl

method saveFleet*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_FLEET, value)):
    self.settings.fleet = value
    return true
  return false

method getFleet*(self: Service): string =
  return self.settings.fleet

method getAvailableNetworks*(self: Service): seq[Network] =
  return self.settings.availableNetworks

method getCurrentNetworkDetails*(self: Service): Network =
  for n in self.settings.availableNetworks:
    if(n.id == self.getCurrentNetwork()):
      return n
  
  # we should never be here
  error "error: current network is not among available networks"

method getCurrentNetworkId*(self: Service): int =
  self.getCurrentNetworkDetails().config.networkId

method getCurrentUserStatus*(self: Service): CurrentUserStatus =
  self.settings.currentUserStatus

method getPinnedMailservers*(self: Service): PinnedMailservers =
  self.settings.pinnedMailservers

method getWalletVisibleTokens*(self: Service): seq[string] =
  self.settings.walletVisibleTokens.tokens

method saveWalletVisibleTokens*(self: Service, tokens: seq[string]): bool =
  var obj = newJObject()
  obj[self.getCurrentNetwork()] = %* tokens
  if(self.saveSetting(KEY_WALLET_VISIBLE_TOKENS, obj)):
    self.settings.walletVisibleTokens.tokens = tokens
    return true
  return false

method saveNodeConfiguration*(self: Service, value: JsonNode): bool =
  if(self.saveSetting(KEY_NODE_CONFIG, value)):
    self.settings.nodeConfig = value
    return true
  return false

method saveWakuBloomFilterMode*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_WAKU_BLOOM_FILTER_MODE, value)):
    self.settings.wakuBloomFilterMode = value
    return true
  return false