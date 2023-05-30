import chronicles
import ../../global/app_sections_config as conf
import ../../global/global_singleton
import ../../global/app_signals
import ../../core/signals/types as signal_types
import ../../core/eventemitter
import ../../core/notifications/notifications_manager
import ../../../app_service/common/types
import ../../../app_service/service/settings/service as settings_service
import ../../../app_service/service/node_configuration/service as node_configuration_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/message/service as message_service
import ../../../app_service/service/gif/service as gif_service
import ../../../app_service/service/mailservers/service as mailservers_service
import ../../../app_service/service/privacy/service as privacy_service
import ../../../app_service/service/node/service as node_service
import ../../../app_service/service/community_tokens/service as community_tokens_service
import ../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../app_service/service/token/service as token_service
import ../../../app_service/service/network/service as networks_service
import ../../../app_service/service/collectible/service as collectible_service

import io_interface
import ../shared_modules/keycard_popup/io_interface as keycard_shared_module

logScope:
  topics = "main-module-controller"

const UNIQUE_MAIN_MODULE_IDENTIFIER* = "MainModule"
const UNIQUE_MAIN_MODULE_KEYCARD_SYNC_IDENTIFIER* = "MainModule-KeycardSyncPurpose"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    nodeConfigurationService: node_configuration_service.Service
    accountsService: accounts_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service
    contactsService: contacts_service.Service
    gifService: gif_service.Service
    privacyService: privacy_service.Service
    mailserversService: mailservers_service.Service
    nodeService: node_service.Service
    communityTokensService: community_tokens_service.Service
    activeSectionId: string
    authenticateUserFlowRequestedBy: string
    walletAccountService: wallet_account_service.Service
    tokenService: token_service.Service
    networksService: networks_service.Service
    collectibleService: collectible_service.Service

