import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface, chatService: chat_service.Service, communityService: community_service.Service,) 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method checkForStoringPassword*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")