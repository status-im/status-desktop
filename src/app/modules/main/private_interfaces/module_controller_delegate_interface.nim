import ../../shared_models/section_item
import ../../../core/notifications/details

method offerToStorePassword*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitStoringPasswordError*(self: AccessInterface, errorDescription: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitStoringPasswordSuccess*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activeSectionSet*(self: AccessInterface, sectionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleSection*(self: AccessInterface, sectionType: SectionType) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityJoined*(self: AccessInterface, community: CommunityDto, events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityEdited*(self: AccessInterface, community: CommunityDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityLeft*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method resolvedENS*(self: AccessInterface, publicKey: string, address: string, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactUpdated*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method mnemonicBackedUp*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method osNotificationClicked*(self: AccessInterface, details: NotificationDetails) {.base.} =
  raise newException(ValueError, "No implementation available")

method newCommunityMembershipRequestReceived*(self: AccessInterface, membershipRequest: CommunityMembershipRequestDto) 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method onNetworkConnected*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNetworkDisconnected*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")