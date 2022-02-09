import NimQml, tables, json, sugar, sequtils

import io_interface, view, controller, chat_search_item, chat_search_model
import ./communities/models/[pending_request_item, pending_request_model]
import ../shared_models/[user_item, user_model, section_item, section_model, active_section]
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
import ../../../app_service/service/settings/service_interface as settings_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/about/service as about_service
import ../../../app_service/service/language/service_interface as language_service
import ../../../app_service/service/privacy/service as privacy_service
import ../../../app_service/service/stickers/service as stickers_service
import ../../../app_service/service/activity_center/service as activity_center_service
import ../../../app_service/service/saved_address/service as saved_address_service
import ../../../app_service/service/node/service as node_service
import ../../../app_service/service/node_configuration/service_interface as node_configuration_service
import ../../../app_service/service/devices/service as devices_service
import ../../../app_service/service/mailservers/service as mailservers_service
import ../../../app_service/service/gif/service as gif_service
import ../../../app_service/service/ens/service as ens_service
import ../../../app_service/service/network/service as network_service


import ../../core/eventemitter

export io_interface

type
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    chatSectionModule: chat_section_module.AccessInterface
    communitySectionsModule: OrderedTable[string, chat_section_module.AccessInterface]
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

# Forward declaration
method calculateProfileSectionHasNotification*[T](self: Module[T]): bool

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.ServiceInterface,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  tokenService: token_service.Service,
  transactionService: transaction_service.Service,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service,
  bookmarkService: bookmark_service.ServiceInterface,
  profileService: profile_service.ServiceInterface,
  settingsService: settings_service.ServiceInterface,
  contactsService: contacts_service.Service,
  aboutService: about_service.Service,
  dappPermissionsService: dapp_permissions_service.ServiceInterface,
  languageService: language_service.ServiceInterface,
  privacyService: privacy_service.Service,
  providerService: provider_service.ServiceInterface,
  stickersService: stickers_service.Service,
  activityCenterService: activity_center_service.Service,
  savedAddressService: saved_address_service.ServiceInterface,
  nodeConfigurationService: node_configuration_service.ServiceInterface,
  devicesService: devices_service.Service,
  mailserversService: mailservers_service.Service,
  nodeService: node_service.Service,
  gifService: gif_service.Service,
  ensService: ens_service.Service,
  networkService: network_service.Service,
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
    mailserversService
  )
  result.moduleLoaded = false

  # Submodules
  result.chatSectionModule = chat_section_module.newModule(result, events, conf.CHAT_SECTION_ID, false, settingsService,
  contactsService, chatService, communityService, messageService, gifService, mailserversService)
  result.communitySectionsModule = initOrderedTable[string, chat_section_module.AccessInterface]()
  result.walletSectionModule = wallet_section_module.newModule[Module[T]](
    result, events, tokenService,
    transactionService, collectible_service, walletAccountService,
    settingsService, savedAddressService
  )
  result.browserSectionModule = browser_section_module.newModule(result, bookmarkService, settingsService,
  dappPermissionsService, providerService)
  result.profileSectionModule = profile_section_module.newModule(
    result, events, accountsService, settingsService,
    profileService, contactsService, aboutService, languageService, privacyService, nodeConfigurationService,
    devicesService, mailserversService, chatService, ensService, walletAccountService,
  )
  result.stickersModule = stickers_module.newModule(result, events, stickersService)
  result.activityCenterModule = activity_center_module.newModule(result, events, activityCenterService, contactsService,
  messageService)
  result.communitiesModule = communities_module.newModule(result, events, communityService, contactsService)
  result.appSearchModule = app_search_module.newModule(result, events, contactsService, chatService, communityService,
  messageService)
  result.nodeSectionModule = node_section_module.newModule(result, events, settingsService, nodeService, nodeConfigurationService)
  result.networksModule = networks_module.newModule(result, events, networkService, walletAccountService)

