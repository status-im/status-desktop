import NimQml, sequtils, strutils, sugar, os, json, chronicles
import views/[mailservers_list, ens_manager, contacts, devices, mailservers, mnemonic, network, fleets, profile_info, device_list, dapp_list, profile_picture, muted_chats]
import chronicles
import qrcode/qrcode

# TODO: Remove direct access to statusgo backend!
import status/statusgo_backend/eth as eth
import status/statusgo_backend/accounts as status_accounts
import status/profile as status_profile
import status/contacts as status_contacts
import status/status
import status/ens as status_ens
import status/chat/chat
import status/types/[setting, os_notification, profile]
import status/notifications/[os_notifications]

import ../chat/views/channels_list
import ../../constants
import ../../app_service/[main]
import ../../app_service/service/local_settings/service as local_settings_service
import ../utils/image_utils
import ../../constants

logScope:
  topics = "profile-view"

QtObject:
  type ProfileView* = ref object of QObject
    profile*: ProfileInfoView
    profilePicture*: ProfilePictureView
    mutedChats*: MutedChatsView
    contacts*: ContactsView
    devices*: DevicesView
    mailservers*: MailserversView
    mnemonic*: MnemonicView
    dappList*: DappList
    fleets*: Fleets
    network*: NetworkView
    status*: Status
    appService: AppService
    localSettingsService: local_settings_service.Service
    changeLanguage*: proc(locale: string)
    ens*: EnsManager

  proc setup(self: ProfileView) =
    self.QObject.setup

  proc delete*(self: ProfileView) =
    if not self.contacts.isNil: self.contacts.delete
    if not self.devices.isNil: self.devices.delete
    if not self.ens.isNil: self.ens.delete
    if not self.profilePicture.isNil: self.profilePicture.delete
    if not self.mutedChats.isNil: self.mutedChats.delete
    if not self.profile.isNil: self.profile.delete
    if not self.dappList.isNil: self.dappList.delete
    if not self.fleets.isNil: self.fleets.delete
    if not self.network.isNil: self.network.delete
    if not self.mnemonic.isNil: self.mnemonic.delete
    if not self.mailservers.isNil: self.mailservers.delete
    self.QObject.delete

  proc newProfileView*(status: Status, appService: AppService, 
    localSettingsService: local_settings_service.Service,
    changeLanguage: proc(locale: string)): ProfileView =
    new(result, delete)
    result = ProfileView()
    result.profile = newProfileInfoView()
    result.profilePicture = newProfilePictureView(status, result.profile)
    result.mutedChats = newMutedChatsView(status)
    result.contacts = newContactsView(status, appService)
    result.devices = newDevicesView(status)
    result.network = newNetworkView(status)
    result.mnemonic = newMnemonicView(status)
    result.mailservers = newMailserversView(status, appService)
    result.dappList = newDappList(status)
    result.ens = newEnsManager(status, appService)
    result.fleets = newFleets(status)
    result.changeLanguage = changeLanguage
    result.status = status
    result.appService = appService
    result.localSettingsService = localSettingsService
    result.setup

  proc initialized*(self: ProfileView) {.signal.}

  proc getProfile(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.profile)

  proc profileChanged*(self: ProfileView) {.signal.}

  proc setNewProfile*(self: ProfileView, profile: Profile) =
    self.profile.setProfile(profile)
    self.contacts.accountKeyUID = profile.address
    self.profileChanged()

  QtProperty[QVariant] profile:
    read = getProfile
    notify = profileChanged

  proc logout*(self: ProfileView) {.slot.} =
    self.status.profile.logout()

  proc changeLocale*(self: ProfileView, locale: string) {.slot.} =
    self.changeLanguage(locale)

  proc nodeVersion*(self: ProfileView): string {.slot.} =
    self.status.getNodeVersion()

  proc qrCode*(self: ProfileView, text:string): string {.slot.} =
    result = "data:image/svg+xml;utf8," & generateQRCodeSVG(text, 2)

  proc changeTheme*(self: ProfileView, theme: int) {.slot.} =
    self.profile.setAppearance(theme)
    self.status.saveSetting(Setting.Appearance, $theme)

  proc getDappList(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.dappList)

  QtProperty[QVariant] dappList:
    read = getDappList

  proc getFleets(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.fleets)

  QtProperty[QVariant] fleets:
    read = getFleets

  proc getEnsManager(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.ens)

  QtProperty[QVariant] ens:
    read = getEnsManager

  proc changePassword(self: ProfileView, password: string, newPassword: string): bool {.slot.} =
    let
      defaultAccount = eth.getDefaultAccount()
      isPasswordOk = status_accounts.verifyAccountPassword(defaultAccount, password, KEYSTOREDIR)
    if not isPasswordOk:
      return false

    if self.status.accounts.changePassword(self.profile.address, password, newPassword):
      return true
    else:
      return false

  proc getLinkPreviewWhitelist*(self: ProfileView): string {.slot.} =
    result = $(self.status.profile.getLinkPreviewWhitelist())

  proc setMessagesFromContactsOnly*(self: ProfileView, messagesFromContactsOnly: bool) {.slot.} =
    if (messagesFromContactsOnly == self.profile.messagesFromContactsOnly):
      return
    self.profile.setMessagesFromContactsOnly(messagesFromContactsOnly)
    self.status.saveSetting(Setting.MessagesFromContactsOnly, messagesFromContactsOnly)
    # TODO cleanup chats after activating this

  proc contactsChanged*(self: ProfileView) {.signal.}

  proc getContacts*(self: ProfileView): QVariant {.slot.} =
    newQVariant(self.contacts)

  QtProperty[QVariant] contacts:
    read = getContacts
    notify = contactsChanged

  proc getDevices*(self: ProfileView): QVariant {.slot.} =
    newQVariant(self.devices)

  QtProperty[QVariant] devices:
    read = getDevices

  proc getMailservers*(self: ProfileView): QVariant {.slot.} =
    newQVariant(self.mailservers)

  QtProperty[QVariant] mailservers:
    read = getMailservers

  proc getMnemonic*(self: ProfileView): QVariant {.slot.} =
    newQVariant(self.mnemonic)

  QtProperty[QVariant] mnemonic:
    read = getMnemonic

  proc getNetwork*(self: ProfileView): QVariant {.slot.} =
    newQVariant(self.network)

  QtProperty[QVariant] network:
    read = getNetwork

  proc getProfilePicture*(self: ProfileView): QVariant {.slot.} =
    newQVariant(self.profilePicture)

  QtProperty[QVariant] picture:
    read = getProfilePicture

  proc getGlobalSettingsFile*(self: ProfileView): string {.slot.} =
    self.localSettingsService.getGlobalSettingsFilePath

  QtProperty[string] globalSettingsFile:
    read = getGlobalSettingsFile

  proc getMutedChats*(self: ProfileView): QVariant {.slot.} =
    newQVariant(self.mutedChats)

  QtProperty[QVariant] mutedChats:
    read = getMutedChats

  proc settingsFileChanged*(self: ProfileView) {.signal.}
  
  proc getSettingsFile*(self: ProfileView): string {.slot.} =
    self.localSettingsService.getSettingsFilePath
  
  proc setSettingsFile*(self: ProfileView, pubKey: string) =
    self.localSettingsService.updateSettingsFilePath(pubKey)
    self.settingsFileChanged()

  QtProperty[string] settingsFile:
    read = getSettingsFile
    notify = settingsFileChanged

  proc accountSettingsFileChanged*(self: ProfileView) {.signal.}

  proc setAccountSettingsFile*(self: ProfileView, alias: string) =
    self.localSettingsService.updateAccountSettingsFilePath(alias)
    self.accountSettingsFileChanged()

  proc getAccountSettingsFile*(self: ProfileView): string {.slot.} =
    self.localSettingsService.getAccountSettingsFilePath

  QtProperty[string] accountSettingsFile:
    read = getAccountSettingsFile
    notify = accountSettingsFileChanged

  proc setSendUserStatus*(self: ProfileView, sendUserStatus: bool) {.slot.} =
    if (sendUserStatus == self.profile.sendUserStatus):
      return
    self.profile.setSendUserStatus(sendUserStatus)
    self.status.saveSetting(Setting.SendUserStatus, sendUserStatus)

  proc showOSNotification*(self: ProfileView, title: string, message: string,
    notificationType: int, useOSNotifications: bool) {.slot.} =

    let details = OsNotificationDetails(
      notificationType: notificationType.OsNotificationType
    )

    self.appService.osNotificationService.showNotification(title, message,
    details, useOSNotifications)

  proc logDir*(self: ProfileView): string {.slot.} =
    url_fromLocalFile(constants.LOGDIR)
