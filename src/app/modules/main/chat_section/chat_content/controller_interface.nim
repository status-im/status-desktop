import ../../../../../app_service/service/message/dto/[message, reaction]

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method belongsToCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method unpinMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessageDetails*(self: AccessInterface, messageId: string): 
  tuple[message: MessageDto, reactions: seq[ReactionDto], error: string] {.base.} =
  raise newException(ValueError, "No implementation available")

method isUsersListAvailable*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")