method delete*[T](self: Module[T]) =
  self.chatSectionModule.delete
  self.profileSectionModule.delete
  self.stickersModule.delete
  self.activityCenterModule.delete
  self.communitiesModule.delete
  for cModule in self.communitySectionsModule.values:
    cModule.delete
  self.communitySectionsModule.clear
  self.walletSectionModule.delete
  self.browserSectionModule.delete
  self.appSearchModule.delete
  self.nodeSectionModule.delete
  self.networksModule.delete
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

proc createCommunityItem[T](self: Module[T], c: CommunityDto): SectionItem =
  let (unviewedCount, mentionsCount) = self.controller.getNumOfNotificationsForCommunity(c.id)
  let hasNotification = unviewedCount > 0 or mentionsCount > 0
  let notificationsCount = mentionsCount # we need to add here number of requests
  let active = self.getActiveSectionId() == c.id # We must pass on if the current item section is currently active to keep that property as it is
  result = initItem(
    c.id,
    SectionType.Community,
    c.name,
    c.admin,
    c.description,
    c.images.thumbnail,
    icon = "",
    c.color,
    hasNotification,
    notificationsCount,
    active,
    enabled = singletonInstance.localAccountSensitiveSettings.getCommunitiesEnabled(),
    c.joined,
    c.canJoin,
    c.canManageUsers,
    c.canRequestAccess,
    c.isMember,
    c.permissions.access,
    c.permissions.ensOnly,
    c.members.map(proc(member: Member): user_item.Item =
      let contactDetails = self.controller.getContactDetails(member.id)
      result = user_item.initItem(
        member.id,
        contactDetails.displayName,
        contactDetails.details.name,
        contactDetails.details.localNickname,
        contactDetails.details.alias,
        OnlineStatus.Offline,
        contactDetails.icon,
        contactDetails.isidenticon,
        )),
    c.pendingRequestsToJoin.map(x => pending_request_item.initItem(
      x.id,
      x.publicKey,
      x.chatId,
      x.communityId,
      x.state,
      x.our
    ))
  )

method load*[T](
  self: Module[T],
  events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service
) =
  singletonInstance.engine.setRootContextProperty("mainModule", self.viewVariant)
  self.controller.init()
  self.view.load()

  # Create community modules here, since we don't know earlier how many joined communities we have.
  let joinedCommunities = self.controller.getJoinedCommunities()

  for c in joinedCommunities:
    self.communitySectionsModule[c.id] = chat_section_module.newModule(
      self,
      events,
      c.id,
      isCommunity = true,
      settingsService,
      contactsService,
      chatService,
      communityService,
      messageService,
      gifService,
      mailserversService
    )

  var activeSection: SectionItem
  var activeSectionId = singletonInstance.localAccountSensitiveSettings.getActiveSection()

  # Chat Section
  let receivedContactRequests = self.controller.getContacts().filter(x => x.requestReceived() and not x.isContact() and not x.isBlocked())
  let (unviewedCount, mentionsCount) = self.controller.getNumOfNotificaitonsForChat()
  let notificationsCount = mentionsCount + receivedContactRequests.len
  let hasNotification = unviewedCount > 0 or notificationsCount > 0
  let chatSectionItem = initItem(conf.CHAT_SECTION_ID, SectionType.Chat, conf.CHAT_SECTION_NAME,
  amISectionAdmin = false,
  description = "",
  image = "",
  conf.CHAT_SECTION_ICON,
  color = "",
  hasNotification,
  notificationsCount,
  active = false,
  enabled = true)
  self.view.model().addItem(chatSectionItem)
  if(activeSectionId == chatSectionItem.id):
    activeSection = chatSectionItem

  # Community Section
  for c in joinedCommunities:
    let communitySectionItem = self.createCommunityItem(c)
    self.view.model().addItem(communitySectionItem)
    if(activeSectionId == communitySectionItem.id):
      activeSection = communitySectionItem

  # Wallet Section
  let walletSectionItem = initItem(conf.WALLET_SECTION_ID, SectionType.Wallet, conf.WALLET_SECTION_NAME,
  amISectionAdmin = false,
  description = "",
  image = "",
  conf.WALLET_SECTION_ICON,
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
  image = "",
  conf.BROWSER_SECTION_ICON,
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
  image = "",
  conf.NODEMANAGEMENT_SECTION_ICON,
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
  image = "",
  conf.SETTINGS_SECTION_ICON,
  color = "",
  hasNotification = self.calculateProfileSectionHasNotification(),
  notificationsCount = 0,
  active = false,
  enabled = true)
  self.view.model().addItem(profileSettingsSectionItem)
  if(activeSectionId == profileSettingsSectionItem.id):
    activeSection = profileSettingsSectionItem

  # Load all sections
  self.chatSectionModule.load(events, settingsService, contactsService, chatService, communityService, messageService, gifService, mailserversService)
  for cModule in self.communitySectionsModule.values:
    cModule.load(events, settingsService, contactsService, chatService, communityService, messageService, gifService, mailserversService)

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

  # Set active section on app start
  self.setActiveSection(activeSection)

