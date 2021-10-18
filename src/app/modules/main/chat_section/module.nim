import NimQml
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../core/global_singleton

import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, id: string, 
  isCommunity: bool, chatService: chat_service.Service,
  communityService: community_service.Service): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, id, isCommunity, 
  communityService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  if(self.controller.isCommunity()):
    singletonInstance.engine.setRootContextProperty("communitySectionModule", 
    self.viewVariant)
  else:
    singletonInstance.engine.setRootContextProperty("chatSectionModule", 
    self.viewVariant)
  
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  if(self.controller.isCommunity()):
    self.delegate.communitySectionDidLoad()
  else:
    self.delegate.chatSectionDidLoad()