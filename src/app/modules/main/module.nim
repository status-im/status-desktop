import NimQml, Tables

import io_interface, view, controller, item
import ../../core/global_singleton

import chat_section/module as chat_section_module
import wallet_section/module as wallet_section_module

import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/accounts/service_interface as accounts_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/token/service as token_service
import ../../../app_service/service/transaction/service as transaction_service
import ../../../app_service/service/collectible/service as collectible_service
import ../../../app_service/service/wallet_account/service as wallet_account_service

import eventemitter

export io_interface

type
  ChatSectionType* {.pure.} = enum
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
  walletAccountService: wallet_account_service.Service
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, keychainService, 
  accountsService, communityService)

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
    walletAccountService
  )

  
method delete*[T](self: Module[T]) =
  self.chatSectionModule.delete
  for cModule in self.communitySectionsModule.values:
    cModule.delete
  self.communitySectionsModule.clear
  self.walletSectionModule.delete
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("mainModule", self.viewVariant)
  self.controller.init()
  self.view.load()

  let chatSectionItem = initItem("chat", ChatSectionType.Chat.int, "Chat", "", 
  "chat", "", 0, 0)
  self.view.addItem(chatSectionItem)
  
  let communities = self.controller.getCommunities()
  for c in communities:
    self.view.addItem(initItem(c.id, ChatSectionType.Community.int, c.name, 
    if not c.images.isNil: c.images.thumbnail else: "",
    "", c.color, 0, 0))

  self.chatSectionModule.load()
  for cModule in self.communitySectionsModule.values:
    cModule.load()

  let walletSectionItem = initItem("wallet", ChatSectionType.Wallet.int, "Wallet", "", 
  "wallet", "", 0, 0)
  self.view.addItem(chatSectionItem)
  self.walletSectionModule.load()



proc checkIfModuleDidLoad [T](self: Module[T]) =
  if(not self.chatSectionModule.isLoaded()):
    return

  for cModule in self.communitySectionsModule.values:
    if(not cModule.isLoaded()):
      return


  if (not self.walletSectionModule.isLoaded()):
    return

  self.delegate.mainDidLoad()

method chatSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method communitySectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

proc walletSectionDidLoad*[T](self: Module[T]) =
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