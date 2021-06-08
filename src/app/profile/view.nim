import NimQml, sequtils, strutils, sugar, os, json, chronicles
import views/[mailservers_list, ens_manager, contacts, devices, mailservers, mnemonic, network, fleets, profile_info, device_list, dapp_list]
import chronicles
import ../chat/views/channels_list
import ../../status/profile/profile
import ../../status/profile as status_profile
import ../../status/contacts as status_contacts
import ../../status/accounts as status_accounts
import ../../status/status
import ../../status/ens as status_ens
import ../../status/chat/chat
import ../../status/libstatus/types
import ../../status/libstatus/accounts/constants as accountConstants
import qrcode/qrcode
import ../utils/image_utils

logScope:
  topics = "profile-view"

const UNKNOWN_ACCOUNT = "unknownAccount"

QtObject:
  type ProfileView* = ref object of QObject
    profile*: ProfileInfoView
    contacts*: ContactsView
    devices*: DevicesView
    mailservers*: MailserversView
    mnemonic*: MnemonicView
    mutedChats*: ChannelsList
    mutedContacts*: ChannelsList
    dappList*: DappList
    fleets*: Fleets
    network*: NetworkView
    status*: Status
    changeLanguage*: proc(locale: string)
    ens*: EnsManager

  proc setup(self: ProfileView) =
    self.QObject.setup

  proc delete*(self: ProfileView) =
    if not self.contacts.isNil: self.contacts.delete
    if not self.devices.isNil: self.devices.delete
    if not self.mutedChats.isNil: self.mutedChats.delete
    if not self.mutedContacts.isNil: self.mutedContacts.delete
    if not self.ens.isNil: self.ens.delete
    if not self.profile.isNil: self.profile.delete
    if not self.dappList.isNil: self.dappList.delete
    if not self.fleets.isNil: self.fleets.delete
    if not self.network.isNil: self.network.delete
    if not self.mnemonic.isNil: self.mnemonic.delete
    if not self.mailservers.isNil: self.mailservers.delete
    self.QObject.delete

  proc newProfileView*(status: Status, changeLanguage: proc(locale: string)): ProfileView =
    new(result, delete)
    result = ProfileView()
    result.profile = newProfileInfoView()
    result.contacts = newContactsView(status)
    result.devices = newDevicesView(status)
    result.network = newNetworkView(status)
    result.mnemonic = newMnemonicView(status)
    result.mailservers = newMailserversView(status)
    result.mutedChats = newChannelsList(status)
    result.mutedContacts = newChannelsList(status)
    result.dappList = newDappList(status)
    result.ens = newEnsManager(status)
    result.fleets = newFleets(status)
    result.changeLanguage = changeLanguage
    result.status = status
    result.setup

  proc profileSettingsFileChanged*(self: ProfileView) {.signal.}

  proc getProfileSettingsFile(self: ProfileView): string {.slot.} =
    let pubkey =
      if (self.profile.pubKey == ""):
        UNKNOWN_ACCOUNT
      else:
        self.profile.pubKey

    return os.joinPath(accountConstants.DATADIR, "qt", pubkey)

  QtProperty[string] profileSettingsFile:
    read = getProfileSettingsFile
    notify = profileSettingsFileChanged

  proc getGlobalSettingsFile(self: ProfileView): string {.slot.} =
    return os.joinPath(accountConstants.DATADIR, "qt", "global")

  proc globalSettingsFileChanged*(self: ProfileView) {.signal.}

  QtProperty[string] globalSettingsFile:
    read = getGlobalSettingsFile
    notify = globalSettingsFileChanged
    

  proc initialized*(self: ProfileView) {.signal.}

  proc getProfile(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.profile)

  proc profileChanged*(self: ProfileView) {.signal.}

  proc setNewProfile*(self: ProfileView, profile: Profile) =
    self.profile.setProfile(profile)
    self.profileChanged()
    self.profileSettingsFileChanged()
    # Remove old 'unknownAccount' settings file if it was created
    let unknownSettingsPath = os.joinPath(accountConstants.DATADIR, "qt", UNKNOWN_ACCOUNT)
    if (not unknownSettingsPath.tryRemoveFile):
      # Only fails if the file exists and an there was an error removing it
      # More info: https://nim-lang.org/docs/os.html#tryRemoveFile%2Cstring
      warn "Failed to remove unused settings file", file=unknownSettingsPath

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

  proc setMessagesFromContactsOnly*(self: ProfileView, messagesFromContactsOnly: bool) {.slot.} =
    if (messagesFromContactsOnly == self.profile.messagesFromContactsOnly):
      return
    self.profile.setMessagesFromContactsOnly(messagesFromContactsOnly)
    self.status.saveSetting(Setting.MessagesFromContactsOnly, messagesFromContactsOnly)
    # TODO cleanup chats after activating this

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

  proc getLinkPreviewWhitelist*(self: ProfileView): string {.slot.} =
    result = $(self.status.profile.getLinkPreviewWhitelist())

  proc getMutedChatsList(self: ProfileView): QVariant {.slot.} =
    newQVariant(self.mutedChats)

  proc getMutedContactsList(self: ProfileView): QVariant {.slot.} =
    newQVariant(self.mutedContacts)

  proc mutedChatsListChanged*(self: ProfileView) {.signal.}

  proc mutedContactsListChanged*(self: ProfileView) {.signal.}

  QtProperty[QVariant] mutedChats:
    read = getMutedChatsList
    notify = mutedChatsListChanged

  QtProperty[QVariant] mutedContacts:
    read = getMutedContactsList
    notify = mutedContactsListChanged

  proc unmuteChannel*(self: ProfileView, chatId: string) {.slot.} =
    if (self.mutedChats.chats.len == 0 and self.mutedContacts.chats.len == 0): return

    var selectedChannel = self.mutedChats.getChannelById(chatId)
    if (selectedChannel != nil):
      discard self.mutedChats.removeChatItemFromList(chatId)
    else:
      selectedChannel = self.mutedContacts.getChannelById(chatId)
      if (selectedChannel == nil): return
      discard self.mutedContacts.removeChatItemFromList(chatId)

    selectedChannel.muted = false
    self.status.chat.unmuteChat(selectedChannel)
    self.mutedChatsListChanged()
    self.mutedContactsListChanged()

  proc updateChats*(self: ProfileView, chats: seq[Chat]) =
    for chat in chats:
      if not chat.muted:
        if chat.chatType.isOneToOne:
          discard self.mutedContacts.removeChatItemFromList(chat.id)
        else:
          discard self.mutedChats.removeChatItemFromList(chat.id)
      else:
        if chat.chatType.isOneToOne:
          discard self.mutedContacts.addChatItemToList(chat)
        else:
          discard self.mutedChats.addChatItemToList(chat)
    self.mutedChatsListChanged()
    self.mutedContactsListChanged()

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

  proc uploadNewProfilePic*(self: ProfileView, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string {.slot.} =
    var image = image_utils.formatImagePath(imageUrl)
    # FIXME the function to get the file size is messed up
    # var size = image_getFileSize(image)
    # TODO find a way to i18n this (maybe send just a code and then QML sets the right string)
    # return "Max file size is 20MB"

    try:
      # TODO add crop tool for the image
      let identityImage = self.status.profile.storeIdentityImage(self.profile.address, image, aX, aY, bX, bY)
      self.profile.setIdentityImage(identityImage)
      result = ""
    except Exception as e:
      error "Error storing identity image", msg=e.msg
      result = "Error storing identity image: " & e.msg

  proc deleteProfilePic*(self: ProfileView): string {.slot.} =
    result = self.status.profile.deleteIdentityImage(self.profile.address)
    if (result == ""):
      self.profile.removeIdentityImage()
