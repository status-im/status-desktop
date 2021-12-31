import ../../../../../../../app_service/service/message/dto/[message]
import ../../../../../../../app_service/service/contacts/dto/[status_update]

method newMessagesLoaded*(self: AccessInterface, messages: seq[MessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available") 

method contactNicknameChanged*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactsStatusUpdated*(self: AccessInterface, statusUpdates: seq[StatusUpdateDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactUpdated*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method loggedInUserImageChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")