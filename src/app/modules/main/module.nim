import NimQml, tables, json, sugar, sequtils, strformat, marshal, times

import io_interface, view, controller, chat_search_item, chat_search_model
import ephemeral_notification_item, ephemeral_notification_model
import ./communities/models/[pending_request_item, pending_request_model]
import ../shared_models/[user_item, member_item, member_model, section_item, section_model, active_section]
import ../../global/app_sections_config as conf
import ../../global/app_signals
import ../../global/global_singleton

import chat_section/[model, sub_item, sub_model]
import chat_section/base_item as chat_section_base_item
import chat_section/item as chat_section_item
import chat_section/module as chat_section_module
import wallet_section/module as wallet_section_module
import browser_section/module as browser_section_module
import profile_section/module as profile_section_module
import app_search/module as app_search_module
import stickers/module as stickers_module
import activity_center/module as activity_center_module
import communities/module as communities_module
import node_section/module as node_section_module
import networks/module as networks_module
import ../../../app_service/service/contacts/dto/contacts

import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/message/service as message_service
import ../../../app_service/service/token/service as token_service
import ../../../app_service/service/transaction/service as transaction_service
import ../../../app_service/service/collectible/service as collectible_service
import ../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../app_service/service/bookmarks/service as bookmark_service
import ../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../../app_service/service/provider/service as provider_service
import ../../../app_service/service/profile/service as profile_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/settings/service as settings_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/about/service as about_service
import ../../../app_service/service/language/service as language_service
import ../../../app_service/service/privacy/service as privacy_service
import ../../../app_service/service/stickers/service as stickers_service
import ../../../app_service/service/activity_center/service as activity_center_service
import ../../../app_service/service/saved_address/service as saved_address_service
import ../../../app_service/service/node/service as node_service
import ../../../app_service/service/node_configuration/service as node_configuration_service
import ../../../app_service/service/devices/service as devices_service
import ../../../app_service/service/mailservers/service as mailservers_service
import ../../../app_service/service/gif/service as gif_service
import ../../../app_service/service/ens/service as ens_service
import ../../../app_service/service/network/service as network_service
import ../../../app_service/service/general/service as general_service
from ../../../app_service/common/types import StatusType

import ../../core/notifications/details
import ../../core/eventemitter

export io_interface

const COMMUNITY_PERMISSION_ACCESS_ON_REQUEST = 3
const TOAST_MESSAGE_VISIBILITY_DURATION_IN_MS = 5000 # 5 seconds
const STATUS_URL_ENS_RESOLVE_REASON = "StatusUrl"
const MAX_MEMBERS_IN_GROUP_CHAT_WITHOUT_ADMIN = 19

type
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: Controller
    channelGroupModules: OrderedTable[string, chat_section_module.AccessInterface]
    walletSectionModule: wallet_section_module.AccessInterface
    browserSectionModule: browser_section_module.AccessInterface
    profileSectionModule: profile_section_module.AccessInterface
    stickersModule: stickers_module.AccessInterface
    activityCenterModule: activity_center_module.AccessInterface
    communitiesModule: communities_module.AccessInterface
    appSearchModule: app_search_module.AccessInterface
    nodeSectionModule: node_section_module.AccessInterface
    networksModule: networks_module.AccessInterface
    moduleLoaded: bool
    statusUrlGroupName: string
    statusUrlGroupMembers: seq[string] # used only for creating group chat from the status url
    statusUrlGroupMembersCount: int

