import ../../../../../../app_service/service/contacts/service as contacts_service
import ../../../../../../app_service/service/chat/service as chat_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getMembersPublicKeys*(self: AccessInterface): seq[string] {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactNameAndImage*(self: AccessInterface, contactId: string):
  tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method getStatusForContact*(self: AccessInterface, contactId: string): StatusUpdateDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getChat*(self: AccessInterface): ChatDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatMemberInfo*(self: AccessInterface, id: string): (bool, bool) =
  raise newException(ValueError, "No implementation available")
