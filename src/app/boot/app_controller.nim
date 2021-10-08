
import ../../app_service/service/contacts/service as contact_service
import ../../app_service/service/chat/service as chat_service
import ../../app_service/service/community/service as community_service
import ../modules/main/module as main_module

type 
  AppController* = ref object of DelegateInterface 
    contactService: contact_service.ServiceInterface
    chatService: chat_service.ServiceInterface
    communityService: community_service.ServiceInterface
    mainModule: main_module.AccessInterface

proc newAppController*(): AppController =
  result = AppController()
  
  # Services
  result.contactService = contact_service.newService()
  result.chatService = chat_service.newService()
  result.communityService = community_service.newService()

  # Modules
  result.mainModule = main_module.newModule(result)

proc delete*(self: AppController) =
  echo "--(AppController)--delete"
  self.mainModule.delete

method didLoad*(self: AppController) =
  echo "--(AppController)--didLoad"

proc load*(self: AppController) =
  echo "--(AppController)--load"
  self.contactService.init()
  self.chatService.init()
  self.communityService.init()
  self.mainModule.load()