proc checkIfModuleDidLoad [T](self: Module[T]) =
  if self.moduleLoaded:
    return

  if(not self.chatSectionModule.isLoaded()):
    return

  for cModule in self.communitySectionsModule.values:
    if(not cModule.isLoaded()):
      return

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

proc stickersDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

proc activityCenterDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method communitiesModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

proc walletSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method browserSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

proc profileSectionDidLoad*[T](self: Module[T]) =
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

method getActiveSectionId*[T](self: Module[T]): string =
  return self.controller.getActiveSectionId()

method setActiveSection*[T](self: Module[T], item: SectionItem) =
  if(item.isEmpty()):
    echo "section is empty and cannot be made as active one"
    return

  self.controller.setActiveSection(item.id, item.sectionType)

proc notifySubModulesAboutChange[T](self: Module[T], sectionId: string) =
  self.chatSectionModule.onActiveSectionChange(sectionId)

  for cModule in self.communitySectionsModule.values:
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
  elif (sectionType == SectionType.Community):
    let enabled = singletonInstance.localAccountSensitiveSettings.getCommunitiesEnabled()
    self.setSectionAvailability(sectionType, not enabled)
    singletonInstance.localAccountSensitiveSettings.setCommunitiesEnabled(not enabled)
  elif (sectionType == SectionType.NodeManagement):
    let enabled = singletonInstance.localAccountSensitiveSettings.getNodeManagementEnabled()
    self.setSectionAvailability(sectionType, not enabled)
    singletonInstance.localAccountSensitiveSettings.setNodeManagementEnabled(not enabled)

method setUserStatus*[T](self: Module[T], status: bool) =
  self.controller.setUserStatus(status)

method getChatSectionModule*[T](self: Module[T]): QVariant =
  return self.chatSectionModule.getModuleAsVariant()

method getCommunitySectionModule*[T](self: Module[T], communityId: string): QVariant =
  if(not self.communitySectionsModule.contains(communityId)):
    echo "main-module, unexisting community key: ", communityId
    return

  return self.communitySectionsModule[communityId].getModuleAsVariant()

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

  var items = transform(self.chatSectionModule.chatsModel().items(), conf.CHAT_SECTION_ID, conf.CHAT_SECTION_NAME)
  for cId in self.communitySectionsModule.keys:
    items.add(transform(self.communitySectionsModule[cId].chatsModel().items(), cId, self.view.model().getItemById(cId).name()))

  self.view.chatSearchModel().setItems(items)

method switchTo*[T](self: Module[T], sectionId, chatId: string) =
  self.controller.switchTo(sectionId, chatId)

method onActiveChatChange*[T](self: Module[T], sectionId: string, chatId: string) =
  self.appSearchModule.onActiveChatChange(sectionId, chatId)

