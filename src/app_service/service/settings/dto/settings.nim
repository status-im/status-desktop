import json, options

include  ../../../common/json_utils

type UpstreamConfig* = object
  enabled*: bool
  url*: string

type Config* = object
  networkId*: int
  dataDir*: string
  upstreamConfig*: UpstreamConfig

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

proc toUpstreamConfig*(jsonObj: JsonNode): UpstreamConfig =
  discard jsonObj.getProp("Enabled", result.enabled)
  discard jsonObj.getProp("URL", result.url)

proc toConfig*(jsonObj: JsonNode): Config =
  discard jsonObj.getProp("NetworkId", result.networkId)
  discard jsonObj.getProp("DataDir", result.dataDir)

  var upstreamConfigObj: JsonNode
  if(jsonObj.getProp("UpstreamConfig", upstreamConfigObj)):
    result.upstreamConfig = toUpstreamConfig(upstreamConfigObj)

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

  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("currency", result.currency)
  discard jsonObj.getProp("networks/current-network", result.currentNetwork)

  var networksArr: JsonNode
  if(jsonObj.getProp("networks/networks", networksArr)):
    if(networksArr.kind == JArray):
      for networkObj in networksArr:
        result.availableNetworks.add(toNetwork(networkObj))

  discard jsonObj.getProp("dapps-address", result.dappsAddress)
  discard jsonObj.getProp("eip1581-address", result.eip1581Address)
  discard jsonObj.getProp("installation-id", result.installationId)
  discard jsonObj.getProp("key-uid", result.keyUid)
  discard jsonObj.getProp("latest-derived-path", result.latestDerivedPath)
  discard jsonObj.getProp("link-preview-request-enabled", result.linkPreviewRequestEnabled)
  discard jsonObj.getProp("messages-from-contacts-only", result.messagesFromContactsOnly)
  discard jsonObj.getProp("mnemonic", result.mnemonic)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("photo-path", result.photoPath)
  discard jsonObj.getProp("preview-privacy?", result.previewPrivacy)
  discard jsonObj.getProp("public-key", result.publicKey)
  discard jsonObj.getProp("signing-phrase", result.signingPhrase)
  discard jsonObj.getProp("default-sync-period", result.defaultSyncPeriod)
  discard jsonObj.getProp("send-push-notifications?", result.sendPushNotifications)
  discard jsonObj.getProp("appearance", result.appearance)
  discard jsonObj.getProp("profile-pictures-show-to", result.profilePicturesShowTo)
  discard jsonObj.getProp("profile-pictures-visibility", result.profilePicturesVisibility)
  discard jsonObj.getProp("use-mailservers?", result.useMailservers)
  discard jsonObj.getProp("wallet-root-address", result.walletRootAddress)
  discard jsonObj.getProp("send-status-updates?", result.sendStatusUpdates)
  discard jsonObj.getProp("telemetry-server-url", result.telemetryServerUrl)
  discard jsonObj.getProp("fleet", result.fleet)

  var pinnedMailserversObj: JsonNode
  if(jsonObj.getProp("pinned-mailservers", pinnedMailserversObj)):
    result.pinnedMailservers = toPinnedMailservers(pinnedMailserversObj)

  var currentUserStatusObj: JsonNode
  if(jsonObj.getProp("current-user-status", currentUserStatusObj)):
    result.currentUserStatus = toCurrentUserStatus(currentUserStatusObj)

  var walletVisibleTokensObj: JsonNode
  if(jsonObj.getProp("wallet/visible-tokens", walletVisibleTokensObj)):
    result.walletVisibleTokens = toWalletVisibleTokens(walletVisibleTokensObj, result.currentNetwork)

  discard jsonObj.getProp("node-config", result.nodeConfig)
  discard jsonObj.getProp("waku-bloom-filter-mode", result.wakuBloomFilterMode)