# Forward declaration
proc setActiveSection*(self: Controller, sectionId: string, skipSavingInSettings: bool = false)

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  accountsService: accounts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  contactsService: contacts_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  privacyService: privacy_service.Service,
  mailserversService: mailservers_service.Service,
  nodeService: node_service.Service,
  communityTokensService: community_tokens_service.Service,
  walletAccountService: wallet_account_service.Service,
  tokenService: token_service.Service,
  networksService: networks_service.Service,
  collectibleService: collectible_service.Service
):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.nodeConfigurationService = nodeConfigurationService
  result.accountsService = accountsService
  result.chatService = chatService
  result.communityService = communityService
  result.contactsService = contactsService
  result.messageService = messageService
  result.gifService = gifService
  result.privacyService = privacyService
  result.nodeService = nodeService
  result.mailserversService = mailserversService
  result.communityTokensService = communityTokensService
  result.walletAccountService = walletAccountService
  result.tokenService = tokenService
  result.networksService = networksService
  result.collectibleService = collectibleService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_CHANNEL_GROUPS_LOADED) do(e:Args):
    let args = ChannelGroupsArgs(e)
    self.delegate.onChannelGroupsLoaded(
      args.channelGroups,
      self.events,
      self.settingsService,
      self.nodeConfigurationService,
      self.contactsService,
      self.chatService,
      self.communityService,
      self.messageService,
      self.gifService,
      self.mailserversService,
      self.walletAccountService,
      self.tokenService,
      self.collectibleService,
      self.communityTokensService
    )

  self.events.on(SIGNAL_COMMUNITY_DATA_LOADED) do(e:Args):
    self.delegate.onCommunityDataLoaded(
      self.events,
      self.settingsService,
      self.nodeConfigurationService,
      self.contactsService,
      self.chatService,
      self.communityService,
      self.messageService,
      self.gifService,
      self.mailserversService,
      self.walletAccountService,
      self.tokenService,
      self.collectibleService,
      self.communityTokensService
    )

  self.events.on(SIGNAL_CHANNEL_GROUPS_LOADING_FAILED) do(e:Args):
    self.delegate.onChatsLoadingFailed()

  self.events.on(SIGNAL_ACTIVE_MAILSERVER_CHANGED) do(e:Args):
    let args = ActiveMailserverChangedArgs(e)
    if args.nodeAddress == "":
      return
    self.delegate.emitMailserverWorking()
    echo "ACTIVE MAILSERVER CHANGED: ", repr(e)
    # We need to take some actions here. This is the only place where "activeMailserverChanged" signal should be handled.
    # Do the following, if we really need that.
    # requestAllHistoricMessagesResult
    # requestMissingCommunityInfos

  self.events.on(SIGNAL_MAILSERVER_NOT_WORKING) do(e: Args):
    self.delegate.emitMailserverNotWorking()

  self.events.on(SIGNAL_COMMUNITY_JOINED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityJoined(
      args.community,
      self.events,
      self.settingsService,
      self.nodeConfigurationService,
      self.contactsService,
      self.chatService,
      self.communityService,
      self.messageService,
      self.gifService,
      self.mailserversService,
      self.walletAccountService,
      self.tokenService,
      self.collectibleService,
      self.communityTokensService,
      setActive = args.fromUserAction
    )

  self.events.on(SIGNAL_COMMUNITY_SPECTATED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityJoined(
      args.community,
      self.events,
      self.settingsService,
      self.nodeConfigurationService,
      self.contactsService,
      self.chatService,
      self.communityService,
      self.messageService,
      self.gifService,
      self.mailserversService,
      self.walletAccountService,
      self.tokenService,
      self.collectibleService,
      self.communityTokensService,
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
      self.nodeConfigurationService,
      self.contactsService,
      self.chatService,
      self.communityService,
      self.messageService,
      self.gifService,
      self.mailserversService,
      self.walletAccountService,
      self.tokenService,
      self.collectibleService,
      self.communityTokensService,
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
      self.nodeConfigurationService,
      self.contactsService,
      self.chatService,
      self.communityService,
      self.messageService,
      self.gifService,
      self.mailserversService,
      self.walletAccountService,
      self.tokenService,
      self.collectibleService,
      self.communityTokensService,
      setActive = false
    )

  self.events.on(SIGNAL_COMMUNITY_DATA_IMPORTED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityDataImported(args.community)

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

  self.events.on(SIGNAL_COMMUNITY_MUTED) do(e:Args):
    let args = CommunityMutedArgs(e)
    self.delegate.onCommunityMuted(args.communityId, args.muted)

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

  self.events.on(SIGNAL_MNEMONIC_REMOVED) do(e: Args):
    self.delegate.mnemonicBackedUp()

  self.events.on(SIGNAL_MAKE_SECTION_CHAT_ACTIVE) do(e: Args):
    var args = ActiveSectionChatArgs(e)
    self.setActiveSection(args.sectionId)

  self.events.on(SIGNAL_STATUS_URL_REQUESTED) do(e: Args):
    var args = StatusUrlArgs(e)
    self.delegate.onStatusUrlRequested(args.action, args.communityId, args.chatId, args.url, args.userId)

  self.events.on(SIGNAL_OS_NOTIFICATION_CLICKED) do(e: Args):
    var args = ClickedNotificationArgs(e)
    self.delegate.osNotificationClicked(args.details)

  if defined(windows):
    self.events.on(SIGNAL_DISPLAY_WINDOWS_OS_NOTIFICATION) do(e: Args):
      var args = NotificationArgs(e)
      self.delegate.displayWindowsOsNotification(args.title, args.message)

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

  self.events.on(SIGNAL_COMMUNITY_MY_REQUEST_ADDED) do(e: Args):
    self.delegate.onMyRequestAdded();

  self.events.on(SIGNAL_COMMUNITY_TOKEN_DEPLOYED) do(e: Args):
    let args = CommunityTokenDeployedArgs(e)
    self.delegate.onCommunityTokenDeployed(args.communityToken)

  self.events.on(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS) do(e: Args):
    let args = CommunityTokenDeployedStatusArgs(e)
    self.delegate.onCommunityTokenDeployStateChanged(args.communityId, args.chainId, args.contractAddress, args.deployState)

  self.events.on(SIGNAL_COMMUNITY_TOKEN_OWNERS_FETCHED) do(e: Args):
    let args = CommunityTokenOwnersArgs(e)
    self.delegate.onCommunityTokenOwnersFetched(args.communityId, args.chainId, args.contractAddress, args.owners)

  self.events.on(SIGNAL_ACCEPT_REQUEST_TO_JOIN_LOADING) do(e: Args):
    var args = CommunityMemberArgs(e)
    self.delegate.onAcceptRequestToJoinLoading(args.communityId, args.pubKey)

  self.events.on(SIGNAL_ACCEPT_REQUEST_TO_JOIN_FAILED) do(e: Args):
    var args = CommunityMemberArgs(e)
    self.delegate.onAcceptRequestToJoinFailed(args.communityId, args.pubKey, args.requestId)

  self.events.on(SIGNAL_ACCEPT_REQUEST_TO_JOIN_FAILED_NO_PERMISSION) do(e: Args):
    var args = CommunityMemberArgs(e)
    self.delegate.onAcceptRequestToJoinFailedNoPermission(args.communityId, args.pubKey, args.requestId)

  self.events.on(SIGNAL_COMMUNITY_MEMBER_APPROVED) do(e: Args):
    var args = CommunityMemberArgs(e)
    self.delegate.onAcceptRequestToJoinSuccess(args.communityId, args.pubKey, args.requestId)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_FLOW_TERMINATED) do(e: Args):
    let args = SharedKeycarModuleFlowTerminatedArgs(e)
    if args.uniqueIdentifier == UNIQUE_MAIN_MODULE_KEYCARD_SYNC_IDENTIFIER:
      self.delegate.onSharedKeycarModuleKeycardSyncPurposeTerminated(args.lastStepInTheCurrentFlow)
      self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_KEYCARD_SYNC_TERMINATED, Args())
      return
    if args.uniqueIdentifier != UNIQUE_MAIN_MODULE_IDENTIFIER or
      self.authenticateUserFlowRequestedBy.len == 0:
        return
    self.delegate.onSharedKeycarModuleFlowTerminated(args.lastStepInTheCurrentFlow)
    let data = SharedKeycarModuleArgs(uniqueIdentifier: self.authenticateUserFlowRequestedBy,
      password: args.password,
      pin: args.pin,
      keyUid: args.keyUid,
      keycardUid: args.keycardUid)
    self.authenticateUserFlowRequestedBy = ""
    self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED, data)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_DISPLAY_POPUP) do(e: Args):
    let args = SharedKeycarModuleBaseArgs(e)
    if args.uniqueIdentifier != UNIQUE_MAIN_MODULE_IDENTIFIER or
      self.authenticateUserFlowRequestedBy.len == 0:
        return
    self.delegate.onDisplayKeycardSharedModuleFlow()

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER) do(e: Args):
    let args = SharedKeycarModuleAuthenticationArgs(e)
    self.authenticateUserFlowRequestedBy = args.uniqueIdentifier
    self.delegate.runAuthenticationPopup(args.keyUid)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_TRY_KEYCARD_SYNC) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    self.delegate.tryKeycardSync(args.keyUid, args.pin)

