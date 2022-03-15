import chronicles, json, strutils, sequtils, tables, sugar

import ../../common/[network_constants]
import ../../../app/core/fleets/fleet_configuration
import ../../../backend/settings as status_settings

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

logScope:
  topics = "settings-service"

type
  Service* = ref object of RootObj
    settings: SettingsDto
    eip1559Enabled*: bool

proc delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.eip1559Enabled = false

proc init*(self: Service) =
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

proc saveAddress*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_ADDRESS, value)):
    self.settings.address = value
    return true
  return false

proc getAddress*(self: Service): string =
  return self.settings.address

proc saveCurrency*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_CURRENCY, value)):
    self.settings.currency = value
    return true
  return false

proc getCurrency*(self: Service): string =
  if(self.settings.currency.len == 0):
    self.settings.currency = DEFAULT_CURRENCY

  return self.settings.currency

proc saveCurrentNetwork*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_NETWORKS_CURRENT_NETWORK, value)):
    self.settings.currentNetwork = value
    return true
  return false

proc getCurrentNetwork*(self: Service): string =
  if(self.settings.currentNetwork.len == 0):
    self.settings.currentNetwork = DEFAULT_CURRENT_NETWORK

  return self.settings.currentNetwork

proc saveDappsAddress*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_DAPPS_ADDRESS, value)):
    self.settings.dappsAddress = value
    return true
  return false

proc getDappsAddress*(self: Service): string =
  return self.settings.dappsAddress

proc saveEip1581Address*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_EIP1581_ADDRESS, value)):
    self.settings.eip1581Address = value
    return true
  return false

proc getEip1581Address*(self: Service): string =
  return self.settings.eip1581Address

proc saveInstallationId*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_INSTALLATION_ID, value)):
    self.settings.installationId = value
    return true
  return false

proc getInstallationId*(self: Service): string =
  return self.settings.installationId

proc savePreferredName*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_PREFERRED_NAME, value)):
    self.settings.preferredName = value
    return true
  return false

proc getPreferredName*(self: Service): string =
  return self.settings.preferredName

proc getDisplayName*(self: Service): string =
  return self.settings.displayName

proc saveNewEnsUsername*(self: Service, username: string): bool =
  var newEnsUsernames = self.settings.ensUsernames
  newEnsUsernames.add(username)
  let newEnsUsernamesAsJson = %* newEnsUsernames

  if(self.saveSetting(KEY_ENS_USERNAMES, newEnsUsernamesAsJson)):
    self.settings.ensUsernames = newEnsUsernames
    return true
  return false

proc getEnsUsernames*(self: Service): seq[string] =
  return self.settings.ensUsernames

proc saveKeyUid*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_KEY_UID, value)):
    self.settings.keyUid = value
    return true
  return false

proc getKeyUid*(self: Service): string =
  return self.settings.keyUid

proc saveLatestDerivedPath*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_LATEST_DERIVED_PATH, value)):
    self.settings.latestDerivedPath = value
    return true
  return false

proc getLatestDerivedPath*(self: Service): int =
  self.settings.latestDerivedPath

proc saveLinkPreviewRequestEnabled*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_LINK_PREVIEW_REQUEST_ENABLED, value)):
    self.settings.linkPreviewRequestEnabled = value
    return true
  return false

proc getLinkPreviewRequestEnabled*(self: Service): bool =
  self.settings.linkPreviewRequestEnabled

proc saveMessagesFromContactsOnly*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_MESSAGES_FROM_CONTACTS_ONLY, value)):
    self.settings.messagesFromContactsOnly = value
    return true
  return false

proc getMessagesFromContactsOnly*(self: Service): bool =
  self.settings.messagesFromContactsOnly

proc saveMnemonic*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_MNEMONIC, value)):
    self.settings.mnemonic = value
    return true
  return false

proc getMnemonic*(self: Service): string =
  return self.settings.mnemonic

