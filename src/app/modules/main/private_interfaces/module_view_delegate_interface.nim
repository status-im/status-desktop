import NimQml
import ../../shared_models/section_item
import ../chat_search_item

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method storePassword*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveSection*(self: AccessInterface, item: SectionItem) {.base.} =
  raise newException(ValueError, "No implementation available")

method setUserStatus*(self: AccessInterface, status: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatSectionModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunitySectionModule*(self: AccessInterface, communityId: string): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getAppSearchModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactDetailsAsJson*(self: AccessInterface, publicKey: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getEmojiHashAsJson*(self: AccessInterface, publicKey: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getColorHashAsJson*(self: AccessInterface, publicKey: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method resolveENS*(self: AccessInterface, ensName: string, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method rebuildChatSearchModel*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchTo*(self: AccessInterface, sectionId, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method isConnected*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")
