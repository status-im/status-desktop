import NimQml

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method setActiveItemSubItem*(self: AccessInterface, itemId: string, subItemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatContentModule*(self: AccessInterface, chatId: string): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method isCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method createPublicChat*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createOneToOneChat*(self: AccessInterface, chatId: string, ensName: string) {.base.} =
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

method rejectContactRequest*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method rejectAllContactRequests*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method blockContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")
  
method addGroupMembers*(self: AccessInterface, chatId: string, pubKeys: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeMemberFromGroupChat*(self: AccessInterface, chatId: string, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method renameGroupChat*(self: AccessInterface, chatId: string, newName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method makeAdmin*(self: AccessInterface, chatId: string, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createGroupChat*(self: AccessInterface, groupName: string, pubKeys: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method joinGroup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method joinGroupChatFromInvitation*(self: AccessInterface, groupName: string, chatId: string, adminPK: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method initListOfMyContacts*(self: AccessInterface) {.base.}  =
  raise newException(ValueError, "No implementation available")

method clearListOfMyContacts*(self: AccessInterface) {.base.}  =
  raise newException(ValueError, "No implementation available")


method acceptRequestToJoinCommunity*(self: AccessInterface, requestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestToJoinCommunity*(self: AccessInterface, requestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityChannel*(self: AccessInterface, name: string, description: string, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityChannel*(self: AccessInterface, channelId, name, description, categoryId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveCommunity*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunity*(self: AccessInterface, name: string, description: string, access: int, ensOnly: bool, color: string, imagePath: string, aX: int, aY: int, bX: int, bY: int) {.base.} =
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
