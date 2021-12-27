import json, options, tables, strutils, marshal
import ../../stickers/dto/stickers

include  ../../../common/json_utils

# Setting keys:
const KEY_ADDRESS* = "address"
const KEY_CURRENCY* = "currency"
const KEY_NETWORKS_CURRENT_NETWORK* = "networks/current-network"
const KEY_NETWORKS_ALL_NETWORKS* = "networks/networks"
const KEY_DAPPS_ADDRESS* = "dapps-address"
const KEY_EIP1581_ADDRESS* = "eip1581-address"
const KEY_INSTALLATION_ID* = "installation-id"
const KEY_PREFERRED_NAME* = "preferred-name"
const KEY_KEY_UID* = "key-uid"
const KEY_LATEST_DERIVED_PATH* = "latest-derived-path"
const KEY_LINK_PREVIEW_REQUEST_ENABLED* = "link-preview-request-enabled"
const KEY_MESSAGES_FROM_CONTACTS_ONLY* = "messages-from-contacts-only"
const KEY_MNEMONIC* = "mnemonic"
const KEY_NAME* = "name"
const KEY_PHOTO_PATH* = "photo-path"
const KEY_PREVIEW_PRIVACY* = "preview-privacy?"
const KEY_PUBLIC_KEY* = "public-key"
const KEY_SIGNING_PHRASE* = "signing-phrase"
const KEY_DEFAULT_SYNC_PERIOD* = "default-sync-period"
const KEY_SEND_PUSH_NOTIFICATIONS* = "send-push-notifications?"
const KEY_APPEARANCE* = "appearance"
const KEY_PROFILE_PICTURES_SHOW_TO* = "profile-pictures-show-to"
const KEY_PROFILE_PICTURES_VISIBILITY* = "profile-pictures-visibility"
const KEY_USE_MAILSERVERS* = "use-mailservers?"
const KEY_WALLET_ROOT_ADDRESS* = "wallet-root-address"
const KEY_SEND_STATUS_UPDATES* = "send-status-updates?"
const KEY_TELEMETRY_SERVER_URL* = "telemetry-server-url"
const KEY_WALLET_VISIBLE_TOKENS* = "wallet/visible-tokens"
const KEY_PINNED_MAILSERVERS* = "pinned-mailservers"
const KEY_CURRENT_USER_STATUS* = "current-user-status"
const KEY_RECENT_STICKERS* = "stickers/recent-stickers"
const KEY_INSTALLED_STICKER_PACKS* = "stickers/packs-installed"
const KEY_FLEET* = "fleet"
const KEY_NODE_CONFIG* = "node-config"
const KEY_WAKU_BLOOM_FILTER_MODE* = "waku-bloom-filter-mode"
const KEY_AUTO_MESSAGE_ENABLED* = "auto-message-enabled?"

type UpstreamConfig* = object
  Enabled*: bool
  URL*: string

type Config* = object
  NetworkId*: int
  DataDir*: string
  UpstreamConfig*: UpstreamConfig

type Network* = object
  id*: string
  etherscanLink*: string
  name*: string
  config*: Config

type PinnedMailservers* = object
  ethProd*: string

type CurrentUserStatus* = object
  statusType*: int
  clock*: int64
  text*: string

type WalletVisibleTokens* = object
  tokens*: seq[string] 

type
  SettingsDto* = object # There is no point to keep all these info as settings, but we must follow status-go response
    address*: string
    currency*: string
    currentNetwork*: string
    availableNetworks*: seq[Network]
    dappsAddress*: string
    eip1581Address*: string
    installationId*: string
    preferredName*: string
    keyUid*: string
    latestDerivedPath*: int
    linkPreviewRequestEnabled*: bool
    messagesFromContactsOnly*: bool
    mnemonic*: string
    name*: string # user alias
    photoPath*: string
    pinnedMailservers*: PinnedMailservers
    previewPrivacy*: bool
    publicKey*: string
    signingPhrase*: string
    defaultSyncPeriod*: int
    sendPushNotifications*: bool
    appearance*: int
    profilePicturesShowTo*: int
    profilePicturesVisibility*: int
    useMailservers*: bool
    walletRootAddress*: string
    sendStatusUpdates*: bool
    telemetryServerUrl*: string
    fleet*: string
    currentUserStatus*: CurrentUserStatus
    walletVisibleTokens*: WalletVisibleTokens
    nodeConfig*: JsonNode
    wakuBloomFilterMode*: bool
    recentStickerHashes*: seq[string]
    installedStickerPacks*: Table[int, StickerPackDto]
    autoMessageEnabled*: bool

