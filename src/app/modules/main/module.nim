import NimQml, Tables

import io_interface, view, controller, item
import ../../../app/boot/global_singleton

import chat_section/module as chat_section_module
import community_section/module as community_section_module
import profile_section/module as profile_section_module

import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/profile/service as profile_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/settings/service as settings_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/about/service as about_service

export io_interface

type 
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    chatSectionModule: chat_section_module.AccessInterface
    communitySectionsModule: OrderedTable[string, community_section_module.AccessInterface]
    profileSectionModule: profile_section_module.AccessInterface

proc newModule*[T](delegate: T, communityService: community_service.Service, accountsService: accounts_service.Service, settingsService: settings_service.ServiceInterface, profileService: profile_service.ServiceInterface, contactsService: contacts_service.ServiceInterface, aboutService: about_service.ServiceInterface): 
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, communityService)

  singletonInstance.engine.setRootContextProperty("mainModule", result.viewVariant)

  # Submodules
  result.chatSectionModule = chat_section_module.newModule(result)
  result.communitySectionsModule = initOrderedTable[string, community_section_module.AccessInterface]()
  let communities = result.controller.getCommunities()
  for c in communities:
    result.communitySectionsModule[c.id] = community_section_module.newModule(result, 
    c.id, communityService)
  result.profileSectionModule = profile_section_module.newModule(result, accountsService, settingsService, profileService, contactsService, aboutService)

method delete*[T](self: Module[T]) =
  self.chatSectionModule.delete
  self.profileSectionModule.delete
  for cModule in self.communitySectionsModule.values:
    cModule.delete
  self.communitySectionsModule.clear
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  echo "=> load"
  self.view.load()

  echo "=> chatSection"
  let chatSectionItem = initItem("chat", "Chat", "", "chat", "", 0, 0)
  self.view.addItem(chatSectionItem)

  echo "=> communitiesSection"
  let communities = self.controller.getCommunities()
  for c in communities:
    self.view.addItem(initItem(c.id, c.name, 
    if not c.images.isNil: c.images.thumbnail else: "",
    "", c.color, 0, 0))

  echo "=> chatSection"
  self.chatSectionModule.load()
  for cModule in self.communitySectionsModule.values:
    cModule.load()

  echo "=> profileSection"
  self.profileSectionModule.load()
  echo "------------"
  echo "------------"
  echo "------------"
  echo "------------"
  echo "------------"
  echo "------------"

proc checkIfModuleDidLoad [T](self: Module[T]) =
  if(not self.chatSectionModule.isLoaded()):
    return

  for cModule in self.communitySectionsModule.values:
    if(not cModule.isLoaded()):
      return

  if(not self.profileSectionModule.isLoaded()):
    return

  self.delegate.mainDidLoad()

method chatSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method communitySectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

proc profileSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method viewDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()