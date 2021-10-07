import Tables

import io_interface
import chat_section/module as chat_section_module
import community_section/module as community_section_module
import view

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: io_interface.DelegateInterface
    view: View
    chatSectionModule: chat_section_module.AccessInterface
    communitySectionsModule: OrderedTable[string, community_section_module.AccessInterface]

#################################################
# Forward declaration section

# Chat Section Module Delegate Interface
proc chatSectionDidLoad*(self: Module)

#################################################

#################################################
# Forward declaration section

# Community Section Module Delegate Interface
proc communitySectionDidLoad*(self: Module, moduleName: string)

#################################################

proc newModule*(delegate: io_interface.DelegateInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView()
  result.chatSectionModule = chat_section_module.newModule[Module](result)
  result.communitySectionsModule = initOrderedTable[string, community_section_module.AccessInterface]()
  result.communitySectionsModule["SectionName"] = community_section_module.newModule[Module](result)
  
method delete*(self: Module) =
  echo "--(MainModule)--delete"
  self.chatSectionModule.delete
  for cModule in self.communitySectionsModule.values:
    cModule.delete
  self.communitySectionsModule.clear
  self.view.delete

method load*(self: Module) =
  echo "--(MainModule)--load"
  self.chatSectionModule.load()
  for cName, cModule in self.communitySectionsModule:
    cModule.load()

proc checkIfModuleDidLoad(self: Module) =
  if(not self.chatSectionModule.isLoaded()):
    return

  for cModule in self.communitySectionsModule.values:
    if(not cModule.isLoaded()):
      return

  echo "--(MainModule)--didLoad"
  self.delegate.didLoad()

proc chatSectionDidLoad*(self: Module) =
  echo "--(MainModule)--chatSectionDidLoad"
  self.checkIfModuleDidLoad()

proc communitySectionDidLoad*(self: Module, moduleName: string) =
  echo "--(MainModule)--communitySectionDidLoad"
  self.checkIfModuleDidLoad()
