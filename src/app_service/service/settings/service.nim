import NimQml, chronicles, json, strutils, sequtils, tables

import ../../common/types as common_types
import ../../common/social_links
import ../../common/utils as common_utils
import ../../../app/core/eventemitter
import ../../../app/core/fleets/fleet_configuration
import ../../../app/core/signals/types
import ../../../backend/settings as status_settings
import ../../../backend/status_update as status_update

import ./dto/settings as settings_dto
import ../stickers/dto/stickers as stickers_dto

export settings_dto
export stickers_dto

# Default values:
const DEFAULT_CURRENCY* = "USD"
const DEFAULT_TELEMETRY_SERVER_URL* = "https://telemetry.status.im"
const DEFAULT_FLEET* = $Fleet.StatusProd

# Signals:
const SIGNAL_CURRENCY_UPDATED* = "currencyUpdated"
const SIGNAL_DISPLAY_NAME_UPDATED* = "displayNameUpdated"
const SIGNAL_BIO_UPDATED* = "bioUpdated"
const SIGNAL_MNEMONIC_REMOVED* = "mnemonicRemoved"
const SIGNAL_SOCIAL_LINKS_UPDATED* = "socialLinksUpdated"
const SIGNAL_CURRENT_USER_STATUS_UPDATED* = "currentUserStatusUpdated"
const SIGNAL_INCLUDE_WATCH_ONLY_ACCOUNTS_UPDATED* = "includeWatchOnlyAccounts"

logScope:
  topics = "settings-service"

