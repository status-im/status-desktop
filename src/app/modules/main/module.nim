import NimQml, Tables

import io_interface, view, controller, item
import ../../core/global_singleton

import chat_section/module as chat_section_module
import wallet_section/module as wallet_section_module
import browser_section/module as browser_section_module
import profile_section/module as profile_section_module

import ../../../app_service/service/keychain/service as keychain_service
# import ../../../app_service/service/accounts/service_interface as accounts_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/token/service as token_service
import ../../../app_service/service/transaction/service as transaction_service
import ../../../app_service/service/collectible/service as collectible_service
import ../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../app_service/service/setting/service as setting_service
import ../../../app_service/service/bookmarks/service as bookmark_service
import ../../../app_service/service/dapp_permissions/service as dapp_permissions_service

import eventemitter
import ../../../app_service/service/profile/service as profile_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/settings/service as settings_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/about/service as about_service
import ../../../app_service/service/language/service as language_service
import ../../../app_service/service/mnemonic/service as mnemonic_service
import ../../../app_service/service/privacy/service as privacy_service

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
    moduleLoaded: bool

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.ServiceInterface,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  tokenService: token_service.Service,
  transactionService: transaction_service.Service,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service,
  bookmarkService: bookmark_service.ServiceInterface, 
  settingService: setting_service.Service,
  profileService: profile_service.ServiceInterface,
  settingsService: settings_service.ServiceInterface,
  contactsService: contacts_service.ServiceInterface,
  aboutService: about_service.ServiceInterface,
  dappPermissionsService: dapp_permissions_service.ServiceInterface,
  languageService: language_service.ServiceInterface,
  mnemonicService: mnemonic_service.ServiceInterface,
  privacyService: privacy_service.ServiceInterface
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, keychainService, 
  accountsService, communityService)
  result.moduleLoaded = false

  # Submodules
  result.chatSectionModule = chat_section_module.newModule(result, "chat", 
  false, chatService, communityService)
  result.communitySectionsModule = initOrderedTable[string, chat_section_module.AccessInterface]()
  let communities = result.controller.getCommunities()
  for c in communities:
    result.communitySectionsModule[c.id] = chat_section_module.newModule(
      result, c.id, true, chatService, communityService
    )

  result.walletSectionModule = wallet_section_module.newModule[Module[T]](
    result,
    events,
    tokenService,
    transactionService,
    collectible_service,
    walletAccountService,
    settingService
  )

  result.browserSectionModule = browser_section_module.newModule(result, bookmarkService, settingsService, dappPermissionsService)
  result.profileSectionModule = profile_section_module.newModule(result, events, accountsService, settingsService, profileService, contactsService, aboutService, languageService, mnemonicService, privacyService)

method delete*[T](self: Module[T]) =
  self.chatSectionModule.delete
  self.profileSectionModule.delete
  for cModule in self.communitySectionsModule.values:
    cModule.delete
  self.communitySectionsModule.clear
  self.walletSectionModule.delete
  self.browserSectionModule.delete
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("mainModule", self.viewVariant)
  self.controller.init()
  self.view.load()

  var activeSection: Item
  var activeSectionId = singletonInstance.localAccountSensitiveSettings.getActiveSection()

  # Chat Section
  let chatSectionItem = initItem("chat", SectionType.Chat, "Chat", "", "chat", "", false, 0, true)
  self.view.addItem(chatSectionItem)
  if(activeSectionId == chatSectionItem.id):
    activeSection = chatSectionItem

  # Community Section
  let communities = self.controller.getCommunities()
  for c in communities:
    let communitySectionItem = initItem(c.id, SectionType.Community, c.name, if not c.images.isNil: c.images.thumbnail else: "",
    "", c.color, false, 0, false, singletonInstance.localAccountSensitiveSettings.getCommunitiesEnabled())
    self.view.addItem(communitySectionItem)
    if(activeSectionId == communitySectionItem.id):
      activeSection = communitySectionItem

  # Wallet Section
  let walletSectionItem = initItem("wallet", SectionType.Wallet, "Wallet", "", "wallet", "", false, 0, false,
  singletonInstance.localAccountSensitiveSettings.getIsWalletEnabled())
  self.view.addItem(walletSectionItem)
  if(activeSectionId == walletSectionItem.id):
    activeSection = walletSectionItem

  # WalletV2 Section
  let walletV2SectionItem = initItem("walletV2", SectionType.WalletV2, "WalletV2", "", "cancel", "", false, 0, false, 
  singletonInstance.localAccountSensitiveSettings.getIsWalletV2Enabled())
  self.view.addItem(walletV2SectionItem)
  if(activeSectionId == walletV2SectionItem.id):
    activeSection = walletV2SectionItem

  # Browser Section
  let browserSectionItem = initItem("browser", SectionType.Browser, "Browser", "", "browser", "", false, 0, false,
  singletonInstance.localAccountSensitiveSettings.getIsBrowserEnabled())
  self.view.addItem(browserSectionItem)
  if(activeSectionId == browserSectionItem.id):
    activeSection = browserSectionItem

  # Timeline Section
  let timelineSectionItem = initItem("timeline", SectionType.Timeline, "Timeline", "", "status-update", "", false, 0, 
  false, singletonInstance.localAccountSensitiveSettings.getTimelineEnabled())
  self.view.addItem(timelineSectionItem)
  if(activeSectionId == timelineSectionItem.id):
    activeSection = timelineSectionItem

  # Node Management Section
  let nodeManagementSectionItem = initItem("nodeManagement", SectionType.NodeManagement, "Node Management", "", "node", 
  "", false, 0, false, singletonInstance.localAccountSensitiveSettings.getNodeManagementEnabled())
  self.view.addItem(nodeManagementSectionItem)
  if(activeSectionId == nodeManagementSectionItem.id):
    activeSection = nodeManagementSectionItem

  # Profile Section
  let profileSettingsSectionItem = initItem("profileSettings", SectionType.ProfileSettings, "Settings", "", 
  "status-update", "", false, 0, false, true)
  self.view.addItem(profileSettingsSectionItem)
  if(activeSectionId == profileSettingsSectionItem.id):
    activeSection = profileSettingsSectionItem

  # Load all sections
  self.chatSectionModule.load()
  for cModule in self.communitySectionsModule.values:
    cModule.load()
  self.walletSectionModule.load()
  # self.walletV2SectionModule.load()
  self.browserSectionModule.load()
  # self.timelineSectionModule.load()
  # self.nodeManagementSectionModule.load()
  self.profileSectionModule.load()

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

  self.moduleLoaded = true
  self.delegate.mainDidLoad()

method chatSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method communitySectionDidLoad*[T](self: Module[T]) =
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
    echo "section is empty and cannot be made an active one"
    return

  self.controller.setActiveSection(item.id, item.sectionType)

method activeSectionSet*[T](self: Module[T], sectionId: string) =
  self.view.activeSectionSet(sectionId)

method enableSection*[T](self: Module[T], sectionType: SectionType) =
  self.view.enableSection(sectionType)

method disableSection*[T](self: Module[T], sectionType: SectionType) =
  self.view.disableSection(sectionType)