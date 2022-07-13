import ../shared_models/section_item, io_interface, chronicles
import ../../global/app_sections_config as conf
import ../../global/global_singleton
import ../../global/app_signals
import ../../core/signals/types as signal_types
import ../../core/eventemitter
import ../../core/notifications/notifications_manager
import ../../../app_service/common/types
import ../../../app_service/service/settings/service as settings_service
import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/message/service as message_service
import ../../../app_service/service/gif/service as gif_service
import ../../../app_service/service/mailservers/service as mailservers_service
import ../../../app_service/service/privacy/service as privacy_service
import ../../../app_service/service/node/service as node_service

logScope:
  topics = "main-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    keychainService: keychain_service.Service
    accountsService: accounts_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service
    contactsService: contacts_service.Service
    gifService: gif_service.Service
    privacyService: privacy_service.Service
    mailserversService: mailservers_service.Service
    nodeService: node_service.Service
    activeSectionId: string

# Forward declaration
proc setActiveSection*(self: Controller, sectionId: string)

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  contactsService: contacts_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  privacyService: privacy_service.Service,
  mailserversService: mailservers_service.Service,
  nodeService: node_service.Service,
):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.keychainService = keychainService
  result.accountsService = accountsService
  result.chatService = chatService
  result.communityService = communityService
  result.contactsService = contactsService
  result.messageService = messageService
  result.gifService = gifService
  result.privacyService = privacyService
  result.nodeService = nodeService
  result.mailserversService = mailserversService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on("mailserverAvailable") do(e:Args):
    echo "MAILSERVER AVAILABLE: ", repr(e)
    # We need to take some actions here. This is the only pace where "mailserverAvailable" signal should be handled.
    # Do the following, if we really need that.
    # requestAllHistoricMessagesResult
    # requestMissingCommunityInfos

  self.events.on(SIGNAL_MAILSERVER_NOT_WORKING) do(e: Args):
    self.delegate.emitMailserverNotWorking()

  if(defined(macosx)):
    let account = self.accountsService.getLoggedInAccount()
    singletonInstance.localAccountSettings.setFileName(account.name)

  self.events.on("keychainServiceSuccess") do(e:Args):
    let args = KeyChainServiceArg(e)
    self.delegate.emitStoringPasswordSuccess()

  self.events.on("keychainServiceError") do(e:Args):
    let args = KeyChainServiceArg(e)
    singletonInstance.localAccountSettings.removeKey(LS_KEY_STORE_TO_KEYCHAIN)
    self.delegate.emitStoringPasswordError(args.errDescription)

  self.events.on(SIGNAL_COMMUNITY_JOINED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityJoined(
      args.community,
      self.events,
      self.settingsService,
      self.contactsService,
      self.chatService,
      self.communityService,
      self.messageService,
      self.gifService,
      self.mailserversService,
      setActive = args.fromUserAction
    )

  self.events.on(TOGGLE_SECTION) do(e:Args):
    let args = ToggleSectionArgs(e)
    self.delegate.toggleSection(args.sectionType)

  self.events.on(SIGNAL_COMMUNITY_CREATED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityJoined(
      args.community,
      self.events,
      self.settingsService,
      self.contactsService,
      self.chatService,
      self.communityService,
      self.messageService,
      self.gifService,
      self.mailserversService,
      setActive = true
    )

  self.events.on(SIGNAL_COMMUNITY_IMPORTED) do(e:Args):
    let args = CommunityArgs(e)
    if(args.error.len > 0):
      return
    self.delegate.communityJoined(
      args.community,
      self.events,
      self.settingsService,
      self.contactsService,
      self.chatService,
      self.communityService,
      self.messageService,
      self.gifService,
      self.mailserversService,
      setActive = false
    )

  self.events.on(SIGNAL_COMMUNITY_LEFT) do(e:Args):
    let args = CommunityIdArgs(e)
    self.delegate.communityLeft(args.communityId)

  self.events.on(SIGNAL_COMMUNITY_EDITED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityEdited(args.community)

  self.events.on(SIGNAL_COMMUNITIES_UPDATE) do(e:Args):
    let args = CommunitiesArgs(e)
    for community in args.communities:
      self.delegate.communityEdited(community)

  self.events.on(SIGNAL_ENS_RESOLVED) do(e: Args):
    var args = ResolvedContactArgs(e)
    self.delegate.resolvedENS(args.pubkey, args.address, args.uuid, args.reason)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactUpdated(args.contactId)

  self.events.on(SIGNAL_CONTACTS_STATUS_UPDATED) do(e: Args):
    let args = ContactsStatusUpdatedArgs(e)
    self.delegate.contactsStatusUpdated(args.statusUpdates)

  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactUpdated(args.contactId)

  self.events.on(SIGNAL_CONTACT_UNTRUSTWORTHY) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.contactUpdated(args.publicKey)

  self.events.on(SIGNAL_CONTACT_TRUSTED) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.contactUpdated(args.publicKey)

  self.events.on(SIGNAL_REMOVED_TRUST_STATUS) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.contactUpdated(args.publicKey)

  self.events.on(SIGNAL_MNEMONIC_REMOVAL) do(e: Args):
    self.delegate.mnemonicBackedUp()

  self.events.on(SIGNAL_MAKE_SECTION_CHAT_ACTIVE) do(e: Args):
    var args = ActiveSectionChatArgs(e)
    self.setActiveSection(args.sectionId)

  self.events.on(SIGNAL_STATUS_URL_REQUESTED) do(e: Args):
    var args = StatusUrlArgs(e)
    self.delegate.onStatusUrlRequested(args.action, args.communityId, args.chatId, args.url, args.userId, 
      args.groupName, args.listOfUserIds)

  self.events.on(SIGNAL_OS_NOTIFICATION_CLICKED) do(e: Args):
    var args = ClickedNotificationArgs(e)
    self.delegate.osNotificationClicked(args.details)

  self.events.on(SIGNAL_DISPLAY_APP_NOTIFICATION) do(e: Args):
    var args = NotificationArgs(e)
    self.delegate.displayEphemeralNotification(args.title, args.message, args.details)

  self.events.on(SIGNAL_NEW_REQUEST_TO_JOIN_COMMUNITY) do(e: Args):
    var args = CommunityRequestArgs(e)
    self.delegate.newCommunityMembershipRequestReceived(args.communityRequest)

  self.events.on(SIGNAL_NETWORK_CONNECTED) do(e: Args):
    self.delegate.onNetworkConnected()

  self.events.on(SIGNAL_NETWORK_DISCONNECTED) do(e: Args):
    self.delegate.onNetworkDisconnected()

  self.events.on(SIGNAL_CURRENT_USER_STATUS_UPDATED) do (e: Args):
    var args = CurrentUserStatusArgs(e)
    singletonInstance.userProfile.setCurrentUserStatus(args.statusType.int)

  self.events.on(chat_service.SIGNAL_CHAT_LEFT) do(e: Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.onChatLeft(args.chatId)

proc isConnected*(self: Controller): bool =
  return self.nodeService.isConnected()

proc getChannelGroups*(self: Controller): seq[ChannelGroupDto] =
  return self.chatService.getChannelGroups()

proc checkForStoringPassword*(self: Controller) =
  # This proc is called once user is logged in irrespective he is logged in
  # through the onboarding or login view.

  # This is MacOS only feature
  if(not defined(macosx)):
    return

  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value == LS_VALUE_STORE or value == LS_VALUE_NEVER):
    return

  # We are here if stored "storeToKeychain" property for the logged in user
  # is either empty or set to "NotNow".
  self.delegate.offerToStorePassword()

proc storePassword*(self: Controller, password: string) =
  let account = self.accountsService.getLoggedInAccount()

  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE or account.name.len == 0):
    return

  self.keychainService.storePassword(account.name, password)

proc getActiveSectionId*(self: Controller): string =
  result = self.activeSectionId

proc setActiveSection*(self: Controller, sectionId: string) =
  self.activeSectionId = sectionId
  let sectionIdToSave = if (sectionId == conf.SETTINGS_SECTION_ID): "" else: sectionId
  singletonInstance.localAccountSensitiveSettings.setActiveSection(sectionIdToSave)
  self.delegate.activeSectionSet(self.activeSectionId)

proc getNumOfNotificaitonsForChat*(self: Controller): tuple[unviewed:int, mentions:int] =
  result.unviewed = 0
  result.mentions = 0
  let chats = self.chatService.getAllChats()
  for chat in chats:
    if(chat.chatType == ChatType.CommunityChat):
      continue

    result.unviewed += chat.unviewedMessagesCount
    result.mentions += chat.unviewedMentionsCount

proc getNumOfNotificationsForCommunity*(self: Controller, communityId: string): tuple[unviewed:int, mentions:int] =
  result.unviewed = 0
  result.mentions = 0
  let chats = self.chatService.getAllChats()
  for chat in chats:
    if(chat.communityId != communityId):
      continue

    result.unviewed += chat.unviewedMessagesCount
    result.mentions += chat.unviewedMentionsCount

proc setCurrentUserStatus*(self: Controller, status: StatusType) =
  if(self.settingsService.saveSendStatusUpdates(status)):
    singletonInstance.userProfile.setCurrentUserStatus(status.int)
    self.contactsService.emitCurrentUserStatusChanged(self.settingsService.getCurrentUserStatus())
  else:
    error "error updating user status"

proc getContact*(self: Controller, id: string): ContactsDto =
  return self.contactsService.getContactById(id)

proc getContacts*(self: Controller, group: ContactsGroup): seq[ContactsDto] =
  return self.contactsService.getContactsByGroup(group)

proc getContactNameAndImage*(self: Controller, contactId: string):
    tuple[name: string, image: string, largeImage: string] =
  return self.contactsService.getContactNameAndImage(contactId)

proc getContactDetails*(self: Controller, contactId: string): ContactDetails =
  return self.contactsService.getContactDetails(contactId)

proc resolveENS*(self: Controller, ensName: string, uuid: string = "", reason: string = "") =
  self.contactsService.resolveENS(ensName, uuid, reason)

proc isMnemonicBackedUp*(self: Controller): bool =
  result = self.privacyService.isMnemonicBackedUp()

proc switchTo*(self: Controller, sectionId, chatId, messageId: string) =
  let data = ActiveSectionChatArgs(sectionId: sectionId, chatId: chatId, messageId: messageId)
  self.events.emit(SIGNAL_MAKE_SECTION_CHAT_ACTIVE, data)

proc getCommunityById*(self: Controller, communityId: string): CommunityDto =
  return self.communityService.getCommunityById(communityId)

proc getStatusForContactWithId*(self: Controller, publicKey: string): StatusUpdateDto =
  return self.contactsService.getStatusForContactWithId(publicKey)
