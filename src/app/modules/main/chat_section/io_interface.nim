import NimQml

import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/node_configuration/service as node_configuration_service
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/gif/service as gif_service
import ../../../../app_service/service/mailservers/service as mailservers_service

import model as chats_model
import item as chat_item

import ../../../core/eventemitter
import ../../../core/unique_event_emitter

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface,
  channelGroup: ChannelGroupDto,
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactService: contact_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatsLoaded*(self: AccessInterface,
  channelGroup: ChannelGroupDto,
  events: UniqueUUIDEventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactService: contact_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service) {.base.} =
  raise newException(ValueError, "No implementation available rip")

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

method chatContentDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activeItemSet*(self: AccessInterface, itemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method makeChatWithIdActive*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addNewChat*(self: AccessInterface, chatDto: ChatDto, belongsToCommunity: bool, events: EventEmitter,
  settingsService: settings_service.Service, contactService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service,
  messageService: message_service.Service, gifService: gif_service.Service,
  mailserversService: mailservers_service.Service, setChatAsActive: bool = true, insertIntoModel: bool = true): Item {.base.} =
  raise newException(ValueError, "No implementation available")

method doesCatOrChatExist*(self: AccessInterface, chatId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method doesTopLevelChatExist*(self: AccessInterface, chatId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method addOrUpdateChat*(self: AccessInterface,
    chat: ChatDto,
    belongsToCommunity: bool,
    events: UniqueUUIDEventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service,
    setChatAsActive: bool = true,
    insertIntoModel: bool = true
  ): Item {.base.} =
  raise newException(ValueError, "No implementation available")

method onNewMessagesReceived*(self: AccessInterface, sectionIdMsgBelongsTo: string, chatIdMsgBelongsTo: string, 
  chatTypeMsgBelongsTo: ChatType, lastMessageTimestamp: int, unviewedMessagesCount: int, unviewedMentionsCount: int, message: MessageDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatUnmuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onMarkAllMessagesRead*(self: AccessInterface, chat: ChatDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityMuted*(self: AccessInterface, chatId: string, muted: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactAdded*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactRejected*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactBlocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactUnblocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactDetailsUpdated*(self: AccessInterface, contactId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityChannelDeletedOrChatLeft*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatRenamed*(self: AccessInterface, chatId: string, newName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onGroupChatDetailsUpdated*(self: AccessInterface, chatId: string, newName: string, newColor: string, newImageJson: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityChannelEdited*(self: AccessInterface, chat: ChatDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReorderChat*(self: AccessInterface, updatedChat: ChatDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReorderChats*(self: AccessInterface, updatedChats: seq[ChatDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReorderCategory*(self: AccessInterface, catId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityCategoryCreated*(self: AccessInterface, category: Category, chats: seq[ChatDto], communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityCategoryDeleted*(self: AccessInterface, category: Category, chats: seq[ChatDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityCategoryEdited*(self: AccessInterface, category: Category, chats: seq[ChatDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCategoryNameChanged*(self: AccessInterface, category: Category) {.base.} =
  raise newException(ValueError, "No implementation available")

method setLoadingHistoryMessagesInProgress*(self: AccessInterface, isLoading: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveItem*(self: AccessInterface, itemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatContentModule*(self: AccessInterface, chatId: string): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method isCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMySectionId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method switchToOrCreateOneToOneChat*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createOneToOneChat*(self: AccessInterface, communityID: string, chatId: string, ensName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveChat*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeCommunityChat*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getActiveChatId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method muteChat*(self: AccessInterface, chatId: string, interval: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method unmuteChat*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method muteCategory*(self: AccessInterface, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method unmuteCategory*(self: AccessInterface, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCategoryMuted*(self: AccessInterface, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCategoryUnmuted*(self: AccessInterface, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method markAllMessagesRead*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method clearChatHistory*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentFleet*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptContactRequest*(self: AccessInterface, publicKey: string, contactRequestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptAllContactRequests*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method dismissContactRequest*(self: AccessInterface, publicKey: string, contactRequestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method dismissAllContactRequests*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method blockContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addGroupMembers*(self: AccessInterface, chatId: string, pubKeys: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeMemberFromGroupChat*(self: AccessInterface, communityID: string, chatId: string, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeMembersFromGroupChat*(self: AccessInterface, communityID: string, chatId: string, pubKeys: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method renameGroupChat*(self: AccessInterface, chatId: string, newName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateGroupChatDetails*(self: AccessInterface, chatId: string, newGroupName: string, newGroupColor: string, newGroupImage: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method makeAdmin*(self: AccessInterface, communityID: string, chatId: string, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createGroupChat*(self: AccessInterface, communityID: string, groupName: string, pubKeys: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createGroupChat*(self: AccessInterface, groupName: string, pubKeys: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method joinGroupChatFromInvitation*(self: AccessInterface, groupName: string, chatId: string, adminPK: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method initListOfMyContacts*(self: AccessInterface, pubKeys: string) {.base.}  =
  raise newException(ValueError, "No implementation available")

method clearListOfMyContacts*(self: AccessInterface) {.base.}  =
  raise newException(ValueError, "No implementation available")

method acceptRequestToJoinCommunity*(self: AccessInterface, requestId: string, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestToJoinCommunity*(self: AccessInterface, requestId: string, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityChannel*(self: AccessInterface, name: string, description: string,
    emoji: string, color: string, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityChannel*(self: AccessInterface, channelId, name, description, emoji, color,
    categoryId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveCommunity*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeUserFromCommunity*(self: AccessInterface, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method banUserFromCommunity*(self: AccessInterface, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunity*(self: AccessInterface, name: string, description, introMessage, outroMessage: string,
                      access: int, color: string, tags: string, logoJsonData: string, bannerJsonData: string,
                      historyArchiveSupportEnabled: bool, pinMessageAllMembersEnabled: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method unbanUserFromCommunity*(self: AccessInterface, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method exportCommunity*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setCommunityMuted*(self: AccessInterface, muted: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method inviteUsersToCommunity*(self: AccessInterface, pubKeysJSON: string, inviteMessage: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityCategory*(self: AccessInterface, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityCategory*(self: AccessInterface, categoryId: string, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityCategory*(self: AccessInterface, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method prepareEditCategoryModel*(self: AccessInterface, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method reorderCommunityCategories*(self: AccessInterface, categoryId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method reorderCommunityChat*(self: AccessInterface, categoryId: string, chatId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method downloadMessages*(self: AccessInterface, chatId: string, filePath: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateLastMessageTimestamp*(self: AccessInterface, chatId: string, lastMessageTimestamp: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactsStatusUpdated*(self: AccessInterface, statusUpdates: seq[StatusUpdateDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchToChannel*(self: AccessInterface, channelName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method joinSpectatedCommunity*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method createOrEditCommunityTokenPermission*(self: AccessInterface, communityId: string, permissionId: string, permissionType: int, tokenCriteriaJson: string, isPrivate: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityTokenPermission*(self: AccessInterface, communityId: string, permissionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenPermissionCreated*(self: AccessInterface, communityId: string, tokenPermission: CommunityTokenPermissionDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenPermissionCreationFailed*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenPermissionUpdated*(self: AccessInterface, communityId: string, tokenPermission: CommunityTokenPermissionDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenPermissionUpdateFailed*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenPermissionDeleted*(self: AccessInterface, communityId: string, permissionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenPermissionDeletionFailed*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenMetadataAdded*(self: AccessInterface, communityId: string, tokenMetadata: CommunityTokensMetadataDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onWalletAccountTokensRebuilt*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKickedFromCommunity*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onJoinedCommunity*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onAcceptRequestToJoinFailedNoPermission*(self: AccessInterface, communityId: string, memberKey: string, requestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, pin: string, password: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestToJoinCommunity*(self: AccessInterface, communityId: string, ensName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onDeactivateChatLoader*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestToJoinCommunityWithAuthentication*(self: AccessInterface, communityId: string, ensName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onOwnedcollectiblesUpdated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
