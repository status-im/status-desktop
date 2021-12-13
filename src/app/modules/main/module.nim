import NimQml, Tables

import io_interface, view, controller, item, model
import ../../global/app_sections_config as conf
import ../../global/global_singleton

import chat_section/module as chat_section_module
import wallet_section/module as wallet_section_module
import browser_section/module as browser_section_module
import profile_section/module as profile_section_module
import app_search/module as app_search_module
import stickers/module as stickers_module
import activity_center/module as activity_center_module

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
import ../../../app_service/service/language/service as language_service
import ../../../app_service/service/mnemonic/service as mnemonic_service
import ../../../app_service/service/privacy/service as privacy_service
import ../../../app_service/service/stickers/service as stickers_service
import ../../../app_service/service/activity_center/service as activity_center_service

import eventemitter

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
    appSearchModule: app_search_module.AccessInterface
    moduleLoaded: bool

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
  aboutService: about_service.ServiceInterface,
  dappPermissionsService: dapp_permissions_service.ServiceInterface,
  languageService: language_service.ServiceInterface,
  mnemonicService: mnemonic_service.ServiceInterface,
  privacyService: privacy_service.ServiceInterface,
  providerService: provider_service.ServiceInterface,
  stickersService: stickers_service.Service,
  activityCenterService: activity_center_service.Service
  ): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, keychainService, accountsService, 
  chatService, communityService)
  result.moduleLoaded = false

  # Submodules
  result.chatSectionModule = chat_section_module.newModule(result, events, conf.CHAT_SECTION_ID, false, contactsService, 
  chatService, communityService, messageService)
  result.communitySectionsModule = initOrderedTable[string, chat_section_module.AccessInterface]()
  result.walletSectionModule = wallet_section_module.newModule[Module[T]](result, events, tokenService, 
    transactionService, collectible_service, walletAccountService, settingsService)
  result.browserSectionModule = browser_section_module.newModule(result, bookmarkService, settingsService, 
  dappPermissionsService, providerService)
  result.profileSectionModule = profile_section_module.newModule(result, events, accountsService, settingsService, 
  profileService, contactsService, aboutService, languageService, mnemonicService, privacyService)
  result.stickersModule = stickers_module.newModule(result, events, stickersService)
  result.activityCenterModule = activity_center_module.newModule(result, events, activityCenterService, contactsService)
  result.appSearchModule = app_search_module.newModule(result, events, contactsService, chatService, communityService, 
  messageService)

