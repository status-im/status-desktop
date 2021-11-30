import NimQml

import ../../../../../app_service/service/contacts/service as contact_service
import ../../../../../app_service/service/chat/service_interface as chat_service
import ../../../../../app_service/service/community/service_interface as community_service
import ../../../../../app_service/service/message/service as message_service

import eventemitter

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface, events: EventEmitter, contactService: contact_service.Service, 
  chatService: chat_service.ServiceInterface, communityService: community_service.ServiceInterface, 
  messageService: message_service.Service) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method onActiveSectionChange*(self: AccessInterface, sectionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")