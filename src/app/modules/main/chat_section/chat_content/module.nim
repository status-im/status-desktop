import NimQml, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller, item, model
import ../../../../core/global_singleton

import input_area/module as input_area_module
import messages/module as messages_module
import users/module as users_module

import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/message/service as message_service

import eventemitter

export io_interface

logScope:
  topics = "chat-section-module"

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    inputAreaModule: input_area_module.AccessInterface
    messagesModule: messages_module.AccessInterface
    usersModule: users_module.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, chatId: string, belongsToCommunity: bool, 
  chatService: chat_service.Service, communityService: community_service.Service, 
  messageService: message_service.Service): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, chatId, belongsToCommunity, chatService, communityService, 
  messageService)
  result.moduleLoaded = false

  result.inputAreaModule = input_area_module.newModule(result, chatId, belongsToCommunity, chatService, communityService)
  result.messagesModule = messages_module.newModule(result, events, chatId, belongsToCommunity, chatService, 
  communityService, messageService)
  result.usersModule = users_module.newModule(result, chatId, belongsToCommunity, chatService, communityService)

method delete*(self: Module) =
  self.inputAreaModule.delete
  self.messagesModule.delete
  self.usersModule.delete
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()
 
  self.inputAreaModule.load()
  self.messagesModule.load()
  self.usersModule.load()

proc checkIfModuleDidLoad(self: Module) =
  if self.moduleLoaded:
    return

  if(not self.inputAreaModule.isLoaded()):
    return

  if (not self.messagesModule.isLoaded()):
    return

  if (not self.usersModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.chatContentDidLoad()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method inputAreaDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method messagesDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method usersDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getInputAreaModule*(self: Module): QVariant =
  return self.inputAreaModule.getModuleAsVariant()

method getMessagesModule*(self: Module): QVariant =
  return self.messagesModule.getModuleAsVariant()

method getUsersModule*(self: Module): QVariant =
  return self.usersModule.getModuleAsVariant()