proc toUpstreamConfig*(jsonObj: JsonNode): UpstreamConfig =
  discard jsonObj.getProp("Enabled", result.Enabled)
  discard jsonObj.getProp("URL", result.URL)

proc toConfig*(jsonObj: JsonNode): Config =
  discard jsonObj.getProp("NetworkId", result.NetworkId)
  discard jsonObj.getProp("DataDir", result.DataDir)

  var upstreamConfigObj: JsonNode
  if(jsonObj.getProp("UpstreamConfig", upstreamConfigObj)):
    result.UpstreamConfig = toUpstreamConfig(upstreamConfigObj)

proc toNetwork*(jsonObj: JsonNode): Network =
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("etherscan-link", result.etherscanLink)
  discard jsonObj.getProp("name", result.name)

  var configObj: JsonNode
  if(jsonObj.getProp("config", configObj)):
    result.config = toConfig(configObj)

proc toPinnedMailservers*(jsonObj: JsonNode): PinnedMailservers =
  discard jsonObj.getProp("eth.prod", result.ethProd)

proc toCurrentUserStatus*(jsonObj: JsonNode): CurrentUserStatus =
  discard jsonObj.getProp("statusType", result.statusType)
  discard jsonObj.getProp("clock", result.clock)
  discard jsonObj.getProp("text", result.text)

proc toWalletVisibleTokens*(jsonObj: JsonNode, networkId: string): WalletVisibleTokens =
  for netId, tokenArr in jsonObj:
    if(netId != networkId or tokenArr.kind != JArray):
      continue

    for token in tokenArr:
      result.tokens.add(token.getStr)

