import ../../../../../../app_service/service/contacts/dto/[contacts]
import ../../../../../../app_service/service/community/dto/[community]
import ../../../../../../app_service/service/chat/dto/[chat]

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

method addReaction*(self: AccessInterface, messageId: string, emojiId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeReaction*(self: AccessInterface, messageId: string, emojiId: int, reactionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method pinUnpinMessage*(self: AccessInterface, messageId: string, pin: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactById*(self: AccessInterface, contactId: string): ContactsDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactNameAndImage*(self: AccessInterface, contactId: string): 
  tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method getNumOfPinnedMessages*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")