proc isConnected*(self: Controller): bool =
  return self.nodeService.isConnected()

proc getChannelGroups*(self: Controller): seq[ChannelGroupDto] =
  return self.chatService.getChannelGroups()

proc getActiveSectionId*(self: Controller): string =
  result = self.activeSectionId

proc setActiveSection*(self: Controller, sectionId: string, skipSavingInSettings: bool = false) =
  self.activeSectionId = sectionId
  if not skipSavingInSettings:
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

    if not chat.muted:
      result.unviewed += chat.unviewedMessagesCount
    result.mentions += chat.unviewedMentionsCount

proc sectionUnreadMessagesAndMentionsCount*(self: Controller, communityId: string):
    tuple[unviewedMessagesCount: int, unviewedMentionsCount: int] =
  return self.chatService.sectionUnreadMessagesAndMentionsCount(communityId)

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

proc getVerificationRequestFrom*(self: Controller, publicKey: string): VerificationRequest =
  self.contactsService.getVerificationRequestFrom(publicKey)

proc getCommunityTokens*(self: Controller, communityId: string): seq[CommunityTokenDto] =
  self.communityTokensService.getCommunityTokens(communityId)

proc getCommunityTokenOwners*(self: Controller, communityId: string, chainId: int, contractAddress: string): seq[CollectibleOwner] =
  return self.communityTokensService.getCommunityTokenOwners(communityId, chainId, contractAddress)

proc getCommunityTokenOwnerName*(self: Controller, chainId: int, contractAddress: string): string =
  return self.communityTokensService.contractOwnerName(chainId, contractAddress)

proc getNetwork*(self:Controller, chainId: int): NetworkDto =
  self.networksService.getNetwork(chainId)