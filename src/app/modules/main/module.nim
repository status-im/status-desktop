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
  SectionType* {.pure.} = enum
    Chat = 0
    Community,
    Wallet,
    Browser,
    Timeline,
    NodeManagement,
    ProfileSettings

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

  let chatSectionItem = initItem("chat", SectionType.Chat.int, "Chat", "", 
  "chat", "", 0, 0)
  self.view.addItem(chatSectionItem)

  echo "=> communitiesSection"
  let communities = self.controller.getCommunities()
  for c in communities:
    self.view.addItem(initItem(c.id, SectionType.Community.int, c.name, c.images.thumbnail, "", c.color, 0, 0))

  echo "=> chatSection"
  self.chatSectionModule.load()
  for cModule in self.communitySectionsModule.values:
    cModule.load()

  let walletSectionItem = initItem("wallet", SectionType.Wallet.int, "Wallet", "", 
  "wallet", "", 0, 0)
  self.view.addItem(chatSectionItem)
  self.walletSectionModule.load()

  self.browserSectionModule.load()
  
  let browserSectionItem = initItem("browser", SectionType.Browser.int, "Browser")
  self.view.addItem(browserSectionItem)

  self.profileSectionModule.load()

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