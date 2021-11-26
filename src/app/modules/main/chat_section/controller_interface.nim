import ../../../../app_service/service/chat/service_interface as chat_service
import ../../../../app_service/service/community/service_interface as community_service

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

method getCommunityIds*(self: AccessInterface): seq[string] {.base.} =
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

method getOneToOneChatNameAndImage*(self: AccessInterface, chatId: string): 
  tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")