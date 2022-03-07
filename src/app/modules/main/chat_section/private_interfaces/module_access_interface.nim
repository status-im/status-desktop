import NimQml

import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/contacts/service as contact_service
import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/message/service as message_service
import ../../../../../app_service/service/gif/service as gif_service
import ../../../../../app_service/service/mailservers/service as mailservers_service

import ../model as chats_model

import ../../../../core/eventemitter

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface, events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  contactService: contact_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method onActiveSectionChange*(self: AccessInterface, sectionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method chatsModel*(self: AccessInterface): chats_model.Model {.base.} =
  raise newException(ValueError, "No implementation available")

method setFirstChannelAsActive*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
