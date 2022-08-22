import NimQml

import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/message/dto/[message]
import ../../../../../../app_service/service/contacts/dto/[status_update]

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method onNewMessagesLoaded*(self: AccessInterface, messages: seq[MessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactNicknameChanged*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactsStatusUpdated*(self: AccessInterface, statusUpdates: seq[StatusUpdateDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactUpdated*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method loggedInUserImageChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method addChatMember*(self: AccessInterface, member: ChatMember) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMembersAddedOrRemoved*(self: AccessInterface, ids: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMembersAdded*(self: AccessInterface, ids: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMemberRemoved*(self: AccessInterface, ids: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatUpdated*(self: AccessInterface, chat: ChatDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMemberUpdated*(self: AccessInterface, id: string, admin: bool, joined: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMembersPublicKeys*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")
