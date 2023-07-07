import Tables, json, options, tables, strutils
import ../../stickers/dto/stickers

include  ../../../common/json_utils
from ../../../common/types import StatusType
from ../../../common/conversion import intToEnum

# Setting keys:
const KEY_ADDRESS* = "address"
const KEY_CURRENCY* = "currency"
const KEY_DAPPS_ADDRESS* = "dapps-address"
const KEY_EIP1581_ADDRESS* = "eip1581-address"
const KEY_INSTALLATION_ID* = "installation-id"
const KEY_PREFERRED_NAME* = "preferred-name"
const KEY_ENS_USERNAMES* = "usernames"
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
const KEY_USE_MAILSERVERS* = "use-mailservers?"
const KEY_WALLET_ROOT_ADDRESS* = "wallet-root-address"
const KEY_SEND_STATUS_UPDATES* = "send-status-updates?"
const KEY_TELEMETRY_SERVER_URL* = "telemetry-server-url"
const KEY_PINNED_MAILSERVERS* = "pinned-mailservers"
const KEY_CURRENT_USER_STATUS* = "current-user-status"
const KEY_RECENT_STICKERS* = "stickers/recent-stickers"
const KEY_INSTALLED_STICKER_PACKS* = "stickers/packs-installed"
const KEY_FLEET* = "fleet"
const KEY_NODE_CONFIG* = "node-config"
const KEY_WAKU_BLOOM_FILTER_MODE* = "waku-bloom-filter-mode"
const KEY_AUTO_MESSAGE_ENABLED* = "auto-message-enabled?"
const KEY_GIF_FAVORITES* = "gifs/favorite-gifs"
const KEY_GIF_RECENTS* = "gifs/recent-gifs"
const KEY_GIF_API_KEY* = "gifs/api-key"
const KEY_DISPLAY_NAME* = "display-name"
const KEY_BIO* = "bio"
const KEY_TEST_NETWORKS_ENABLED* = "test-networks-enabled?"
const INCLUDE_WATCH_ONLY_ACCOUNT* = "include-watch-only-account?"

# Notifications Settings Values
const VALUE_NOTIF_SEND_ALERTS* = "SendAlerts"
const VALUE_NOTIF_DELIVER_QUIETLY* = "DeliverQuietly"
const VALUE_NOTIF_TURN_OFF* = "TurnOff"

const PROFILE_PICTURES_VISIBILITY_CONTACTS_ONLY* = 1
const PROFILE_PICTURES_VISIBILITY_EVERYONE* = 2
const PROFILE_PICTURES_VISIBILITY_NO_ONE* = 3

const PROFILE_PICTURES_SHOW_TO_CONTACTS_ONLY* = 1
const PROFILE_PICTURES_SHOW_TO_EVERYONE* = 2
const PROFILE_PICTURES_SHOW_TO_NO_ONE* = 3

type NotificationsExemptions* = object
  muteAllMessages*: bool
  personalMentions*: string
  globalMentions*: string
  otherMessages*: string

type UpstreamConfig* = object
  Enabled*: bool
  URL*: string

type PinnedMailserver* = object
  ethProd*: string
  ethStaging*: string
  wakuv2Prod*: string
  wakuv2Test*: string
  goWakuTest*: string
  statusTest*: string
  statusProd*: string

type CurrentUserStatus* = object
  statusType*: StatusType
  clock*: int64
  text*: string

type
  SettingsFieldDto* = object
    name*: string
    value*: JsonNode

type
  SettingsDto* = object # There is no point to keep all these info as settings, but we must follow status-go response
    address*: string
    currency*: string
    dappsAddress*: string
    eip1581Address*: string
    installationId*: string
    displayName*: string
    bio*: string
    preferredName*: string
    ensUsernames*: seq[string]
    keyUid*: string
    latestDerivedPath*: int
    linkPreviewRequestEnabled*: bool
    messagesFromContactsOnly*: bool
    mnemonic*: string
    name*: string # user alias
    photoPath*: string
    pinnedMailserver*: PinnedMailserver
    previewPrivacy*: bool
    publicKey*: string
    signingPhrase*: string
    defaultSyncPeriod*: int
    sendPushNotifications*: bool
    appearance*: int
    useMailservers*: bool
    walletRootAddress*: string
    sendStatusUpdates*: bool
    telemetryServerUrl*: string
    fleet*: string
    currentUserStatus*: CurrentUserStatus
    nodeConfig*: JsonNode
    wakuBloomFilterMode*: bool
    autoMessageEnabled*: bool
    gifRecents*: JsonNode
    gifFavorites*: JsonNode
    testNetworksEnabled*: bool
    notificationsAllowNotifications*: bool
    notificationsOneToOneChats*: string
    notificationsGroupChats*: string
    notificationsPersonalMentions*: string
    notificationsGlobalMentions*: string
    notificationsAllMessages*: string
    notificationsContactRequests*: string
    notificationsIdentityVerificationRequests*: string
    notificationsSoundsEnabled*: bool
    notificationsVolume*: int
    notificationsMessagePreview*: int
    includeWatchOnlyAccount*: bool