method delete*[T](self: Module[T]) =
  self.chatSectionModule.delete
  self.profileSectionModule.delete
  self.stickersModule.delete
  self.activityCenterModule.delete
  for cModule in self.communitySectionsModule.values:
    cModule.delete
  self.communitySectionsModule.clear
  self.walletSectionModule.delete
  self.browserSectionModule.delete
  self.appSearchModule.delete
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](
    self: Module[T],
    events: EventEmitter,
    contactsService: contacts_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service
  ) =
  singletonInstance.engine.setRootContextProperty("mainModule", self.viewVariant)
  self.controller.init()
  self.view.load()

  # Create community modules here, since we don't know earlier how many communities we have.
  let communities = self.controller.getCommunities()

  for c in communities:
    self.communitySectionsModule[c.id] = chat_section_module.newModule(
      self,
      events,
      c.id,
      true,
      contactsService,
      chatService, 
      communityService,
      messageService
    )

  var activeSection: Item
  var activeSectionId = singletonInstance.localAccountSensitiveSettings.getActiveSection()

  # Chat Section
  let (unviewedCount, mentionsCount) = self.controller.getNumOfNotificaitonsForChat()
  let hasNotification = unviewedCount > 0 or mentionsCount > 0
  let notificationsCount = mentionsCount
  let chatSectionItem = initItem(conf.CHAT_SECTION_ID, SectionType.Chat, conf.CHAT_SECTION_NAME, "", 
  conf.CHAT_SECTION_ICON, "", hasNotification, notificationsCount, 
  false, true)
  self.view.addItem(chatSectionItem)
  if(activeSectionId == chatSectionItem.id):
    activeSection = chatSectionItem

  # Community Section
  for c in communities:
    let (unviewedCount, mentionsCount) = self.controller.getNumOfNotificaitonsForCommunity(c.id)
    let hasNotification = unviewedCount > 0 or mentionsCount > 0
    let notificationsCount = mentionsCount # we need to add here number of requests
    let communitySectionItem = initItem(c.id, SectionType.Community, c.name, c.images.thumbnail, "", c.color, 
    hasNotification, notificationsCount, false, singletonInstance.localAccountSensitiveSettings.getCommunitiesEnabled())
    self.view.addItem(communitySectionItem)
    if(activeSectionId == communitySectionItem.id):
      activeSection = communitySectionItem

  # Wallet Section
  let walletSectionItem = initItem(conf.WALLET_SECTION_ID, SectionType.Wallet, conf.WALLET_SECTION_NAME, "", 
  conf.WALLET_SECTION_ICON, "", false, 0, false,
  singletonInstance.localAccountSensitiveSettings.getIsWalletEnabled())
  self.view.addItem(walletSectionItem)
  if(activeSectionId == walletSectionItem.id):
    activeSection = walletSectionItem

  # WalletV2 Section
  let walletV2SectionItem = initItem(conf.WALLETV2_SECTION_ID, SectionType.WalletV2, conf.WALLETV2_SECTION_NAME, "", 
  conf.WALLETV2_SECTION_ICON, "", false, 0, false, 
  singletonInstance.localAccountSensitiveSettings.getIsWalletV2Enabled())
  self.view.addItem(walletV2SectionItem)
  if(activeSectionId == walletV2SectionItem.id):
    activeSection = walletV2SectionItem

  # Browser Section
  let browserSectionItem = initItem(conf.BROWSER_SECTION_ID, SectionType.Browser, conf.BROWSER_SECTION_NAME, "", 
  conf.BROWSER_SECTION_ICON, "", false, 0, false,
  singletonInstance.localAccountSensitiveSettings.getIsBrowserEnabled())
  self.view.addItem(browserSectionItem)
  if(activeSectionId == browserSectionItem.id):
    activeSection = browserSectionItem

  # Node Management Section
  let nodeManagementSectionItem = initItem(conf.NODEMANAGEMENT_SECTION_ID, SectionType.NodeManagement, 
  conf.NODEMANAGEMENT_SECTION_NAME, "", conf.NODEMANAGEMENT_SECTION_ICON, "", false, 0, false, 
  singletonInstance.localAccountSensitiveSettings.getNodeManagementEnabled())
  self.view.addItem(nodeManagementSectionItem)
  if(activeSectionId == nodeManagementSectionItem.id):
    activeSection = nodeManagementSectionItem

  # Profile Section
  let profileSettingsSectionItem = initItem(conf.SETTINGS_SECTION_ID, SectionType.ProfileSettings, 
  conf.SETTINGS_SECTION_NAME, "", conf.SETTINGS_SECTION_ICON, "", false, 0, false, true)
  self.view.addItem(profileSettingsSectionItem)
  if(activeSectionId == profileSettingsSectionItem.id):
    activeSection = profileSettingsSectionItem

  # Load all sections
  self.chatSectionModule.load(events, contactsService, chatService, communityService, messageService)
  for cModule in self.communitySectionsModule.values:
    cModule.load(events, contactsService, chatService, communityService, messageService)
  self.walletSectionModule.load()
  # self.walletV2SectionModule.load()
  self.browserSectionModule.load()
  # self.timelineSectionModule.load()
  # self.nodeManagementSectionModule.load()
  self.profileSectionModule.load()
  self.stickersModule.load()
  self.activityCenterModule.load()
  self.appSearchModule.load()

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

  if(not self.profileSectionModule.isLoaded()):
    return

  if(not self.stickersModule.isLoaded()):
    return

  if(not self.activityCenterModule.isLoaded()):
    return

  if(not self.appSearchModule.isLoaded()):
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

proc walletSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method browserSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

proc profileSectionDidLoad*[T](self: Module[T]) =
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

method setActiveSection*[T](self: Module[T], item: Item) =
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

method enableSection*[T](self: Module[T], sectionType: SectionType) =
  self.view.model().enableSection(sectionType)

method disableSection*[T](self: Module[T], sectionType: SectionType) =
  self.view.disableSection(sectionType)

method setUserStatus*[T](self: Module[T], status: bool) =
  self.controller.setUserStatus(status)

method getChatSectionModule*[T](self: Module[T]): QVariant =
  return self.chatSectionModule.getModuleAsVariant()

method getCommunitySectionModule*[T](self: Module[T], communityId: string): QVariant =
  if(not self.communitySectionsModule.contains(communityId)):
    echo "main-module, unexisting community key: ", communityId
    return

  return self.communitySectionsModule[communityId].getModuleAsVariant()

method onActiveChatChange*[T](self: Module[T], sectionId: string, chatId: string) =
  self.appSearchModule.onActiveChatChange(sectionId, chatId)

method getAppSearchModule*[T](self: Module[T]): QVariant =
  self.appSearchModule.getModuleAsVariant()