proc toSettingsDto*(jsonObj: JsonNode): SettingsDto =

  discard jsonObj.getProp(KEY_ADDRESS, result.address)
  discard jsonObj.getProp(KEY_CURRENCY, result.currency)
  discard jsonObj.getProp(KEY_NETWORKS_CURRENT_NETWORK, result.currentNetwork)

  var networksArr: JsonNode
  if(jsonObj.getProp(KEY_NETWORKS_ALL_NETWORKS, networksArr)):
    if(networksArr.kind == JArray):
      for networkObj in networksArr:
        result.availableNetworks.add(toNetwork(networkObj))

  var installedStickerPacksArr: JsonNode
  if(jsonObj.getProp(KEY_INSTALLED_STICKER_PACKS, installedStickerPacksArr)):
    if(installedStickerPacksArr.kind == JObject):
      result.installedStickerPacks = initTable[int, StickerPackDto]()
      for i in installedStickerPacksArr.keys:
        let packId = parseInt(i)
        result.installedStickerPacks[packId] = installedStickerPacksArr[i].toStickerPackDto

    
  var recentStickersArr: JsonNode
  if(jsonObj.getProp(KEY_RECENT_STICKERS, recentStickersArr)):
    if(recentStickersArr.kind == JArray):
      for stickerHash in recentStickersArr:
        result.recentStickerHashes.add(stickerHash.getStr)

  discard jsonObj.getProp(KEY_DAPPS_ADDRESS, result.dappsAddress)
  discard jsonObj.getProp(KEY_EIP1581_ADDRESS, result.eip1581Address)
  discard jsonObj.getProp(KEY_INSTALLATION_ID, result.installationId)
  discard jsonObj.getProp(KEY_PREFERRED_NAME, result.preferredName)
  discard jsonObj.getProp(KEY_KEY_UID, result.keyUid)
  discard jsonObj.getProp(KEY_LATEST_DERIVED_PATH, result.latestDerivedPath)
  discard jsonObj.getProp(KEY_LINK_PREVIEW_REQUEST_ENABLED, result.linkPreviewRequestEnabled)
  discard jsonObj.getProp(KEY_MESSAGES_FROM_CONTACTS_ONLY, result.messagesFromContactsOnly)
  discard jsonObj.getProp(KEY_MNEMONIC, result.mnemonic)
  discard jsonObj.getProp(KEY_NAME, result.name)
  discard jsonObj.getProp(KEY_PHOTO_PATH, result.photoPath)
  discard jsonObj.getProp(KEY_PREVIEW_PRIVACY, result.previewPrivacy)
  discard jsonObj.getProp(KEY_PUBLIC_KEY, result.publicKey)
  discard jsonObj.getProp(KEY_SIGNING_PHRASE, result.signingPhrase)
  discard jsonObj.getProp(KEY_DEFAULT_SYNC_PERIOD, result.defaultSyncPeriod)
  discard jsonObj.getProp(KEY_SEND_PUSH_NOTIFICATIONS, result.sendPushNotifications)
  discard jsonObj.getProp(KEY_APPEARANCE, result.appearance)
  discard jsonObj.getProp(KEY_PROFILE_PICTURES_SHOW_TO, result.profilePicturesShowTo)
  discard jsonObj.getProp(KEY_PROFILE_PICTURES_VISIBILITY, result.profilePicturesVisibility)
  discard jsonObj.getProp(KEY_USE_MAILSERVERS, result.useMailservers)
  discard jsonObj.getProp(KEY_WALLET_ROOT_ADDRESS, result.walletRootAddress)
  discard jsonObj.getProp(KEY_SEND_STATUS_UPDATES, result.sendStatusUpdates)
  discard jsonObj.getProp(KEY_TELEMETRY_SERVER_URL, result.telemetryServerUrl)
  discard jsonObj.getProp(KEY_FLEET, result.fleet)
  discard jsonObj.getProp(KEY_AUTO_MESSAGE_ENABLED, result.autoMessageEnabled)

  var pinnedMailserversObj: JsonNode
  if(jsonObj.getProp(KEY_PINNED_MAILSERVERS, pinnedMailserversObj)):
    result.pinnedMailservers = toPinnedMailservers(pinnedMailserversObj)

  var currentUserStatusObj: JsonNode
  if(jsonObj.getProp(KEY_CURRENT_USER_STATUS, currentUserStatusObj)):
    result.currentUserStatus = toCurrentUserStatus(currentUserStatusObj)

  var walletVisibleTokensObj: JsonNode
  if(jsonObj.getProp(KEY_WALLET_VISIBLE_TOKENS, walletVisibleTokensObj)):
    result.walletVisibleTokens = toWalletVisibleTokens(walletVisibleTokensObj, result.currentNetwork)

  discard jsonObj.getProp(KEY_NODE_CONFIG, result.nodeConfig)
  discard jsonObj.getProp(KEY_WAKU_BLOOM_FILTER_MODE, result.wakuBloomFilterMode)

proc configToJsonNode*(config: Config): JsonNode =
  let configAsString = $$config
  result = parseJson(configAsString)

proc networkToJsonNode*(network: Network): JsonNode =
  ## we cannot use the same technique as we did for `configToJsonNode` cause we cannot have 
  ## variable name with a dash in order to map `etherscan-link` appropriatelly
  return %*{
    "id": network.id,
    "etherscan-link": network.etherscanLink,
    "name": network.name,
    "config": configToJsonNode(network.config)
  }

proc availableNetworksToJsonNode*(networks: seq[Network]): JsonNode =
  var availableNetworksAsJson = newJArray()
  for n in networks:
    availableNetworksAsJson.add(networkToJsonNode(n))
  return availableNetworksAsJson