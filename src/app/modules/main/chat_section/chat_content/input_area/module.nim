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

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    chatId: string,
    belongsToCommunity: bool, 
    chatService: chat_service.ServiceInterface,
    communityService: community_service.ServiceInterface
    ): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, chatId, belongsToCommunity, chatService, communityService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.inputAreaDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getChatId*(self: Module): string =
  return self.controller.getChatId()

method sendImages*(self: Module, imagePathsJson: string): string =
  self.controller.sendImages(imagePathsJson)

method requestAddressForTransaction*(self: Module, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
  self.controller.requestAddressForTransaction(chatId, fromAddress, amount, tokenAddress)

method requestTransaction*(self: Module, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
  self.controller.requestTransaction(chatId, fromAddress, amount, tokenAddress)

method declineRequestTransaction*(self: Module, messageId: string) =
  self.controller.declineRequestTransaction(messageId)

method declineRequestAddressForTransaction*(self: Module, messageId: string) =
  self.controller.declineRequestAddressForTransaction(messageId)

method acceptRequestAddressForTransaction*(self: Module, messageId: string, address: string) =
  self.controller.acceptRequestAddressForTransaction(messageId, address)

method acceptRequestTransaction*(self: Module, transactionHash: string, messageId: string, signature: string) =
  self.controller.acceptRequestTransaction(transactionHash, messageId, signature)