proc toPinnedMailserver*(jsonObj: JsonNode): PinnedMailserver =
  # we maintain pinned mailserver per fleet
  discard jsonObj.getProp("eth.prod", result.ethProd)
  discard jsonObj.getProp("eth.staging", result.ethStaging)
  discard jsonObj.getProp("wakuv2.prod", result.wakuv2Prod)
  discard jsonObj.getProp("wakuv2.test", result.wakuv2Test)
  discard jsonObj.getProp("go-waku.test", result.goWakuTest)
  discard jsonObj.getProp("status.test", result.statusTest)
  discard jsonObj.getProp("status.prod", result.statusProd)

proc toCurrentUserStatus*(jsonObj: JsonNode): CurrentUserStatus =
  var statusTypeInt: int
  discard jsonObj.getProp("statusType", statusTypeInt)
  result.statusType = intToEnum(statusTypeInt, StatusType.Unknown)
  discard jsonObj.getProp("clock", result.clock)
  discard jsonObj.getProp("text", result.text)

proc toSettingsFieldDto*(jsonObj: JsonNode): SettingsFieldDto =
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("value", result.value)

proc toSettingsDto*(jsonObj: JsonNode): SettingsDto =
  discard jsonObj.getProp(KEY_ADDRESS, result.address)
  discard jsonObj.getProp(KEY_CURRENCY, result.currency)
  discard jsonObj.getProp(KEY_DAPPS_ADDRESS, result.dappsAddress)
  discard jsonObj.getProp(KEY_EIP1581_ADDRESS, result.eip1581Address)
  discard jsonObj.getProp(KEY_INSTALLATION_ID, result.installationId)
  discard jsonObj.getProp(KEY_PREFERRED_NAME, result.preferredName)
  discard jsonObj.getProp(KEY_DISPLAY_NAME, result.displayName)
  discard jsonObj.getProp(KEY_BIO, result.bio)
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
  discard jsonObj.getProp(KEY_USE_MAILSERVERS, result.useMailservers)
  discard jsonObj.getProp(KEY_WALLET_ROOT_ADDRESS, result.walletRootAddress)
  discard jsonObj.getProp(KEY_SEND_STATUS_UPDATES, result.sendStatusUpdates)
  discard jsonObj.getProp(KEY_TELEMETRY_SERVER_URL, result.telemetryServerUrl)
  discard jsonObj.getProp(KEY_FLEET, result.fleet)
  discard jsonObj.getProp(KEY_AUTO_MESSAGE_ENABLED, result.autoMessageEnabled)
  discard jsonObj.getProp(KEY_GIF_RECENTS, result.gifRecents)
  discard jsonObj.getProp(KEY_GIF_FAVORITES, result.gifFavorites)
  discard jsonObj.getProp(KEY_TEST_NETWORKS_ENABLED, result.testNetworksEnabled)
  discard jsonObj.getProp(INCLUDE_WATCH_ONLY_ACCOUNT, result.includeWatchOnlyAccount)

  var pinnedMailserverObj: JsonNode
  if(jsonObj.getProp(KEY_PINNED_MAILSERVERS, pinnedMailserverObj)):
    result.pinnedMailserver = toPinnedMailserver(pinnedMailserverObj)

  var currentUserStatusObj: JsonNode
  if(jsonObj.getProp(KEY_CURRENT_USER_STATUS, currentUserStatusObj)):
    result.currentUserStatus = toCurrentUserStatus(currentUserStatusObj)

  discard jsonObj.getProp(KEY_NODE_CONFIG, result.nodeConfig)
  discard jsonObj.getProp(KEY_WAKU_BLOOM_FILTER_MODE, result.wakuBloomFilterMode)

  var usernamesArr: JsonNode
  if(jsonObj.getProp(KEY_ENS_USERNAMES, usernamesArr)):
    if(usernamesArr.kind == JArray):
      for username in usernamesArr:
        result.ensUsernames.add(username.getStr)

proc pinnedMailserverToJsonNode*(mailserver: PinnedMailserver): JsonNode =
  return %*{
    "eth.prod": mailserver.ethProd,
    "eth.staging": mailserver.ethStaging,
    "wakuv2.prod": mailserver.wakuv2Prod,
    "wakuv2.test": mailserver.wakuv2Test,
    "go-waku.test": mailserver.goWakuTest,
    "status.test": mailserver.statusTest,
    "status.prod": mailserver.statusProd
  }