proc saveName*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_NAME, value)):
    self.settings.name = value
    return true
  return false

proc getName*(self: Service): string =
  return self.settings.name

proc savePhotoPath*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_PHOTO_PATH, value)):
    self.settings.photoPath = value
    return true
  return false

proc getPhotoPath*(self: Service): string =
  return self.settings.photoPath

proc savePreviewPrivacy*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_PREVIEW_PRIVACY, value)):
    self.settings.previewPrivacy = value
    return true
  return false

proc getPreviewPrivacy*(self: Service): bool =
  self.settings.previewPrivacy

proc savePublicKey*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_PUBLIC_KEY, value)):
    self.settings.publicKey = value
    return true
  return false

proc getPublicKey*(self: Service): string =
  return self.settings.publicKey

proc saveSigningPhrase*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_SIGNING_PHRASE, value)):
    self.settings.signingPhrase = value
    return true
  return false

proc getSigningPhrase*(self: Service): string =
  return self.settings.signingPhrase

proc saveDefaultSyncPeriod*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_DEFAULT_SYNC_PERIOD, value)):
    self.settings.defaultSyncPeriod = value
    return true
  return false

proc getDefaultSyncPeriod*(self: Service): int =
  self.settings.defaultSyncPeriod

proc saveSendPushNotifications*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_SEND_PUSH_NOTIFICATIONS, value)):
    self.settings.sendPushNotifications = value
    return true
  return false

proc getSendPushNotifications*(self: Service): bool =
  self.settings.sendPushNotifications

proc saveAppearance*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_APPEARANCE, value)):
    self.settings.appearance = value
    return true
  return false

proc getAppearance*(self: Service): int =
  self.settings.appearance

proc saveProfilePicturesShowTo*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_PROFILE_PICTURES_SHOW_TO, value)):
    self.settings.profilePicturesShowTo = value
    return true
  return false

proc getProfilePicturesShowTo*(self: Service): int =
  self.settings.profilePicturesShowTo

proc saveProfilePicturesVisibility*(self: Service, value: int): bool =
  if(self.saveSetting(KEY_PROFILE_PICTURES_VISIBILITY, value)):
    self.settings.profilePicturesVisibility = value
    return true
  return false

proc getProfilePicturesVisibility*(self: Service): int =
  self.settings.profilePicturesVisibility

proc saveUseMailservers*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_USE_MAILSERVERS, value)):
    self.settings.useMailservers = value
    return true
  return false

proc getUseMailservers*(self: Service): bool =
  self.settings.useMailservers

proc saveWalletRootAddress*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_WALLET_ROOT_ADDRESS, value)):
    self.settings.walletRootAddress = value
    return true
  return false

proc getWalletRootAddress*(self: Service): string =
  return self.settings.walletRootAddress

proc saveSendStatusUpdates*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_SEND_STATUS_UPDATES, value)):
    self.settings.sendStatusUpdates = value
    return true
  return false

proc getSendStatusUpdates*(self: Service): bool =
  self.settings.sendStatusUpdates

proc saveTelemetryServerUrl*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_TELEMETRY_SERVER_URL, value)):
    self.settings.telemetryServerUrl = value
    return true
  return false

proc getTelemetryServerUrl*(self: Service): string =
  return self.settings.telemetryServerUrl

proc saveFleet*(self: Service, value: string): bool =
  if(self.saveSetting(KEY_FLEET, value)):
    self.settings.fleet = value
    return true
  return false

proc getFleetAsString*(self: Service): string =
  if(self.settings.fleet.len == 0):
    self.settings.fleet = DEFAULT_FLEET
  return self.settings.fleet

proc getFleet*(self: Service): Fleet =
  let fleetAsString = self.getFleetAsString()
  let fleet = parseEnum[Fleet](fleetAsString)
  return fleet

proc getAvailableNetworks*(self: Service): seq[Network] =
  return self.settings.availableNetworks

