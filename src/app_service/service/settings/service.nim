import NimQml, chronicles, json, strutils, sequtils, tables, sugar

import ../../common/[network_constants]
import ../../common/types as common_types
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
const DEFAULT_CURRENCY* = "usd"
const DEFAULT_TELEMETRY_SERVER_URL* = "https://telemetry.status.im"
const DEFAULT_FLEET* = $Fleet.Prod

const SIGNAL_CURRENT_USER_STATUS_UPDATED* = "currentUserStatusUpdated"
const SIGNAL_SETTING_PROFILE_PICTURES_SHOW_TO_CHANGED* = "profilePicturesShowToChanged"
const SIGNAL_SETTING_PROFILE_PICTURES_VISIBILITY_CHANGED* = "profilePicturesVisibilityChanged"

logScope:
  topics = "settings-service"

type
  CurrentUserStatusArgs* = ref object of Args
    statusType*: StatusType
    text*: string

type
  SettingProfilePictureArgs* = ref object of Args
    value*: int

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    settings: SettingsDto

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter): Service =
    new(result, delete)
    result.events = events
    result.QObject.setup

  proc init*(self: Service) =
    try:
      let response = status_settings.getSettings()
      self.settings = response.result.toSettingsDto()
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

          if settingsField.name == KEY_PROFILE_PICTURES_SHOW_TO:
            self.settings.profilePicturesShowTo = settingsfield.value.parseInt
            self.events.emit(SIGNAL_SETTING_PROFILE_PICTURES_SHOW_TO_CHANGED, SettingProfilePictureArgs(value: self.settings.profilePicturesShowTo))

          if settingsField.name == KEY_PROFILE_PICTURES_VISIBILITY:
            self.settings.profilePicturesVisibility = settingsfield.value.parseInt
            self.events.emit(SIGNAL_SETTING_PROFILE_PICTURES_VISIBILITY_CHANGED, SettingProfilePictureArgs(value: self.settings.profilePicturesVisibility))

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
      self.settings.currency = value
      return true
    return false

  proc getCurrency*(self: Service): string =
    if(self.settings.currency.len == 0):
      self.settings.currency = DEFAULT_CURRENCY

    return self.settings.currency

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
      return true
    return false

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
    if(self.settings.fleet.len == 0):
      self.settings.fleet = DEFAULT_FLEET
    return self.settings.fleet

  proc getFleet*(self: Service): Fleet =
    let fleetAsString = self.getFleetAsString()
    let fleet = parseEnum[Fleet](fleetAsString)
    return fleet

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
    result = true #default value
    try:
      let response = status_settings.getAllowNotifications()
      if(not response.error.isNil):
        error "error reading allow notification setting: ", errDescription = response.error.message
        return
      result = response.result.getBool
    except Exception as e:
      let errDesription = e.msg
      error "reading allow notification setting error: ", errDesription

  proc setNotifSettingAllowNotifications*(self: Service, value: bool) {.slot.} =
    try:
      let response = status_settings.setAllowNotifications(value)
      if(not response.error.isNil):
        error "error saving allow notification setting: ", errDescription = response.error.message
        return
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
    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getOneToOneChats()
      if(not response.error.isNil):
        error "error reading one to one setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
    except Exception as e:
      let errDesription = e.msg
      error "reading one to one setting error: ", errDesription

  proc setNotifSettingOneToOneChats*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setOneToOneChats(value)
      if(not response.error.isNil):
        error "error saving one to one setting: ", errDescription = response.error.message
        return
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
    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getGroupChats()
      if(not response.error.isNil):
        error "error reading group chats setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
    except Exception as e:
      let errDesription = e.msg
      error "reading group chats setting error: ", errDesription

  proc setNotifSettingGroupChats*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setGroupChats(value)
      if(not response.error.isNil):
        error "error saving group chats setting: ", errDescription = response.error.message
        return
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
    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getPersonalMentions()
      if(not response.error.isNil):
        error "error reading personal mentions setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
    except Exception as e:
      let errDesription = e.msg
      error "reading personal mentions setting error: ", errDesription

  proc setNotifSettingPersonalMentions*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setPersonalMentions(value)
      if(not response.error.isNil):
        error "error saving personal mentions setting: ", errDescription = response.error.message
        return
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
    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getGlobalMentions()
      if(not response.error.isNil):
        error "error reading global mentions setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
    except Exception as e:
      let errDesription = e.msg
      error "reading global mentions setting error: ", errDesription

  proc setNotifSettingGlobalMentions*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setGlobalMentions(value)
      if(not response.error.isNil):
        error "error saving global mentions setting: ", errDescription = response.error.message
        return
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
    result = VALUE_NOTIF_TURN_OFF #default value
    try:
      let response = status_settings.getAllMessages()
      if(not response.error.isNil):
        error "error reading all messages setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
    except Exception as e:
      let errDesription = e.msg
      error "reading all messages setting error: ", errDesription

  proc setNotifSettingAllMessages*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setAllMessages(value)
      if(not response.error.isNil):
        error "error saving all messages setting: ", errDescription = response.error.message
        return
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
    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getContactRequests()
      if(not response.error.isNil):
        error "error reading contact request setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
    except Exception as e:
      let errDesription = e.msg
      error "reading contact request setting error: ", errDesription

  proc setNotifSettingContactRequests*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setContactRequests(value)
      if(not response.error.isNil):
        error "error saving contact request setting: ", errDescription = response.error.message
        return
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
    result = VALUE_NOTIF_SEND_ALERTS #default value
    try:
      let response = status_settings.getIdentityVerificationRequests()
      if(not response.error.isNil):
        error "error reading identity verification request setting: ", errDescription = response.error.message
        return
      result = response.result.getStr
    except Exception as e:
      let errDesription = e.msg
      error "reading identity verification request setting error: ", errDesription

  proc setNotifSettingIdentityVerificationRequests*(self: Service, value: string) {.slot.} =
    try:
      let response = status_settings.setIdentityVerificationRequests(value)
      if(not response.error.isNil):
        error "error saving identity verification request setting: ", errDescription = response.error.message
        return
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
    result = true #default value
    try:
      let response = status_settings.getSoundEnabled()
      if(not response.error.isNil):
        error "error reading sound enabled setting: ", errDescription = response.error.message
        return
      result = response.result.getBool
    except Exception as e:
      let errDesription = e.msg
      error "reading sound enabled setting error: ", errDesription

  proc setNotificationSoundsEnabled*(self: Service, value: bool) {.slot.} =
    try:
      let response = status_settings.setSoundEnabled(value)
      if(not response.error.isNil):
        error "error saving sound enabled setting: ", errDescription = response.error.message
        return
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
    result = 50 #default value
    try:
      let response = status_settings.getVolume()
      if(not response.error.isNil):
        error "error reading volume setting: ", errDescription = response.error.message
        return
      result = response.result.getInt
    except Exception as e:
      let errDesription = e.msg
      error "reading volume setting error: ", errDesription

  proc setNotificationVolume*(self: Service, value: int) {.slot.} =
    try:
      let response = status_settings.setVolume(value)
      if(not response.error.isNil):
        error "error saving volume setting: ", errDescription = response.error.message
        return
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
    result = 2 #default value
    try:
      let response = status_settings.getMessagePreview()
      if(not response.error.isNil):
        error "error reading message preview setting: ", errDescription = response.error.message
        return
      result = response.result.getInt
    except Exception as e:
      let errDesription = e.msg
      error "reading message preview setting error: ", errDesription

  proc setNotificationMessagePreview*(self: Service, value: int) {.slot.} =
    try:
      let response = status_settings.setMessagePreview(value)
      if(not response.error.isNil):
        error "error saving message preview setting: ", errDescription = response.error.message
        return
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
