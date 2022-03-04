import chronicles, json, strutils, sequtils, tables, sugar

import ../../common/[network_constants]
import ../../../app/core/fleets/fleet_configuration
import service_interface, ./dto/settings
import ../../../backend/settings as status_settings

export service_interface
export settings

logScope:
  topics = "settings-service"

type
  Service* = ref object of service_interface.ServiceInterface
    settings: SettingsDto
    eip1559Enabled*: bool

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.eip1559Enabled = false

method init*(self: Service) =
  try:
    let response = status_settings.getSettings()
    self.settings = response.result.toSettingsDto()
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc saveSetting(self: Service, attribute: string, value: string | JsonNode | bool | int): bool =
  let response = status_settings.saveSettings(attribute, value)
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

method savePreferredName*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_PREFERRED_NAME, value)):
    self.settings.preferredName = value
    return true
  return false

method getPreferredName*(self: Service): string =
  return self.settings.preferredName

method saveNewEnsUsername*(self: Service, username: string): bool =
  var newEnsUsernames = self.settings.ensUsernames
  newEnsUsernames.add(username)
  let newEnsUsernamesAsJson = %* newEnsUsernames

  if(self.saveSetting(KEY_ENS_USERNAMES, newEnsUsernamesAsJson)):
    self.settings.ensUsernames = newEnsUsernames
    return true
  return false

method getEnsUsernames*(self: Service): seq[string] =
  return self.settings.ensUsernames

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

method getFleetAsString*(self: Service): string =
  if(self.settings.fleet.len == 0):
    self.settings.fleet = DEFAULT_FLEET
  return self.settings.fleet

method getFleet*(self: Service): Fleet =
  let fleetAsString = self.getFleetAsString()
  let fleet = parseEnum[Fleet](fleetAsString)
  return fleet

method getAvailableNetworks*(self: Service): seq[Network] =
  return self.settings.availableNetworks

method getAvailableCustomNetworks*(self: Service): seq[Network] =
  return self.settings.availableNetworks.filterIt(it.id notin DEFAULT_NETWORKS_IDS)

method getCurrentNetworkDetails*(self: Service): Network =
  for n in self.settings.availableNetworks:
    if(n.id == self.getCurrentNetwork()):
      return n

  # we should never be here
  error "error: current network is not among available networks"

method addCustomNetwork*(self: Service, network: Network): bool =
  var newAvailableNetworks = self.settings.availableNetworks
  newAvailableNetworks.add(network)
  let availableNetworksAsJson = availableNetworksToJsonNode(newAvailableNetworks)

  if(self.saveSetting(KEY_NETWORKS_ALL_NETWORKS, availableNetworksAsJson)):
    self.settings.availableNetworks = newAvailableNetworks
    return true
  return false

method getCurrentNetworkId*(self: Service): int =
  self.getCurrentNetworkDetails().config.NetworkId

method getCurrentUserStatus*(self: Service): CurrentUserStatus =
  self.settings.currentUserStatus

method getPinnedMailserver*(self: Service, fleet: Fleet): string =
  if (fleet == Fleet.Prod):
    return self.settings.pinnedMailserver.ethProd
  elif (fleet == Fleet.Staging):
    return self.settings.pinnedMailserver.ethStaging
  elif (fleet == Fleet.Test):
    return self.settings.pinnedMailserver.ethTest
  elif (fleet == Fleet.WakuV2Prod):
    return self.settings.pinnedMailserver.wakuv2Prod
  elif (fleet == Fleet.WakuV2Test):
    return self.settings.pinnedMailserver.wakuv2Test
  elif (fleet == Fleet.GoWakuTest):
    return self.settings.pinnedMailserver.goWakuTest
  elif (fleet == Fleet.StatusTest):
      return self.settings.pinnedMailserver.statusTest
  return ""

method pinMailserver*(self: Service, address: string, fleet: Fleet): bool =
  var newMailserverJsonObj = self.settings.pinnedMailserver.pinnedMailserverToJsonNode()
  newMailserverJsonObj[$fleet] = %* address
  if(self.saveSetting(KEY_PINNED_MAILSERVERS, newMailserverJsonObj)):
    if (fleet == Fleet.Prod):
      self.settings.pinnedMailserver.ethProd = address
    elif (fleet == Fleet.Staging):
      self.settings.pinnedMailserver.ethStaging = address
    elif (fleet == Fleet.Test):
      self.settings.pinnedMailserver.ethTest = address
    elif (fleet == Fleet.WakuV2Prod):
      self.settings.pinnedMailserver.wakuv2Prod = address
    elif (fleet == Fleet.WakuV2Test):
      self.settings.pinnedMailserver.wakuv2Test = address
    elif (fleet == Fleet.GoWakuTest):
      self.settings.pinnedMailserver.goWakuTest = address
    elif (fleet == Fleet.StatusTest):
      self.settings.pinnedMailserver.statusTest = address
    return true
  return false

method unpinMailserver*(self: Service, fleet: Fleet): bool =
  return self.pinMailserver("", fleet)

method getWalletVisibleTokens*(self: Service): Table[int, seq[string]] =
  self.settings.walletVisibleTokens

method saveWalletVisibleTokens*(self: Service, visibleTokens: Table[int, seq[string]]): bool =
  var obj = newJObject()
  for chainId, tokens in visibleTokens.pairs:
    obj[$chainId] = %* tokens
  
  if(self.saveSetting(KEY_WALLET_VISIBLE_TOKENS, obj)):
    self.settings.walletVisibleTokens = visibleTokens
    return true
  
  return false

method getRecentStickers*(self: Service): seq[string] =
  result = self.settings.recentStickerHashes

method saveRecentStickers*(self: Service, recentStickers: seq[StickerDto]): bool =
  let json = %(recentStickers.mapIt($it.hash))
  if(self.saveSetting(KEY_RECENT_STICKERS, json)):
    self.settings.recentStickerHashes = recentStickers.map(s => s.hash)
    return true
  return false

method getInstalledStickerPacks*(self: Service): Table[int, StickerPackDto] =
  result = self.settings.installedStickerPacks

method saveRecentStickers*(self: Service, installedStickerPacks: Table[int, StickerPackDto]): bool =
  let json = %* {}
  for packId, pack in installedStickerPacks.pairs:
    json[$packId] = %(pack)

  if(self.saveSetting(KEY_INSTALLED_STICKER_PACKS, json)):
    self.settings.installedStickerPacks = installedStickerPacks
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

method saveAutoMessageEnabled*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_AUTO_MESSAGE_ENABLED, value)):
    self.settings.autoMessageEnabled = value
    return true
  return false

method autoMessageEnabled*(self: Service): bool =
  return self.settings.autoMessageEnabled

method getWakuBloomFilterMode*(self: Service): bool =
  return self.settings.wakuBloomFilterMode


