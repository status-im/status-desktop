import ../../../../app_service/service/contacts/dto/[contacts, contact_details]
import ../../../../app_service/service/chat/dto/[chat]
import ../../../../app_service/service/community/dto/[community]

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMySectionId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getActiveChatId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method isCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getJoinedCommunities*(self: AccessInterface): seq[CommunityDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getMyCommunity*(self: AccessInterface): CommunityDto {.base.}  =
  raise newException(ValueError, "No implementation available")

method getCategories*(self: AccessInterface, communityId: string): seq[Category] {.base.} =
  raise newException(ValueError, "No implementation available")

method getChats*(self: AccessInterface, communityId: string, categoryId: string): seq[Chat] {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatDetails*(self: AccessInterface, communityId, chatId: string): ChatDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatDetailsForChatTypes*(self: AccessInterface, types: seq[ChatType]): seq[ChatDto] {.base.} =
  raise newException(ValueError, "No implementation available")
    
method setActiveItemSubItem*(self: AccessInterface, itemId: string, subItemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")
    
method removeCommunityChat*(self: AccessInterface, itemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getOneToOneChatNameAndImage*(self: AccessInterface, chatId: string): 
  tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method createPublicChat*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createOneToOneChat*(self: AccessInterface, chatId: string, ensName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveChat*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method muteChat*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method unmuteChat*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method markAllMessagesRead*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method clearChatHistory*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentFleet*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getContacts*(self: AccessInterface): seq[ContactsDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getContact*(self: AccessInterface, id: string): ContactsDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactDetails*(self: AccessInterface, id: string): ContactDetails {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactNameAndImage*(self: AccessInterface, contactId: string): 
  tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method addContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method rejectContactRequest*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method blockContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")
  
method addGroupMembers*(self: AccessInterface, chatId: string, pubKeys: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeMemberFromGroupChat*(self: AccessInterface, chatId: string, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method renameGroupChat*(self: AccessInterface, chatId: string, newName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method makeAdmin*(self: AccessInterface, chatId: string, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createGroupChat*(self: AccessInterface, groupName: string, pubKeys: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method joinGroup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method joinGroupChatFromInvitation*(self: AccessInterface, groupName: string, chatId: string, adminPK: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptRequestToJoinCommunity*(self: AccessInterface, requestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestToJoinCommunity*(self: AccessInterface, requestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityChannel*(self: AccessInterface, name: string, description: string, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityChannel*(self: AccessInterface, channelId: string, name: string, description: string, categoryId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityCategory*(self: AccessInterface, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityCategory*(self: AccessInterface, categoryId: string, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityCategory*(self: AccessInterface, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveCommunity*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunity*(self: AccessInterface, name: string, description: string, access: int, ensOnly: bool, color: string, imageUrl: string, aX: int, aY: int, bX: int, bY: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method exportCommunity*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setCommunityMuted*(self: AccessInterface, muted: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method inviteUsersToCommunity*(self: AccessInterface, pubKeys: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method reorderCommunityCategories*(self: AccessInterface, categoryId: string, position: int) =
  raise newException(ValueError, "No implementation available")

method reorderCommunityChat*(self: AccessInterface, categoryId: string, chatId: string, position: int): string =
  raise newException(ValueError, "No implementation available")
