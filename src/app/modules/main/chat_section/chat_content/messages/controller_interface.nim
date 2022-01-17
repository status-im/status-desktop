import ../../../../../../app_service/service/contacts/dto/[contacts, contact_details]
import ../../../../../../app_service/service/community/dto/[community]
import ../../../../../../app_service/service/chat/dto/[chat]
import ../../../../../../app_service/service/message/dto/[message, reaction]

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMySectionId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getMyChatId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatDetails*(self: AccessInterface): ChatDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunityDetails*(self: AccessInterface): CommunityDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getOneToOneChatNameAndImage*(self: AccessInterface): tuple[name: string, image: string, isIdenticon: bool] 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method belongsToCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method loadMoreMessages*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
  
method addReaction*(self: AccessInterface, messageId: string, emojiId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeReaction*(self: AccessInterface, messageId: string, emojiId: int, reactionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method pinUnpinMessage*(self: AccessInterface, messageId: string, pin: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactById*(self: AccessInterface, contactId: string): ContactsDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactDetails*(self: AccessInterface, contactId: string): ContactDetails {.base.} =
  raise newException(ValueError, "No implementation available")

method getNumOfPinnedMessages*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getRenderedText*(self: AccessInterface, parsedTextArray: seq[ParsedText]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessageDetails*(self: AccessInterface, messageId: string): 
  tuple[message: MessageDto, reactions: seq[ReactionDto], error: string] {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")


method decodeContentHash*(self: AccessInterface, hash: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method editMessage*(self: AccessInterface, messageId: string, updatedMsg: string) {.base.} =
  raise newException(ValueError, "No implementation available")
