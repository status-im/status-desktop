import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/gif/service as gif_service
import ../../../../app_service/service/mailservers/service as mailservers_service

import ../../../core/eventemitter

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(
  self: AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service
  ) 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method checkForStoringPassword*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method calculateProfileSectionHasNotification*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")