proc getAvailableCustomNetworks*(self: Service): seq[Network] =
  return self.settings.availableNetworks.filterIt(it.id notin DEFAULT_NETWORKS_IDS)

proc getCurrentNetworkDetails*(self: Service): Network =
  for n in self.settings.availableNetworks:
    if(n.id == self.getCurrentNetwork()):
      return n

  # we should never be here
  error "error: current network is not among available networks"

proc addCustomNetwork*(self: Service, network: Network): bool =
  var newAvailableNetworks = self.settings.availableNetworks
  newAvailableNetworks.add(network)
  let availableNetworksAsJson = availableNetworksToJsonNode(newAvailableNetworks)

  if(self.saveSetting(KEY_NETWORKS_ALL_NETWORKS, availableNetworksAsJson)):
    self.settings.availableNetworks = newAvailableNetworks
    return true
  return false

proc getCurrentNetworkId*(self: Service): int =
  self.getCurrentNetworkDetails().config.NetworkId

proc getCurrentUserStatus*(self: Service): CurrentUserStatus =
  self.settings.currentUserStatus

proc getPinnedMailserver*(self: Service, fleet: Fleet): string =
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
  elif (fleet == Fleet.StatusProd):
    return self.settings.pinnedMailserver.statusProd
  return ""

proc pinMailserver*(self: Service, address: string, fleet: Fleet): bool =
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
    elif (fleet == Fleet.StatusProd):
      self.settings.pinnedMailserver.statusProd = address
    return true
  return false

proc unpinMailserver*(self: Service, fleet: Fleet): bool =
  return self.pinMailserver("", fleet)

proc getWalletVisibleTokens*(self: Service): Table[int, seq[string]] =
  self.settings.walletVisibleTokens

proc saveWalletVisibleTokens*(self: Service, visibleTokens: Table[int, seq[string]]): bool =
  var obj = newJObject()
  for chainId, tokens in visibleTokens.pairs:
    obj[$chainId] = %* tokens
  
  if(self.saveSetting(KEY_WALLET_VISIBLE_TOKENS, obj)):
    self.settings.walletVisibleTokens = visibleTokens
    return true
  
  return false

proc isEIP1559Enabled*(self: Service, blockNumber: int): bool =
  let networkId = self.getCurrentNetworkDetails().config.NetworkId
  let activationBlock = case networkId:
    of 3: 10499401 # Ropsten
    of 4: 8897988 # Rinkeby
    of 5: 5062605 # Goerli
    of 1: 12965000 # Mainnet
    else: -1
  if activationBlock > -1 and blockNumber >= activationBlock:
    result = true
  else:
    result = false
  self.eip1559Enabled = result

proc isEIP1559Enabled*(self: Service): bool =
  result = self.eip1559Enabled

proc saveNodeConfiguration*(self: Service, value: JsonNode): bool =
  if(self.saveSetting(KEY_NODE_CONFIG, value)):
    self.settings.nodeConfig = value
    return true
  return false

proc saveWakuBloomFilterMode*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_WAKU_BLOOM_FILTER_MODE, value)):
    self.settings.wakuBloomFilterMode = value
    return true
  return false

proc saveAutoMessageEnabled*(self: Service, value: bool): bool =
  if(self.saveSetting(KEY_AUTO_MESSAGE_ENABLED, value)):
    self.settings.autoMessageEnabled = value
    return true
  return false

proc autoMessageEnabled*(self: Service): bool =
  return self.settings.autoMessageEnabled

proc getWakuBloomFilterMode*(self: Service): bool =
  return self.settings.wakuBloomFilterMode

method areTestNetworksEnabled*(self: Service): bool =
  return self.settings.testNetworksEnabled

method toggleTestNetworksEnabled*(self: Service): bool =
  let newValue = not self.settings.testNetworksEnabled
  if(self.saveSetting(KEY_TEST_NETWORKS_ENABLED, newValue)):
    self.settings.testNetworksEnabled = newValue
    return true
  return false