method onNotificationsUpdated[T](self: Module[T], sectionId: string, sectionHasUnreadMessages: bool,
  sectionNotificationCount: int) =
  self.view.model().udpateNotifications(sectionId, sectionHasUnreadMessages, sectionNotificationCount)

method getAppSearchModule*[T](self: Module[T]): QVariant =
  self.appSearchModule.getModuleAsVariant()

method communityJoined*[T](
  self: Module[T],
  community: CommunityDto,
  events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service
) =
  var firstCommunityJoined = false
  if (self.communitySectionsModule.len == 0):
    firstCommunityJoined = true
  self.communitySectionsModule[community.id] = chat_section_module.newModule(
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
  self.communitySectionsModule[community.id].load(events, settingsService, contactsService, chatService, communityService, messageService, gifService, mailserversService)

  let communitySectionItem = self.createCommunityItem(community)
  if (firstCommunityJoined):
    # If there are no other communities, add the first community after the Chat section in the model so that the order is respected
    self.view.model().addItem(communitySectionItem, self.view.model().getItemIndex(conf.CHAT_SECTION_ID) + 1)
  else:
    self.view.model().addItem(communitySectionItem)
  self.setActiveSection(communitySectionItem)

method communityLeft*[T](self: Module[T], communityId: string) =
  if(not self.communitySectionsModule.contains(communityId)):
    echo "main-module, unexisting community key to leave: ", communityId
    return

  self.communitySectionsModule.del(communityId)

  self.view.model().removeItem(communityId)

  if (self.controller.getActiveSectionId() == communityId):
    let item = self.view.model().getItemById(conf.CHAT_SECTION_ID)
    self.setActiveSection(item)

method communityEdited*[T](
    self: Module[T],
    community: CommunityDto) =
  self.view.editItem(self.createCommunityItem(community))

method getContactDetailsAsJson*[T](self: Module[T], publicKey: string): string =
  let contact =  self.controller.getContact(publicKey)
  let (name, image, isIdenticon) = self.controller.getContactNameAndImage(contact.id)
  let jsonObj = %* {
    "displayName": name,
    "displayIcon": image,
    "isDisplayIconIdenticon": isIdenticon,
    "publicKey": contact.id,
    "name": contact.name,
    "ensVerified": contact.ensVerified,
    "alias": contact.alias,
    "lastUpdated": contact.lastUpdated,
    "lastUpdatedLocally": contact.lastUpdatedLocally,
    "localNickname": contact.localNickname,
    "identicon": contact.identicon,
    "thumbnailImage": contact.image.large,
    "largeImage": contact.image.thumbnail,
    "isContact":contact.added,
    "isBlocked":contact.blocked,
    "requestReceived":contact.hasAddedUs,
    "isSyncing":contact.isSyncing,
    "removed":contact.removed
  }
  return $jsonObj

method resolveENS*[T](self: Module[T], ensName: string, uuid: string) =
  if ensName.len == 0:
    error "error: cannot do a lookup for empty ens name"
    return
  self.controller.resolveENS(ensName, uuid)

method resolvedENS*[T](self: Module[T], publicKey: string, address: string, uuid: string) =
  self.view.emitResolvedENSSignal(publicKey, address, uuid)

method contactUpdated*[T](self: Module[T], publicKey: string) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.activeSection().updateMember(
    publicKey,
    contactDetails.displayName,
    contactDetails.details.name,
    contactDetails.details.localNickname,
    contactDetails.details.alias,
    contactDetails.icon,
    contactDetails.isidenticon,
    )

method calculateProfileSectionHasNotification*[T](self: Module[T]): bool =
  return not self.controller.isMnemonicBackedUp()

method mnemonicBackedUp*[T](self: Module[T]) =
  self.view.model().udpateNotifications(
    conf.SETTINGS_SECTION_ID,
    self.calculateProfileSectionHasNotification(),
    notificationsCount = 0)
