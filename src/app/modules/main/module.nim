import io_interface
import chat_section/module as chat_section_module
import view

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: io_interface.DelegateInterface
    view: View
    chatSectionModule: chat_section_module.AccessInterface

#################################################
# Forward declaration section

# Chat Section Module
proc didLoad*(self: Module)

#################################################

proc newModule*(delegate: io_interface.DelegateInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView()
  result.chatSectionModule = chat_section_module.newModule[Module](result)
  
method delete*(self: Module) =
  echo "--(MainModule)--delete"
  self.view.delete

method load*(self: Module) =
  echo "--(MainModule)--load"
  self.chatSectionModule.load()

proc didLoad*(self: Module) =
  echo "--(MainModule)--didLoad"
  self.delegate.didLoad()
