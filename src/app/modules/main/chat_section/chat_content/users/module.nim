import NimQml
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../../../global/global_singleton

import ../../../../../../app_service/service/chat/service_interface as chat_service
import ../../../../../../app_service/service/community/service_interface as community_service

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, chatId: string, belongsToCommunity: bool, 
  chatService: chat_service.ServiceInterface, communityService: community_service.ServiceInterface): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, chatId, belongsToCommunity, communityService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("usersModule", self.viewVariant)
  
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.usersDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant