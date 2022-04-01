import NimQml

import ../../../app_service/service/settings/service as settings_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/message/service as message_service
import ../../../app_service/service/gif/service as gif_service
import ../../../app_service/service/mailservers/service as mailservers_service

import ../../core/eventemitter
import ../../core/notifications/details
import ../shared_models/section_item
import chat_search_item

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(
  self: AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method checkForStoringPassword*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method calculateProfileSectionHasNotification*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method appSearchDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method stickersDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activityCenterDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method profileSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method walletSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method browserSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method networksModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method nodeSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method chatSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communitySectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onActiveChatChange*(self: AccessInterface, sectionId: string, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNotificationsUpdated*(self: AccessInterface, sectionId: string, sectionHasUnreadMessages: bool,
  sectionNotificationCount: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getActiveSectionId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method communitiesModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method offerToStorePassword*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitStoringPasswordError*(self: AccessInterface, errorDescription: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitStoringPasswordSuccess*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitMailserverNotWorking*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activeSectionSet*(self: AccessInterface, sectionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleSection*(self: AccessInterface, sectionType: SectionType) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityJoined*(self: AccessInterface, community: CommunityDto, events: EventEmitter,
  settingsService: settings_service.Service,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service,
  setActive: bool = false,) {.base.} =
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

method meMentionedCountChanged*(self: AccessInterface, allMentions: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNetworkConnected*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNetworkDisconnected*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method storePassword*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveSection*(self: AccessInterface, item: SectionItem) {.base.} =
  raise newException(ValueError, "No implementation available")

method setUserStatus*(self: AccessInterface, status: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatSectionModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunitySectionModule*(self: AccessInterface, communityId: string): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getAppSearchModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactDetailsAsJson*(self: AccessInterface, publicKey: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method resolveENS*(self: AccessInterface, ensName: string, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method rebuildChatSearchModel*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchTo*(self: AccessInterface, sectionId, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method isConnected*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")




# This way (using concepts) is used only for the modules managed by AppController
type
  DelegateInterface* = concept c
    c.mainDidLoad()