# Forward declaration
method calculateProfileSectionHasNotification*[T](self: Module[T]): bool

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  tokenService: token_service.Service,
  transactionService: transaction_service.Service,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service,
  bookmarkService: bookmark_service.Service,
  profileService: profile_service.Service,
  settingsService: settings_service.Service,
  contactsService: contacts_service.Service,
  aboutService: about_service.Service,
  dappPermissionsService: dapp_permissions_service.Service,
  languageService: language_service.Service,
  privacyService: privacy_service.Service,
  providerService: provider_service.Service,
  stickersService: stickers_service.Service,
  activityCenterService: activity_center_service.Service,
  savedAddressService: saved_address_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  devicesService: devices_service.Service,
  mailserversService: mailservers_service.Service,
  nodeService: node_service.Service,
  gifService: gif_service.Service,
  ensService: ens_service.Service,
  networkService: network_service.Service,
  generalService: general_service.Service
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result,
    events,
    settingsService,
    keychainService,
    accountsService,
    chatService,
    communityService,
    contactsService,
    messageService,
    gifService,
    privacyService,
    mailserversService,
    nodeService,
  )
  result.moduleLoaded = false

  # Submodules
  result.channelGroupModules = initOrderedTable[string, chat_section_module.AccessInterface]()
  result.walletSectionModule = wallet_section_module.newModule(
    result, events, tokenService,
    transactionService, collectible_service, walletAccountService,
    settingsService, savedAddressService, networkService,
  )
  result.browserSectionModule = browser_section_module.newModule(
    result, events, bookmarkService, settingsService, networkService,
    dappPermissionsService, providerService, walletAccountService
  )
  result.profileSectionModule = profile_section_module.newModule(
    result, events, accountsService, settingsService, stickersService,
    profileService, contactsService, aboutService, languageService, privacyService, nodeConfigurationService,
    devicesService, mailserversService, chatService, ensService, walletAccountService, generalService, communityService,
    networkService,
  )
  result.stickersModule = stickers_module.newModule(result, events, stickersService, settingsService, walletAccountService, networkService)
  result.activityCenterModule = activity_center_module.newModule(result, events, activityCenterService, contactsService,
  messageService, chatService)
  result.communitiesModule = communities_module.newModule(result, events, communityService, contactsService)
  result.appSearchModule = app_search_module.newModule(result, events, contactsService, chatService, communityService,
  messageService)
  result.nodeSectionModule = node_section_module.newModule(result, events, settingsService, nodeService, nodeConfigurationService)
  result.networksModule = networks_module.newModule(result, events, networkService, walletAccountService, settingsService)

method delete*[T](self: Module[T]) =
  self.profileSectionModule.delete
  self.stickersModule.delete
  self.activityCenterModule.delete
  self.communitiesModule.delete
  for cModule in self.channelGroupModules.values:
    cModule.delete
  self.channelGroupModules.clear
  self.walletSectionModule.delete
  self.browserSectionModule.delete
  self.appSearchModule.delete
  self.nodeSectionModule.delete
  self.networksModule.delete
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

proc createChannelGroupItem[T](self: Module[T], c: ChannelGroupDto): SectionItem =
  let isCommunity = c.channelGroupType == ChannelGroupType.Community
  var communityDetails: CommunityDto
  var unviewedCount, mentionsCount: int
  if (isCommunity):
    (unviewedCount, mentionsCount) = self.controller.getNumOfNotificationsForCommunity(c.id)
    communityDetails = self.controller.getCommunityById(c.id)
  else:
    let receivedContactRequests = self.controller.getContacts(ContactsGroup.IncomingPendingContactRequests)
    (unviewedCount, mentionsCount) = self.controller.getNumOfNotificaitonsForChat()
    mentionsCount = mentionsCount + receivedContactRequests.len

  let hasNotification = unviewedCount > 0 or mentionsCount > 0
  let notificationsCount = mentionsCount # we need to add here number of requests
  let active = self.getActiveSectionId() == c.id # We must pass on if the current item section is currently active to keep that property as it is
  result = initItem(
    c.id,
    if isCommunity: SectionType.Community else: SectionType.Chat,
    if isCommunity: c.name else: "Chat",
    c.admin,
    c.description,
    c.introMessage,
    c.outroMessage,
    c.images.thumbnail,
    c.images.banner,
    icon = if (isCommunity): "" else: conf.CHAT_SECTION_ICON,
    c.color,
    if isCommunity: communityDetails.tags else: "",
    hasNotification,
    notificationsCount,
    active,
    enabled = true,
    if (isCommunity): communityDetails.joined else: true,
    if (isCommunity): communityDetails.canJoin else: true,
    c.canManageUsers,
    if (isCommunity): communityDetails.canRequestAccess else: true,
    if (isCommunity): communityDetails.isMember else: true,
    c.permissions.access,
    c.permissions.ensOnly,
    c.muted,
    c.members.map(proc(member: ChatMember): MemberItem =
      let contactDetails = self.controller.getContactDetails(member.id)
      result = initMemberItem(
        pubKey = member.id,
        displayName = contactDetails.displayName,
        ensName = contactDetails.details.name,
        localNickname = contactDetails.details.localNickname,
        alias = contactDetails.details.alias,
        icon = contactDetails.icon,
        onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(member.id).statusType),
        isContact = contactDetails.details.isContact
        )),
    if (isCommunity): communityDetails.pendingRequestsToJoin.map(x => pending_request_item.initItem(
      x.id,
      x.publicKey,
      x.chatId,
      x.communityId,
      x.state,
      x.our
    )) else: @[],
    communityDetails.settings.historyArchiveSupportEnabled,
    communityDetails.adminSettings.pinMessageAllMembersEnabled
  )



