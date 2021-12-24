import ../shared_models/section_item, controller_interface, io_interface, chronicles
import ../../global/global_singleton
import ../../global/app_signals
import ../../../app_service/service/settings/service_interface as settings_service
import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/accounts/service_interface as accounts_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/message/service as message_service

import ../../core/signals/types
import eventemitter

export controller_interface

logScope:
  topics = "main-module-controller"

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.ServiceInterface
    keychainService: keychain_service.Service
    accountsService: accounts_service.ServiceInterface
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service
    contactsService: contacts_service.Service
    activeSectionId: string

proc newController*(delegate: io_interface.AccessInterface, 
  events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.ServiceInterface,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  contactsService: contacts_service.Service,
  messageService: message_service.Service): 
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
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on("mailserverAvailable") do(e:Args):
    echo "MAILSERVER AVAILABLE: ", repr(e)
    # We need to take some actions here. This is the only pace where "mailserverAvailable" signal should be handled.
    # Do the following, if we really need that.
    # requestAllHistoricMessagesResult
    # requestMissingCommunityInfos

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
      self.messageService
      )

  self.events.on(TOGGLE_SECTION) do(e:Args):
    let args = ToggleSectionArgs(e)
    self.delegate.toggleSection(args.sectionType)
    discard    

method getJoinedCommunities*(self: Controller): seq[CommunityDto] =
  return self.communityService.getJoinedCommunities()

method checkForStoringPassword*(self: Controller) =
  # This method is called once user is logged in irrespective he is logged in 
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

method storePassword*(self: Controller, password: string) =
  let account = self.accountsService.getLoggedInAccount()

  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE or account.name.len == 0):
    return

  self.keychainService.storePassword(account.name, password)

method setActiveSection*(self: Controller, sectionId: string, sectionType: SectionType) =
  self.activeSectionId = sectionId

  if(sectionType == SectionType.Chat or sectionType == SectionType.Community):
    # We need to take other actions here, in case of Chat or Community sections like
    # notify status go that unviewed mentions count is updated and so...
    echo "deal with appropriate service..."

  singletonInstance.localAccountSensitiveSettings.setActiveSection(self.activeSectionId)

  self.delegate.activeSectionSet(self.activeSectionId)

method getNumOfNotificaitonsForChat*(self: Controller): tuple[unviewed:int, mentions:int] =
  result.unviewed = 0
  result.mentions = 0
  let chats = self.chatService.getAllChats()
  for chat in chats:
    if(chat.chatType == ChatType.Timeline or chat.chatType == ChatType.CommunityChat):
      continue

    result.unviewed += chat.unviewedMessagesCount
    result.mentions += chat.unviewedMentionsCount

method getNumOfNotificationsForCommunity*(self: Controller, communityId: string): tuple[unviewed:int, mentions:int] =
  result.unviewed = 0
  result.mentions = 0
  let chats = self.chatService.getAllChats()
  for chat in chats:
    if(chat.communityId != communityId):
      continue

    result.unviewed += chat.unviewedMessagesCount
    result.mentions += chat.unviewedMentionsCount

method setUserStatus*(self: Controller, status: bool) =
  if(self.settingsService.saveSendStatusUpdates(status)):
    singletonInstance.userProfile.setUserStatus(status)
  else:
    error "error updating user status"