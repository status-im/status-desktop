
import ../../app_service/service/contacts/service as contact_service
import ../../app_service/service/chat/service as chat_service
import ../../app_service/service/community/service as community_service
import ../modules/main/module as main_module

type 
  AppController* = ref object of DelegateInterface 
    # Services
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    # Modules
    mainModule: main_module.AccessInterface

proc newAppController*(): AppController =
  result = AppController()
  # Services
  result.contactService = contact_service.newService()
  result.chatService = chat_service.newService()
  result.communityService = community_service.newService()
  # Modules
  result.mainModule = main_module.newModule(result, result.communityService)

proc delete*(self: AppController) =
  self.mainModule.delete

method didLoad*(self: AppController) =
  discard

proc load*(self: AppController) =
  self.contactService.init()
  self.chatService.init()
  self.communityService.init()
  self.mainModule.load()