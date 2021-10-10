import NimQml, Tables

import io_interface, view, controller
import ../../../app/boot/global_singleton

import chat_section/module as chat_section_module
import community_section/module as community_section_module

import ../../../app_service/service/community/service as community_service

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: io_interface.DelegateInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    chatSectionModule: chat_section_module.AccessInterface
    communitySectionsModule: OrderedTable[string, community_section_module.AccessInterface]

#################################################
# Forward declaration section

# Controller Delegate Interface


# Chat Section Module Delegate Interface
proc chatSectionDidLoad*(self: Module)

# Community Section Module Delegate Interface
proc communitySectionDidLoad*(self: Module, moduleName: string)

#################################################

proc newModule*(delegate: io_interface.DelegateInterface, communityService: community_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module](result, communityService)

  singletonInstance.engine.setRootContextProperty("mainModule", result.viewVariant)

  # Submodules
  result.chatSectionModule = chat_section_module.newModule[Module](result)
  result.communitySectionsModule = initOrderedTable[string, community_section_module.AccessInterface]()
  result.communitySectionsModule["SectionName"] = community_section_module.newModule[Module](result)
  
method delete*(self: Module) =
  self.chatSectionModule.delete
  for cModule in self.communitySectionsModule.values:
    cModule.delete
  self.communitySectionsModule.clear
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.view.load()
  self.chatSectionModule.load()
  for cName, cModule in self.communitySectionsModule:
    cModule.load()

proc checkIfModuleDidLoad(self: Module) =
  if(not self.chatSectionModule.isLoaded()):
    return

  for cModule in self.communitySectionsModule.values:
    if(not cModule.isLoaded()):
      return

  self.delegate.didLoad()

proc chatSectionDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

proc communitySectionDidLoad*(self: Module, moduleName: string) =
  self.checkIfModuleDidLoad()

method viewDidLoad*(self: Module) =
  discard