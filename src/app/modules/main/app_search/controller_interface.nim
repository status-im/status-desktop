import ../../../../app_service/service/contacts/dto/contacts
import ../../../../app_service/service/chat/dto/chat
import ../../../../app_service/service/community/dto/community

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activeSectionId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method activeChatId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveSectionIdAndChatId*(self: AccessInterface, sectionId: string, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method searchTerm*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method searchLocation*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method searchSubLocation*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setSearchLocation*(self: AccessInterface, location: string, subLocation: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getJoinedCommunities*(self: AccessInterface): seq[CommunityDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunityById*(self: AccessInterface, communityId: string): CommunityDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllChatsForCommunity*(self: AccessInterface, communityId: string): seq[Chat] {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatDetailsForChatTypes*(self: AccessInterface, types: seq[ChatType]): seq[ChatDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatDetails*(self: AccessInterface, communityId, chatId: string): ChatDto {.base.} =
  raise newException(ValueError, "No implementation available")

method searchMessages*(self: AccessInterface, searchTerm: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getOneToOneChatNameAndImage*(self: AccessInterface, chatId: string): 
  tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactNameAndImage*(self: AccessInterface, contactId: string): 
  tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")