method load*[T](
  self: Module[T],
  events: EventEmitter,
  settingsService: settings_service.Service,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service,
) =
  singletonInstance.engine.setRootContextProperty("mainModule", self.viewVariant)
  self.controller.init()
  self.view.load()

  var activeSection: SectionItem
  var activeSectionId = singletonInstance.localAccountSensitiveSettings.getActiveSection()
  if (activeSectionId == ""):
    activeSectionId = singletonInstance.userProfile.getPubKey()

  let channelGroups = self.controller.getChannelGroups()
  for channelGroup in channelGroups:
    self.channelGroupModules[channelGroup.id] = chat_section_module.newModule(
      self,
      events,
      channelGroup.id,
      isCommunity = channelGroup.channelGroupType == ChannelGroupType.Community,
      settingsService,
      contactsService,
      chatService,
      communityService,
      messageService,
      gifService,
      mailserversService
    )
    let channelGroupItem = self.createChannelGroupItem(channelGroup)
    self.view.model().addItem(channelGroupItem)
    if(activeSectionId == channelGroupItem.id):
      activeSection = channelGroupItem
    
    self.channelGroupModules[channelGroup.id].load(channelGroup, events, settingsService,
      contactsService, chatService, communityService, messageService, gifService, mailserversService)

  # Communities Portal Section
  let communitiesPortalSectionItem = initItem(conf.COMMUNITIESPORTAL_SECTION_ID, SectionType.CommunitiesPortal, conf.COMMUNITIESPORTAL_SECTION_NAME,
  amISectionAdmin = false,
  description = "",
  image = "",
  icon = conf.COMMUNITIESPORTAL_SECTION_ICON,
  color = "",
  hasNotification = false,
  notificationsCount = 0,
  active = false,
  enabled = true)
  self.view.model().addItem(communitiesPortalSectionItem)
  if(activeSectionId == communitiesPortalSectionItem.id):
    activeSection = communitiesPortalSectionItem

  # Wallet Section
  let walletSectionItem = initItem(conf.WALLET_SECTION_ID, SectionType.Wallet, conf.WALLET_SECTION_NAME,
  amISectionAdmin = false,
  description = "",
  introMessage = "",
  outroMessage = "",
  image = "",
  icon = conf.WALLET_SECTION_ICON,
  color = "",
  hasNotification = false,
  notificationsCount = 0,
  active = false,
  enabled = singletonInstance.localAccountSensitiveSettings.getIsWalletEnabled())
  self.view.model().addItem(walletSectionItem)
  if(activeSectionId == walletSectionItem.id):
    activeSection = walletSectionItem

  # Browser Section
  let browserSectionItem = initItem(conf.BROWSER_SECTION_ID, SectionType.Browser, conf.BROWSER_SECTION_NAME,
  amISectionAdmin = false,
  description = "",
  introMessage = "",
  outroMessage = "",
  image = "",
  icon = conf.BROWSER_SECTION_ICON,
  color = "",
  hasNotification = false,
  notificationsCount = 0,
  active = false,
  enabled = singletonInstance.localAccountSensitiveSettings.getIsBrowserEnabled())
  self.view.model().addItem(browserSectionItem)
  if(activeSectionId == browserSectionItem.id):
    activeSection = browserSectionItem

  # Node Management Section
  let nodeManagementSectionItem = initItem(conf.NODEMANAGEMENT_SECTION_ID, SectionType.NodeManagement,
  conf.NODEMANAGEMENT_SECTION_NAME,
  amISectionAdmin = false,
  description = "",
  introMessage = "",
  outroMessage = "",
  image = "",
  icon = conf.NODEMANAGEMENT_SECTION_ICON,
  color = "",
  hasNotification = false,
  notificationsCount = 0,
  active = false,
  enabled = singletonInstance.localAccountSensitiveSettings.getNodeManagementEnabled())
  self.view.model().addItem(nodeManagementSectionItem)
  if(activeSectionId == nodeManagementSectionItem.id):
    activeSection = nodeManagementSectionItem

  # Profile Section
  let profileSettingsSectionItem = initItem(conf.SETTINGS_SECTION_ID, SectionType.ProfileSettings,
  conf.SETTINGS_SECTION_NAME,
  amISectionAdmin = false,
  description = "",
  introMessage = "",
  outroMessage = "",
  image = "",
  icon = conf.SETTINGS_SECTION_ICON,
  color = "",
  hasNotification = self.calculateProfileSectionHasNotification(),
  notificationsCount = 0,
  active = false,
  enabled = true)
  self.view.model().addItem(profileSettingsSectionItem)
  if(activeSectionId == profileSettingsSectionItem.id):
    activeSection = profileSettingsSectionItem

  self.browserSectionModule.load()
  # self.nodeManagementSectionModule.load()
  self.profileSectionModule.load()
  self.stickersModule.load()
  self.networksModule.load()
  self.activityCenterModule.load()
  self.communitiesModule.load()
  self.appSearchModule.load()
  self.nodeSectionModule.load()
  # Load wallet last as it triggers events that are listened by other modules
  self.walletSectionModule.load()
  #self.communitiesPortalSectionModule.load()

  # Set active section on app start
  # If section is profile then open chat by default
  if activeSection.sectionType == SectionType.ProfileSettings:
    self.setActiveSection(self.view.model().getItemBySectionType(SectionType.Chat))
  else:
    self.setActiveSection(activeSection)

