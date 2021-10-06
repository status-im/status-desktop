import NimQml, Tables

import io_interface, view, controller, item
import ../../../app/boot/global_singleton

import chat_section/module as chat_section_module
import community_section/module as community_section_module

import ../../../app_service/service/community/service as community_service

export io_interface

type 
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    chatSectionModule: chat_section_module.AccessInterface
    communitySectionsModule: OrderedTable[string, community_section_module.AccessInterface]

#################################################
# Forward declaration section

# Controller Delegate Interface


# Chat Section Module Delegate Interface
proc chatSectionDidLoad*[T](self: Module[T])

# Community Section Module Delegate Interface
proc communitySectionDidLoad*[T](self: Module[T])

#################################################

proc newModule*[T](delegate: T, 
  communityService: community_service.Service): 
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, communityService)

  singletonInstance.engine.setRootContextProperty("mainModule", result.viewVariant)

  # Submodules
  result.chatSectionModule = chat_section_module.newModule[Module[T]](result)
  result.communitySectionsModule = initOrderedTable[string, community_section_module.AccessInterface]()
  let communities = result.controller.getCommunities()
  for c in communities:
    result.communitySectionsModule[c.id] = community_section_module.newModule[Module[T]](result, 
    c.id, communityService)
  
method delete*[T](self: Module[T]) =
  self.chatSectionModule.delete
  for cModule in self.communitySectionsModule.values:
    cModule.delete
  self.communitySectionsModule.clear
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  self.view.load()

  let chatSectionItem = initItem("chat", "Chat", "", "chat", "", 0, 0)
  self.view.addItem(chatSectionItem)
  
  let communities = self.controller.getCommunities()
  for c in communities:
    self.view.addItem(initItem(c.id, c.name, 
    if not c.images.isNil: c.images.thumbnail else: "",
    "", c.color, 0, 0))

  self.chatSectionModule.load()
  for cModule in self.communitySectionsModule.values:
    cModule.load()

proc checkIfModuleDidLoad [T](self: Module[T]) =
  if(not self.chatSectionModule.isLoaded()):
    return

  for cModule in self.communitySectionsModule.values:
    if(not cModule.isLoaded()):
      return

  self.delegate.mainDidLoad()

proc chatSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

proc communitySectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method viewDidLoad*[T](self: Module[T]) =
  discard