type
  SettingsTextValueArgs* = ref object of Args
    value*: string

  CurrentUserStatusArgs* = ref object of Args
    statusType*: StatusType
    text*: string

  SocialLinksArgs* = ref object of Args
    socialLinks*: SocialLinks
    error*: string

  SettingProfilePictureArgs* = ref object of Args
    value*: int

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    settings: SettingsDto
    socialLinks: SocialLinks
    initialized: bool
    notifExemptionsCache: Table[string, NotificationsExemptions]

  # Forward declaration
  proc storeSocialLinksAndNotify(self: Service, data: SocialLinksArgs)
  proc initNotificationSettings*(self: Service)
  proc getNotifSettingAllowNotifications*(self: Service): bool
  proc getNotifSettingOneToOneChats*(self: Service): string
  proc getNotifSettingGroupChats*(self: Service): string
  proc getNotifSettingPersonalMentions*(self: Service): string
  proc getNotifSettingGlobalMentions*(self: Service): string
  proc getNotifSettingAllMessages*(self: Service): string
  proc getNotifSettingContactRequests*(self: Service): string
  proc getNotifSettingIdentityVerificationRequests*(self: Service): string
  proc getNotificationSoundsEnabled*(self: Service): bool
  proc getNotificationVolume*(self: Service): int
  proc getNotificationMessagePreview*(self: Service): int

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter): Service =
    new(result, delete)
    result.events = events
    result.initialized = false
    result.notifExemptionsCache = initTable[string, NotificationsExemptions]()
    result.QObject.setup

  proc init*(self: Service) =
    try:
      let response = status_settings.getSettings()
      self.settings = response.result.toSettingsDto()
      self.initNotificationSettings()
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)

      if receivedData.currentStatus.len > 0:
        var statusUpdate = receivedData.currentStatus[0]
        self.events.emit(SIGNAL_CURRENT_USER_STATUS_UPDATED, CurrentUserStatusArgs(statusType: statusUpdate.statusType, text: statusUpdate.text))

      if receivedData.settings.len > 0:
        for settingsField in receivedData.settings:
          if settingsField.name == KEY_CURRENCY:
            self.settings.currency = settingsField.value.getStr
            self.events.emit(SIGNAL_CURRENCY_UPDATED, SettingsTextValueArgs(value: self.settings.currency))
          if settingsField.name == KEY_DISPLAY_NAME:
            self.settings.displayName = settingsField.value.getStr
            self.events.emit(SIGNAL_DISPLAY_NAME_UPDATED, SettingsTextValueArgs(value: self.settings.displayName))
          if settingsField.name == KEY_BIO:
            self.settings.bio = settingsField.value.getStr
            self.events.emit(SIGNAL_BIO_UPDATED, SettingsTextValueArgs(value: self.settings.bio))
          if settingsField.name == KEY_MNEMONIC:
            self.settings.mnemonic = ""
            self.events.emit(SIGNAL_MNEMONIC_REMOVED, Args())
          if settingsField.name == INCLUDE_WATCH_ONLY_ACCOUNT:
            self.settings.includeWatchOnlyAccount = settingsField.value.getBool
            self.events.emit(SIGNAL_INCLUDE_WATCH_ONLY_ACCOUNTS_UPDATED, Args())

      if receivedData.socialLinksInfo.links.len > 0 or
        receivedData.socialLinksInfo.removed:
          self.storeSocialLinksAndNotify(SocialLinksArgs(socialLinks: receivedData.socialLinksInfo.links))

    self.initialized = true

  proc initNotificationSettings(self: Service) =
    # set initial values from RPC before initialization is done
    # not interested in return values here
    discard self.getNotifSettingAllowNotifications()
    discard self.getNotifSettingOneToOneChats()
    discard self.getNotifSettingGroupChats()
    discard self.getNotifSettingPersonalMentions()
    discard self.getNotifSettingGlobalMentions()
    discard self.getNotifSettingAllMessages()
    discard self.getNotifSettingContactRequests()
    discard self.getNotifSettingIdentityVerificationRequests()
    discard self.getNotificationSoundsEnabled()
    discard self.getNotificationVolume()
    discard self.getNotificationMessagePreview()


  proc saveSetting(self: Service, attribute: string, value: string | JsonNode | bool | int): bool =
    try:
      let response = status_settings.saveSettings(attribute, value)
      if(not response.error.isNil):
        error "error saving settings: ", errDescription = response.error.message
        return false
      return true
    except Exception as e:
      let errDesription = e.msg
      error "saving settings error: ", errDesription
    return false

  proc saveAddress*(self: Service, value: string): bool =
    if(self.saveSetting(KEY_ADDRESS, value)):
      self.settings.address = value
      return true
    return false

  proc getAddress*(self: Service): string =
    return self.settings.address

  proc saveCurrency*(self: Service, value: string): bool =
    if(self.saveSetting(KEY_CURRENCY, value)):
      self.settings.currency = value.toLowerAscii()
      self.events.emit(SIGNAL_CURRENCY_UPDATED, SettingsTextValueArgs(value: self.settings.currency))
      return true
    return false

  proc getCurrency*(self: Service): string =
    if(self.settings.currency.len == 0):
      self.settings.currency = DEFAULT_CURRENCY

    return self.settings.currency.toUpperAscii()

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

  proc saveDisplayName*(self: Service, value: string): bool =
    if(self.saveSetting(KEY_DISPLAY_NAME, value)):
      self.settings.displayName = value
      self.events.emit(SIGNAL_DISPLAY_NAME_UPDATED, SettingsTextValueArgs(value: self.settings.displayName))
      return true
    return false

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
      self.events.emit(SIGNAL_MNEMONIC_REMOVED, Args())
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

  proc getSendStatusUpdates*(self: Service): bool =
    self.settings.sendStatusUpdates

  proc saveTelemetryServerUrl*(self: Service, value: string): bool =
    if(self.saveSetting(KEY_TELEMETRY_SERVER_URL, value)):
      self.settings.telemetryServerUrl = value
      return true
    return false

  proc getTelemetryServerUrl*(self: Service): string =
    return self.settings.telemetryServerUrl

  proc saveSendStatusUpdates*(self: Service, newStatus: StatusType): bool =
    try:
      # The new user status needs to always be broadcast, so we need to update
      # the settings accordingly and might turn it off afterwards (if user has
      # set status to "inactive")
      const propagateStatus = true
      if(self.saveSetting(KEY_SEND_STATUS_UPDATES, propagateStatus) != true):
          return false
      discard status_update.setUserStatus(newStatus.int)
      self.settings.currentUserStatus.statusType = newStatus
      let sendPingsWithStatusUpdates = (newStatus == StatusType.AlwaysOnline or newStatus == StatusType.Automatic)
      if(self.saveSetting(KEY_SEND_STATUS_UPDATES, sendPingsWithStatusUpdates)):
        self.settings.sendStatusUpdates = sendPingsWithStatusUpdates
        return true
      return false
    except:
      return false

  proc saveFleet*(self: Service, value: string): bool =
    self.settings.fleet = value
    return true

  proc getFleetAsString*(self: Service): string =
    result = self.settings.fleet

  proc getFleet*(self: Service): Fleet =
    let fleetAsString = self.getFleetAsString()
    return parseEnum[Fleet](fleetAsString)

  proc getCurrentUserStatus*(self: Service): CurrentUserStatus =
    self.settings.currentUserStatus

  proc getPinnedMailserver*(self: Service, fleet: Fleet): string =
    if (fleet == Fleet.Prod):
      return self.settings.pinnedMailserver.ethProd
    elif (fleet == Fleet.Staging):
      return self.settings.pinnedMailserver.ethStaging
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

  proc pinMailserver*(self: Service, mailserverID: string, fleet: Fleet): bool =
    var newMailserverJsonObj = self.settings.pinnedMailserver.pinnedMailserverToJsonNode()
    newMailserverJsonObj[$fleet] = %* mailserverID
    if(self.saveSetting(KEY_PINNED_MAILSERVERS, newMailserverJsonObj)):
      if (fleet == Fleet.Prod):
        self.settings.pinnedMailserver.ethProd = mailserverID
      elif (fleet == Fleet.Staging):
        self.settings.pinnedMailserver.ethStaging = mailserverID
      elif (fleet == Fleet.WakuV2Prod):
        self.settings.pinnedMailserver.wakuv2Prod = mailserverID
      elif (fleet == Fleet.WakuV2Test):
        self.settings.pinnedMailserver.wakuv2Test = mailserverID
      elif (fleet == Fleet.GoWakuTest):
        self.settings.pinnedMailserver.goWakuTest = mailserverID
      elif (fleet == Fleet.StatusTest):
        self.settings.pinnedMailserver.statusTest = mailserverID
      elif (fleet == Fleet.StatusProd):
        self.settings.pinnedMailserver.statusProd = mailserverID
      return true
    return false

  proc unpinMailserver*(self: Service, fleet: Fleet): bool =
    return self.pinMailserver("", fleet)

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

  proc setDefaultSyncPeriod*(self: Service, value: int): bool =
    if(self.saveSetting(KEY_DEFAULT_SYNC_PERIOD,value)):
      self.settings.defaultSyncPeriod = value
      return true
    return false

  proc getWakuBloomFilterMode*(self: Service): bool =
    return self.settings.wakuBloomFilterMode

  proc areTestNetworksEnabled*(self: Service): bool =
    return self.settings.testNetworksEnabled

  proc toggleTestNetworksEnabled*(self: Service): bool =
    let newValue = not self.settings.testNetworksEnabled
    if(self.saveSetting(KEY_TEST_NETWORKS_ENABLED, newValue)):
      self.settings.testNetworksEnabled = newValue
      return true
    return false

  proc notifSettingAllowNotificationsChanged*(self: Service) {.signal.}
  proc getNotifSettingAllowNotifications*(self: Service): bool {.slot.} =
    if self.initialized:
      return self.settings.notificationsAllowNotifications

    result = true #default value
    try:
      let response = status_settings.getAllowNotifications()
      if(not response.error.isNil):
        error "error reading allow notification setting: ", errDescription = response.error.message
        return
      result = response.result.getBool
      self.settings.notificationsAllowNotifications = result
    except Exception as e:
      let errDesription = e.msg
      error "reading allow notification setting error: ", errDesription

  proc setNotifSettingAllowNotifications*(self: Service, value: bool) {.slot.} =
    try:
      let response = status_settings.setAllowNotifications(value)
      if(not response.error.isNil):
        error "error saving allow notification setting: ", errDescription = response.error.message
        return
      self.settings.notificationsAllowNotifications = value
      self.notifSettingAllowNotificationsChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving allow notification setting error: ", errDesription

  QtProperty[bool] notifSettingAllowNotifications:
    read = getNotifSettingAllowNotifications
    write = setNotifSettingAllowNotifications
    notify = notifSettingAllowNotificationsChanged

  proc notifSettingOneToOneChatsChanged*(self: Service) {.signal.}
  proc getNotifSettingOneToOneChats*(self: Service): string {.slot.} =
    if self.initialized:
      return self.settings.notificationsOneToOneChats

    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getOneToOneChats()
      if(not response.error.isNil):
        error "error reading one to one setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
      self.settings.notificationsOneToOneChats = result
    except Exception as e:
      let errDesription = e.msg
      error "reading one to one setting error: ", errDesription

  proc setNotifSettingOneToOneChats*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setOneToOneChats(value)
      if(not response.error.isNil):
        error "error saving one to one setting: ", errDescription = response.error.message
        return
      self.settings.notificationsOneToOneChats = value
      self.notifSettingOneToOneChatsChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving one to one setting error: ", errDesription

  QtProperty[string] notifSettingOneToOneChats:
    read = getNotifSettingOneToOneChats
    write = setNotifSettingOneToOneChats
    notify = notifSettingOneToOneChatsChanged

  proc notifSettingGroupChatsChanged*(self: Service) {.signal.}
  proc getNotifSettingGroupChats*(self: Service): string {.slot.} =
    if self.initialized:
      return self.settings.notificationsGroupChats

    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getGroupChats()
      if(not response.error.isNil):
        error "error reading group chats setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
      self.settings.notificationsGroupChats = result
    except Exception as e:
      let errDesription = e.msg
      error "reading group chats setting error: ", errDesription

  proc setNotifSettingGroupChats*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setGroupChats(value)
      if(not response.error.isNil):
        error "error saving group chats setting: ", errDescription = response.error.message
        return
      self.settings.notificationsGroupChats = value
      self.notifSettingGroupChatsChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving group chats setting error: ", errDesription

  QtProperty[string] notifSettingGroupChats:
    read = getNotifSettingGroupChats
    write = setNotifSettingGroupChats
    notify = notifSettingGroupChatsChanged

  proc notifSettingPersonalMentionsChanged*(self: Service) {.signal.}
  proc getNotifSettingPersonalMentions*(self: Service): string {.slot.} =
    if self.initialized:
      return self.settings.notificationsPersonalMentions

    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getPersonalMentions()
      if(not response.error.isNil):
        error "error reading personal mentions setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
      self.settings.notificationsPersonalMentions = result
    except Exception as e:
      let errDesription = e.msg
      error "reading personal mentions setting error: ", errDesription

  proc setNotifSettingPersonalMentions*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setPersonalMentions(value)
      if(not response.error.isNil):
        error "error saving personal mentions setting: ", errDescription = response.error.message
        return
      self.settings.notificationsPersonalMentions = value
      self.notifSettingPersonalMentionsChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving personal mentions setting error: ", errDesription

  QtProperty[string] notifSettingPersonalMentions:
    read = getNotifSettingPersonalMentions
    write = setNotifSettingPersonalMentions
    notify = notifSettingPersonalMentionsChanged

  proc notifSettingGlobalMentionsChanged*(self: Service) {.signal.}
  proc getNotifSettingGlobalMentions*(self: Service): string {.slot.} =
    if self.initialized:
      return self.settings.notificationsGlobalMentions

    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getGlobalMentions()
      if(not response.error.isNil):
        error "error reading global mentions setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
      self.settings.notificationsGlobalMentions = result
    except Exception as e:
      let errDesription = e.msg
      error "reading global mentions setting error: ", errDesription

  proc setNotifSettingGlobalMentions*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setGlobalMentions(value)
      if(not response.error.isNil):
        error "error saving global mentions setting: ", errDescription = response.error.message
        return
      self.settings.notificationsGlobalMentions = value
      self.notifSettingGlobalMentionsChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving global mentions setting error: ", errDesription

  QtProperty[string] notifSettingGlobalMentions:
    read = getNotifSettingGlobalMentions
    write = setNotifSettingGlobalMentions
    notify = notifSettingGlobalMentionsChanged

  proc notifSettingAllMessagesChanged*(self: Service) {.signal.}
  proc getNotifSettingAllMessages*(self: Service): string {.slot.} =
    if self.initialized:
      return self.settings.notificationsAllMessages

    result = VALUE_NOTIF_TURN_OFF #default value
    try:
      let response = status_settings.getAllMessages()
      if(not response.error.isNil):
        error "error reading all messages setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
      self.settings.notificationsAllMessages = result
    except Exception as e:
      let errDesription = e.msg
      error "reading all messages setting error: ", errDesription

  proc setNotifSettingAllMessages*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setAllMessages(value)
      if(not response.error.isNil):
        error "error saving all messages setting: ", errDescription = response.error.message
        return
      self.settings.notificationsAllMessages = value
      self.notifSettingAllMessagesChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving all messages setting error: ", errDesription

  QtProperty[string] notifSettingAllMessages:
    read = getNotifSettingAllMessages
    write = setNotifSettingAllMessages
    notify = notifSettingAllMessagesChanged

  proc notifSettingContactRequestsChanged*(self: Service) {.signal.}
  proc getNotifSettingContactRequests*(self: Service): string {.slot.} =
    if self.initialized:
      return self.settings.notificationsContactRequests

    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getContactRequests()
      if(not response.error.isNil):
        error "error reading contact request setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
      self.settings.notificationsContactRequests = result
    except Exception as e:
      let errDesription = e.msg
      error "reading contact request setting error: ", errDesription

  proc setNotifSettingContactRequests*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setContactRequests(value)
      if(not response.error.isNil):
        error "error saving contact request setting: ", errDescription = response.error.message
        return
      self.settings.notificationsContactRequests = value
      self.notifSettingContactRequestsChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving contact request setting error: ", errDesription

  QtProperty[string] notifSettingContactRequests:
    read = getNotifSettingContactRequests
    write = setNotifSettingContactRequests
    notify = notifSettingContactRequestsChanged

  proc notifSettingIdentityVerificationRequestsChanged*(self: Service) {.signal.}
  proc getNotifSettingIdentityVerificationRequests*(self: Service): string {.slot.} =
    if self.initialized:
      return self.settings.notificationsIdentityVerificationRequests

    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getIdentityVerificationRequests()
      if(not response.error.isNil):
        error "error reading identity verification request setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
      self.settings.notificationsIdentityVerificationRequests = result
    except Exception as e:
      let errDesription = e.msg
      error "reading identity verification request setting error: ", errDesription

  proc setNotifSettingIdentityVerificationRequests*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setIdentityVerificationRequests(value)
      if(not response.error.isNil):
        error "error saving identity verification request setting: ", errDescription = response.error.message
        return
      self.settings.notificationsIdentityVerificationRequests = value
      self.notifSettingIdentityVerificationRequestsChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving identity verification request setting error: ", errDesription

  QtProperty[string] notifSettingIdentityVerificationRequests:
    read = getNotifSettingIdentityVerificationRequests
    write = setNotifSettingIdentityVerificationRequests
    notify = notifSettingIdentityVerificationRequestsChanged

  proc notificationSoundsEnabledChanged*(self: Service) {.signal.}
  proc getNotificationSoundsEnabled*(self: Service): bool {.slot.} =
    if self.initialized:
      return self.settings.notificationsSoundsEnabled

    result = true #default value
    try:
      let response = status_settings.getSoundEnabled()
      if(not response.error.isNil):
        error "error reading sound enabled setting: ", errDescription = response.error.message
        return
      result = response.result.getBool
      self.settings.notificationsSoundsEnabled = result
    except Exception as e:
      let errDesription = e.msg
      error "reading sound enabled setting error: ", errDesription

  proc setNotificationSoundsEnabled*(self: Service, value: bool) {.slot.} =
    try:
      let response = status_settings.setSoundEnabled(value)
      if(not response.error.isNil):
        error "error saving sound enabled setting: ", errDescription = response.error.message
        return
      self.settings.notificationsSoundsEnabled = value
      self.notificationSoundsEnabledChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving sound enabled setting error: ", errDesription

  QtProperty[bool] notificationSoundsEnabled:
    read = getNotificationSoundsEnabled
    write = setNotificationSoundsEnabled
    notify = notificationSoundsEnabledChanged

  proc notificationVolumeChanged*(self: Service) {.signal.}
  proc getNotificationVolume*(self: Service): int {.slot.} =
    if self.initialized:
      return self.settings.notificationsVolume

    result = 50 #default value
    try:
      let response = status_settings.getVolume()
      if(not response.error.isNil):
        error "error reading volume setting: ", errDescription = response.error.message
        return
      result = response.result.getInt
      self.settings.notificationsVolume = result
    except Exception as e:
      let errDesription = e.msg
      error "reading volume setting error: ", errDesription

  proc setNotificationVolume*(self: Service, value: int) {.slot.} =
    try:
      let response = status_settings.setVolume(value)
      if(not response.error.isNil):
        error "error saving volume setting: ", errDescription = response.error.message
        return
      self.settings.notificationsVolume = value
      self.notificationVolumeChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving volume setting error: ", errDesription

  QtProperty[int] volume:
    read = getNotificationVolume
    write = setNotificationVolume
    notify = notificationVolumeChanged


  proc notificationMessagePreviewChanged*(self: Service) {.signal.}
  proc getNotificationMessagePreview*(self: Service): int {.slot.} =
    if self.initialized:
      return self.settings.notificationsMessagePreview

    result = 2 #default value
    try:
      let response = status_settings.getMessagePreview()
      if(not response.error.isNil):
        error "error reading message preview setting: ", errDescription = response.error.message
        return
      result = response.result.getInt
      self.settings.notificationsMessagePreview = result
    except Exception as e:
      let errDesription = e.msg
      error "reading message preview setting error: ", errDesription

  proc setNotificationMessagePreview*(self: Service, value: int) {.slot.} =
    try:
      let response = status_settings.setMessagePreview(value)
      if(not response.error.isNil):
        error "error saving message preview setting: ", errDescription = response.error.message
        return
      self.settings.notificationsMessagePreview = value
      self.notificationMessagePreviewChanged()
    except Exception as e:
      let errDesription = e.msg
      error "saving message preview setting error: ", errDesription

  QtProperty[int] notificationMessagePreview:
    read = getNotificationMessagePreview
    write = setNotificationMessagePreview
    notify = notificationMessagePreviewChanged

  proc setNotifSettingExemptions*(self: Service, id: string, exemptions: NotificationsExemptions): bool =
    result = false
    try:
      let response = status_settings.setExemptions(id, exemptions.muteAllMessages, exemptions.personalMentions,
      exemptions.globalMentions, exemptions.otherMessages)
      if(not response.error.isNil):
        error "error saving exemptions setting: ", id = id, errDescription = response.error.message
        return
      self.notifExemptionsCache[id] = exemptions
      result = true
    except Exception as e:
      let errDesription = e.msg
      error "saving exemptions setting error: ", id = id, errDesription

  proc removeNotifSettingExemptions*(self: Service, id: string): bool =
    result = false
    try:
      let response = status_settings.deleteExemptions(id)
      if(not response.error.isNil):
        error "error deleting exemptions setting: ", id = id, errDescription = response.error.message
        return
      result = true
    except Exception as e:
      let errDesription = e.msg
      error "saving deleting exemptions setting: ", id = id, errDesription

  proc getNotifSettingExemptions*(self: Service, id: string): NotificationsExemptions =
    if self.notifExemptionsCache.hasKey(id):
      return self.notifExemptionsCache[id]

    #default values
    result.muteAllMessages = false
    result.personalMentions = VALUE_NOTIF_SEND_ALERTS
    result.globalMentions = VALUE_NOTIF_SEND_ALERTS
    result.otherMessages = VALUE_NOTIF_TURN_OFF
    try:
      var response = status_settings.getExemptionMuteAllMessages(id)
      if(not response.error.isNil):
        error "error reading exemptions mute all messages request setting: ", id = id, errDescription = response.error.message
        return
      result.muteAllMessages = response.result.getBool

      response = status_settings.getExemptionPersonalMentions(id)
      if(not response.error.isNil):
        error "error reading exemptions personal mentions request setting: ", id = id, errDescription = response.error.message
        return
      result.personalMentions = response.result.getStr

      response = status_settings.getExemptionGlobalMentions(id)
      if(not response.error.isNil):
        error "error reading exemptions global mentions request setting: ", id = id, errDescription = response.error.message
        return
      result.globalMentions = response.result.getStr

      response = status_settings.getExemptionOtherMessages(id)
      if(not response.error.isNil):
        error "error reading exemptions other messages request setting: ", id = id, errDescription = response.error.message
        return
      result.otherMessages = response.result.getStr

    except Exception as e:
      let errDesription = e.msg
      error "reading exemptions setting error: ", id = id, errDesription

    self.notifExemptionsCache[id] = result

  proc getBio*(self: Service): string =
    self.settings.bio

  proc saveBio*(self: Service, value: string): bool =
    if(self.saveSetting(KEY_BIO, value)):
      self.settings.bio = value
      self.events.emit(SIGNAL_BIO_UPDATED, SettingsTextValueArgs(value: self.settings.bio))
      return true
    return false

  proc getSocialLinks*(self: Service): SocialLinks =
    return self.socialLinks

  proc storeSocialLinksAndNotify(self: Service, data: SocialLinksArgs) =
    self.socialLinks = data.socialLinks
    self.events.emit(SIGNAL_SOCIAL_LINKS_UPDATED, data)

  proc fetchAndStoreSocialLinks*(self: Service) =
    var data = SocialLinksArgs()
    try:
      let response = status_settings.getSocialLinks()
      if(not response.error.isNil):
        data.error = response.error.message
        error "error getting social links", errDescription = response.error.message
      data.socialLinks = toSocialLinks(response.result)
    except Exception as e:
      data.error = e.msg
      error "error getting social links", errDesription = e.msg
    self.storeSocialLinksAndNotify(data)

  proc setSocialLinks*(self: Service, links: SocialLinks) =
    var data = SocialLinksArgs()
    let isValid = all(links, proc (link: SocialLink): bool = common_utils.validateLink(link.url))
    if not isValid:
      data.error = "invalid link provided"
      error "validation error", errDescription=data.error
      return
    try:
      let response = status_settings.addOrReplaceSocialLinks(%*links)
      if not response.error.isNil:
        data.error = response.error.message
        error "error saving social links", errDescription=data.error
        return
      data.socialLinks = links
    except Exception as e:
      data.error = e.msg
      error "error saving social links", errDescription=data.error
    self.storeSocialLinksAndNotify(data)

  proc isIncludeWatchOnlyAccount*(self: Service): bool =
    return self.settings.includeWatchOnlyAccount

  proc toggleIncludeWatchOnlyAccount*(self: Service) =
    let newValue = not self.settings.includeWatchOnlyAccount
    if(self.saveSetting(INCLUDE_WATCH_ONLY_ACCOUNT, newValue)):
      self.settings.includeWatchOnlyAccount = newValue
      self.events.emit(SIGNAL_INCLUDE_WATCH_ONLY_ACCOUNTS_UPDATED, Args())