proc checkIfModuleDidLoad [T](self: Module[T]) =
  if self.moduleLoaded:
    return

  for cModule in self.channelGroupModules.values:
    if(not cModule.isLoaded()):
      return

#  if (not self.communitiesPortalSectionModule.isLoaded()):
#    return

  if (not self.walletSectionModule.isLoaded()):
    return

  if(not self.browserSectionModule.isLoaded()):
    return

  if(not self.nodeSectionModule.isLoaded()):
    return

  if(not self.profileSectionModule.isLoaded()):
    return

  if(not self.stickersModule.isLoaded()):
    return

  if(not self.activityCenterModule.isLoaded()):
    return

  if(not self.communitiesModule.isLoaded()):
    return

  if(not self.appSearchModule.isLoaded()):
    return

  if(not self.networksModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.mainDidLoad()

method chatSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method communitySectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method appSearchDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method stickersDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method activityCenterDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method communitiesModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

#method communitiesPortalSectionDidLoad*[T](self: Module[T]) =
#  self.checkIfModuleDidLoad()

method walletSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method browserSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method profileSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method nodeSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method networksModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method viewDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method checkForStoringPassword*[T](self: Module[T]) =
  self.controller.checkForStoringPassword()

method offerToStorePassword*[T](self: Module[T]) =
  self.view.offerToStorePassword()

method storePassword*[T](self: Module[T], password: string) =
  self.controller.storePassword(password)

method emitStoringPasswordError*[T](self: Module[T], errorDescription: string) =
  self.view.emitStoringPasswordError(errorDescription)

method emitStoringPasswordSuccess*[T](self: Module[T]) =
  self.view.emitStoringPasswordSuccess()

method emitMailserverNotWorking*[T](self: Module[T]) =
  self.view.emitMailserverNotWorking()

method getActiveSectionId*[T](self: Module[T]): string =
  return self.controller.getActiveSectionId()

method setActiveSection*[T](self: Module[T], item: SectionItem) =
  if(item.isEmpty()):
    echo "section is empty and cannot be made as active one"
    return

  self.controller.setActiveSection(item.id)

proc notifySubModulesAboutChange[T](self: Module[T], sectionId: string) =
  for cModule in self.channelGroupModules.values:
    cModule.onActiveSectionChange(sectionId)

  # If there is a need other section may be notified the same way from here...

method activeSectionSet*[T](self: Module[T], sectionId: string) =
  let item = self.view.model().getItemById(sectionId)
  if(item.isEmpty()):
    # should never be here
    echo "main-module, incorrect section id: ", sectionId
    return

  self.view.model().setActiveSection(sectionId)
  self.view.activeSectionSet(item)

  self.notifySubModulesAboutChange(sectionId)

proc setSectionAvailability[T](self: Module[T], sectionType: SectionType, available: bool) =
  if(available):
    self.view.model().enableSection(sectionType)
  else:
    self.view.model().disableSection(sectionType)

method toggleSection*[T](self: Module[T], sectionType: SectionType) =
  if (sectionType == SectionType.Wallet):
    let enabled = singletonInstance.localAccountSensitiveSettings.getIsWalletEnabled()
    self.setSectionAvailability(sectionType, not enabled)
    singletonInstance.localAccountSensitiveSettings.setIsWalletEnabled(not enabled)
  elif (sectionType == SectionType.Browser):
    let enabled = singletonInstance.localAccountSensitiveSettings.getIsBrowserEnabled()
    self.setSectionAvailability(sectionType, not enabled)
    singletonInstance.localAccountSensitiveSettings.setIsBrowserEnabled(not enabled)
  elif (sectionType == SectionType.NodeManagement):
    let enabled = singletonInstance.localAccountSensitiveSettings.getNodeManagementEnabled()
    self.setSectionAvailability(sectionType, not enabled)
    singletonInstance.localAccountSensitiveSettings.setNodeManagementEnabled(not enabled)

method setCurrentUserStatus*[T](self: Module[T], status: StatusType) =
  self.controller.setCurrentUserStatus(status)

proc getChatSectionModule*[T](self: Module[T]): chat_section_module.AccessInterface =
  return self.channelGroupModules[singletonInstance.userProfile.getPubKey()]

method getChatSectionModuleAsVariant*[T](self: Module[T]): QVariant =
  return self.getChatSectionModule().getModuleAsVariant()

method getCommunitySectionModule*[T](self: Module[T], communityId: string): QVariant =
  if(not self.channelGroupModules.contains(communityId)):
    echo "main-module, unexisting community key: ", communityId
    return

  return self.channelGroupModules[communityId].getModuleAsVariant()

method rebuildChatSearchModel*[T](self: Module[T]) =
  let transformItem = proc(item: chat_section_base_item.BaseItem, sectionId, sectionName: string): chat_search_item.Item =
    result = chat_search_item.initItem(item.id(), item.name(), item.color(), item.icon(), sectionId, sectionName)

  let transform = proc(items: seq[chat_section_item.Item], sectionId, sectionName: string): seq[chat_search_item.Item] =
    for item in items:
      if item.type() != ChatType.Unknown.int:
        result.add(transformItem(item, sectionId, sectionName))
      else:
        for subItem in item.subItems().items():
          result.add(transformItem(subItem, sectionId, sectionName))

  var items: seq[chat_search_item.Item] = @[]
  for cId in self.channelGroupModules.keys:
    items.add(transform(self.channelGroupModules[cId].chatsModel().items(), cId,
      self.view.model().getItemById(cId).name()))

  self.view.chatSearchModel().setItems(items)

method switchTo*[T](self: Module[T], sectionId, chatId: string) =
  self.controller.switchTo(sectionId, chatId, "")

method onActiveChatChange*[T](self: Module[T], sectionId: string, chatId: string) =
  self.appSearchModule.onActiveChatChange(sectionId, chatId)

method onChatLeft*[T](self: Module[T], chatId: string) =
  self.appSearchModule.updateSearchLocationIfPointToChatWithId(chatId)

method onNotificationsUpdated[T](self: Module[T], sectionId: string, sectionHasUnreadMessages: bool,
  sectionNotificationCount: int) =
  self.view.model().updateNotifications(sectionId, sectionHasUnreadMessages, sectionNotificationCount)

method onNetworkConnected[T](self: Module[T]) =
  self.view.setConnected(true)

method onNetworkDisconnected[T](self: Module[T]) =
  self.view.setConnected(false)

method isConnected[T](self: Module[T]): bool =
  self.controller.isConnected()

method getAppSearchModule*[T](self: Module[T]): QVariant =
  self.appSearchModule.getModuleAsVariant()

method communityJoined*[T](
  self: Module[T],
  community: CommunityDto,
  events: EventEmitter,
  settingsService: settings_service.Service,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service,
  setActive: bool = false,
) =
  var firstCommunityJoined = false
  if (self.channelGroupModules.len == 1): # First one is personal chat section
    firstCommunityJoined = true
  self.channelGroupModules[community.id] = chat_section_module.newModule(
      self,
      events,
      community.id,
      isCommunity = true,
      settingsService,
      contactsService,
      chatService,
      communityService,
      messageService,
      gifService,
      mailserversService
    )
  let channelGroup = community.toChannelGroupDto()
  self.channelGroupModules[community.id].load(channelGroup, events, settingsService, contactsService,
    chatService, communityService, messageService, gifService, mailserversService)

  let communitySectionItem = self.createChannelGroupItem(channelGroup)
  if (firstCommunityJoined):
    # If there are no other communities, add the first community after the Chat section in the model so that the order is respected
    self.view.model().addItem(communitySectionItem,
      self.view.model().getItemIndex(singletonInstance.userProfile.getPubKey()) + 1)
  else:
    self.view.model().addItem(communitySectionItem)

  if(community.permissions.access == COMMUNITY_PERMISSION_ACCESS_ON_REQUEST and 
    community.requestedToJoinAt > 0 and 
    community.joined):
    singletonInstance.globalEvents.myRequestToJoinCommunityAcccepted("Community Request Accepted",
      fmt "Your request to join community {community.name} is accepted", community.id)

  if setActive:
    self.setActiveSection(communitySectionItem)
    if(channelGroup.chats.len > 0):
      let chatId = channelGroup.chats[0].id
      self.channelGroupModules[community.id].setActiveItemSubItem(chatId, "")

method communityLeft*[T](self: Module[T], communityId: string) =
  if(not self.channelGroupModules.contains(communityId)):
    echo "main-module, unexisting community key to leave: ", communityId
    return

  self.channelGroupModules.del(communityId)

  self.view.model().removeItem(communityId)

  if (self.controller.getActiveSectionId() == communityId):
    let item = self.view.model().getItemById(singletonInstance.userProfile.getPubKey())
    self.setActiveSection(item)

method communityEdited*[T](
    self: Module[T],
    community: CommunityDto) =
  let channelGroup = community.toChannelGroupDto()
  self.view.editItem(self.createChannelGroupItem(channelGroup))

method getContactDetailsAsJson*[T](self: Module[T], publicKey: string): string =
  let contact =  self.controller.getContact(publicKey)
  let (name, _, _) = self.controller.getContactNameAndImage(contact.id)
  let jsonObj = %* {
    "displayName": name,
    "displayIcon": contact.image.thumbnail,
    "publicKey": contact.id,
    "name": contact.name,
    "ensVerified": contact.ensVerified,
    "alias": contact.alias,
    "lastUpdated": contact.lastUpdated,
    "lastUpdatedLocally": contact.lastUpdatedLocally,
    "localNickname": contact.localNickname,
    "thumbnailImage": contact.image.thumbnail,
    "largeImage": contact.image.large,
    "isContact": contact.isContact,
    "isBlocked": contact.blocked,
    "requestReceived": contact.hasAddedUs,
    "isAdded": contact.isContactRequestSent,
    "isSyncing": contact.isSyncing,
    "removed": contact.removed,
    "trustStatus": contact.trustStatus.int,
    "verificationStatus": contact.verificationStatus.int,
    "hasAddedUs": contact.hasAddedUs
  }
  return $jsonObj

method resolveENS*[T](self: Module[T], ensName: string, uuid: string, reason: string = "") =
  if ensName.len == 0:
    echo "error: cannot do a lookup for empty ens name"
    return
  self.controller.resolveENS(ensName, uuid, reason)

method resolvedENS*[T](self: Module[T], publicKey: string, address: string, uuid: string, reason: string) =
  if(reason.len > 0 and publicKey.len == 0):
    self.displayEphemeralNotification("Unexisting contact", "Wrong public key or ens name", "", false, EphemeralNotificationType.Default.int, "")
    return
  
  if(reason == STATUS_URL_ENS_RESOLVE_REASON & $StatusUrlAction.DisplayUserProfile):
    let item = self.view.model().getItemById(singletonInstance.userProfile.getPubKey())
    self.setActiveSection(item)
    self.view.emitDisplayUserProfileSignal(publicKey)
  elif(reason == STATUS_URL_ENS_RESOLVE_REASON & $StatusUrlAction.OpenOrCreatePrivateChat):
    let item = self.view.model().getItemById(singletonInstance.userProfile.getPubKey())
    self.setActiveSection(item)
    self.getChatSectionModule().switchToOrCreateOneToOneChat(publicKey)
  elif(reason == STATUS_URL_ENS_RESOLVE_REASON & $StatusUrlAction.OpenOrCreateGroupChat):
    self.statusUrlGroupMembers.add(publicKey)
    if(self.statusUrlGroupMembers.len == self.statusUrlGroupMembersCount):
      let item = self.view.model().getItemById(singletonInstance.userProfile.getPubKey())
      self.setActiveSection(item)
      self.getChatSectionModule().createGroupChat(self.statusUrlGroupName, self.statusUrlGroupMembers)
      self.statusUrlGroupName = ""
      self.statusUrlGroupMembers = @[]
      self.statusUrlGroupMembersCount = 0
  else:
    self.view.emitResolvedENSSignal(publicKey, address, uuid)

method contactsStatusUpdated*[T](self: Module[T], statusUpdates: seq[StatusUpdateDto]) =
  for s in statusUpdates:
    let status = toOnlineStatus(s.statusType)
    self.view.activeSection().setOnlineStatusForMember(s.publicKey, status)

method contactUpdated*[T](self: Module[T], publicKey: string) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.activeSection().updateMember(
    publicKey,
    contactDetails.displayName,
    contactDetails.details.name,
    contactDetails.details.localNickname,
    contactDetails.details.alias,
    contactDetails.icon,
    isContact = contactDetails.details.isContact,
    isUntrustworthy = contactDetails.details.isContactUntrustworthy(),
    )

method calculateProfileSectionHasNotification*[T](self: Module[T]): bool =
  return not self.controller.isMnemonicBackedUp()

method mnemonicBackedUp*[T](self: Module[T]) =
  self.view.model().updateNotifications(
    conf.SETTINGS_SECTION_ID,
    self.calculateProfileSectionHasNotification(),
    notificationsCount = 0)

method osNotificationClicked*[T](self: Module[T], details: NotificationDetails) =
  if(details.notificationType == NotificationType.NewContactRequest):
    self.controller.switchTo(details.sectionId, "", "")
    self.view.emitOpenContactRequestsPopupSignal()
  elif(details.notificationType == NotificationType.JoinCommunityRequest):
    self.controller.switchTo(details.sectionId, "", "")
    self.view.emitOpenCommunityMembershipRequestsPopupSignal(details.sectionId)
  elif(details.notificationType == NotificationType.MyRequestToJoinCommunityAccepted):
    self.controller.switchTo(details.sectionId, "", "")
  elif(details.notificationType == NotificationType.MyRequestToJoinCommunityRejected):
    echo "There is no particular action clicking on a notification informing you about rejection to join community"

method newCommunityMembershipRequestReceived*[T](self: Module[T], membershipRequest: CommunityMembershipRequestDto) =
  let (contactName, _, _) = self.controller.getContactNameAndImage(membershipRequest.publicKey)
  let community =  self.controller.getCommunityById(membershipRequest.communityId)
  singletonInstance.globalEvents.newCommunityMembershipRequestNotification("New membership request",
  fmt "{contactName} asks to join {community.name}", community.id)

method meMentionedCountChanged*[T](self: Module[T], allMentions: int) =
  singletonInstance.globalEvents.meMentionedIconBadgeNotification(allMentions)

method displayEphemeralNotification*[T](self: Module[T], title: string, subTitle: string, icon: string, loading: bool, 
  ephNotifType: int, url: string, details = NotificationDetails()) =
  let now = getTime()
  let id = now.toUnix * 1000000000 + now.nanosecond
  var finalEphNotifType = EphemeralNotificationType.Default
  if(ephNotifType == EphemeralNotificationType.Success.int):
    finalEphNotifType = EphemeralNotificationType.Success
  let item = ephemeral_notification_item.initItem(id, title, TOAST_MESSAGE_VISIBILITY_DURATION_IN_MS, subTitle, icon,
  loading, finalEphNotifType, url, details)
  self.view.ephemeralNotificationModel().addItem(item)

method displayEphemeralNotification*[T](self: Module[T], title: string, subTitle: string, details: NotificationDetails) =
  if(details.notificationType == NotificationType.NewMessage or 
    details.notificationType == NotificationType.NewMessageWithPersonalMention or
    details.notificationType == NotificationType.NewMessageWithGlobalMention):
    self.displayEphemeralNotification(title, subTitle, "", false, EphemeralNotificationType.Default.int, "", details)
  
  elif(details.notificationType == NotificationType.NewContactRequest or 
    details.notificationType == NotificationType.IdentityVerificationRequest):
    self.displayEphemeralNotification(title, subTitle, "contact", false, EphemeralNotificationType.Default.int, "", details)

  elif(details.notificationType == NotificationType.AcceptedContactRequest):
    self.displayEphemeralNotification(title, subTitle, "checkmark-circle", false, EphemeralNotificationType.Success.int, "", details)

method removeEphemeralNotification*[T](self: Module[T], id: int64) =
  self.view.ephemeralNotificationModel().removeItemWithId(id)

method ephemeralNotificationClicked*[T](self: Module[T], id: int64) =
  let item = self.view.ephemeralNotificationModel().getItemWithId(id)
  if(item.details.isEmpty()):
    return
  if(item.details.notificationType == NotificationType.NewMessage or 
    item.details.notificationType == NotificationType.NewMessageWithPersonalMention or
    item.details.notificationType == NotificationType.NewMessageWithGlobalMention):
    self.controller.switchTo(item.details.sectionId, item.details.chatId, item.details.messageId)
  else:
    self.osNotificationClicked(item.details)

method onStatusUrlRequested*[T](self: Module[T], action: StatusUrlAction, communityId: string, chatId: string, 
  url: string, userId: string, groupName: string, listOfUserIds: seq[string]) =
  
  if(action == StatusUrlAction.OpenLinkInBrowser and singletonInstance.localAccountSensitiveSettings.getIsBrowserEnabled()):
    let item = self.view.model().getItemById(conf.BROWSER_SECTION_ICON)
    self.setActiveSection(item)
    self.browserSectionModule.openUrl(url)

  elif(action == StatusUrlAction.DisplayUserProfile):
    self.resolveENS(userId, "", STATUS_URL_ENS_RESOLVE_REASON & $StatusUrlAction.DisplayUserProfile)

  elif(action == StatusUrlAction.OpenOrCreatePrivateChat):
    self.resolveENS(chatId, "", STATUS_URL_ENS_RESOLVE_REASON & $StatusUrlAction.OpenOrCreatePrivateChat)

  elif(action == StatusUrlAction.OpenOrJoinPublicChat):
    let item = self.view.model().getItemById(singletonInstance.userProfile.getPubKey())
    self.setActiveSection(item)
    self.getChatSectionModule().createPublicChat(chatId)

  elif(action == StatusUrlAction.OpenOrCreateGroupChat):
    self.statusUrlGroupName = groupName
    # if there are more than 20 members added to the url, we add only first 19
    self.statusUrlGroupMembersCount = if listOfUserIds.len <= MAX_MEMBERS_IN_GROUP_CHAT_WITHOUT_ADMIN: listOfUserIds.len else: MAX_MEMBERS_IN_GROUP_CHAT_WITHOUT_ADMIN
    var i = 0
    for id in listOfUserIds:
      if(i >= MAX_MEMBERS_IN_GROUP_CHAT_WITHOUT_ADMIN):
        break
      i.inc
      self.resolveENS(id, "", STATUS_URL_ENS_RESOLVE_REASON & $StatusUrlAction.OpenOrCreateGroupChat)
  
  elif(action == StatusUrlAction.RequestToJoinCommunity):
    let item = self.view.model().getItemById(singletonInstance.userProfile.getPubKey())
    self.setActiveSection(item)
    self.communitiesModule.requestToJoinCommunity(communityId, singletonInstance.userProfile.getName())

  elif(action == StatusUrlAction.OpenCommunity):
    let item = self.view.model().getItemById(communityId)
    self.setActiveSection(item)

  elif(action == StatusUrlAction.OpenCommunityChannel):
    for cId, cModule in self.channelGroupModules.pairs:
      if(cId == singletonInstance.userProfile.getPubKey()):
        continue
      if(cModule.doesCatOrChatExist(chatId)):
        let item = self.view.model().getItemById(cId)
        self.setActiveSection(item)

        cModule.makeChatWithIdActive(chatId)
        break
