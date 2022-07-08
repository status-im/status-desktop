import NimQml

import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/gif/service as gif_service
import ../../../../app_service/service/mailservers/service as mailservers_service

import model as chats_model

import ../../../core/eventemitter

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface,
  channelGroup: ChannelGroupDto,
  events: EventEmitter,
  settingsService: settings_service.Service,
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

method chatContentDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activeItemSubItemSet*(self: AccessInterface, itemId: string, subItemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method makeChatWithIdActive*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addNewChat*(self: AccessInterface, chatDto: ChatDto, belongsToCommunity: bool, events: EventEmitter,
  settingsService: settings_service.Service, contactService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service,
  messageService: message_service.Service, gifService: gif_service.Service,
  mailserversService: mailservers_service.Service, setChatAsActive: bool = true) {.base.} =
  raise newException(ValueError, "No implementation available")

method doesCatOrChatExist*(self: AccessInterface, chatId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method doesTopLevelChatExist*(self: AccessInterface, chatId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method addChatIfDontExist*(self: AccessInterface,
    chat: ChatDto,
    belongsToCommunity: bool,
    events: EventEmitter,
    settingsService: settings_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service,
    setChatAsActive: bool = true) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNewMessagesReceived*(self: AccessInterface, sectionIdMsgBelongsTo: string, chatIdMsgBelongsTo: string, 
  chatTypeMsgBelongsTo: ChatType, unviewedMessagesCount: int, unviewedMentionsCount: int, message: MessageDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatUnmuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onMarkAllMessagesRead*(self: AccessInterface, chatId: string) {.base.} =
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

method onCommunityChannelEdited*(self: AccessInterface, chat: ChatDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReorderChatOrCategory*(self: AccessInterface, chatOrCatId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityCategoryCreated*(self: AccessInterface, category: Category, chats: seq[ChatDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityCategoryDeleted*(self: AccessInterface, category: Category) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityCategoryEdited*(self: AccessInterface, category: Category, chats: seq[ChatDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCategoryNameChanged*(self: AccessInterface, category: Category) {.base.} =
  raise newException(ValueError, "No implementation available")

method setLoadingHistoryMessagesInProgress*(self: AccessInterface, isLoading: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveItemSubItem*(self: AccessInterface, itemId: string, subItemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatContentModule*(self: AccessInterface, chatId: string): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method isCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMySectionId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method createPublicChat*(self: AccessInterface, chatId: string) {.base.} =
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

method muteChat*(self: AccessInterface, chatId: string) {.base.} =
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

method acceptContactRequest*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptAllContactRequests*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method dismissContactRequest*(self: AccessInterface, publicKey: string) {.base.} =
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

method acceptRequestToJoinCommunity*(self: AccessInterface, requestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestToJoinCommunity*(self: AccessInterface, requestId: string) {.base.} =
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

method exportCommunity*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setCommunityMuted*(self: AccessInterface, muted: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method inviteUsersToCommunity*(self: AccessInterface, pubKeysJSON: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityCategory*(self: AccessInterface, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityCategory*(self: AccessInterface, categoryId: string, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityCategory*(self: AccessInterface, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method prepareEditCategoryModel*(self: AccessInterface, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method reorderCommunityCategories*(self: AccessInterface, categoryId: string, position: int) =
  raise newException(ValueError, "No implementation available")

method reorderCommunityChat*(self: AccessInterface, categoryId: string, chatId: string, position: int): string =
  raise newException(ValueError, "No implementation available")

method onMeMentionedInEditedMessage*(self: AccessInterface, chatId: string, editedMessage : MessageDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method downloadMessages*(self: AccessInterface, chatId: string, filePath: string) =
  raise newException(ValueError, "No implementation available")
