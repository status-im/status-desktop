import NimQml

import ../../../../app_service/service/message/dto/message

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

method onActiveChatChange*(self: AccessInterface, sectionId: string, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSearchMessagesDone*(self: AccessInterface, messages: seq[MessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method prepareLocationMenuModel*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setSearchLocation*(self: AccessInterface, location: string, subLocation: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSearchLocationObject*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method searchMessages*(self: AccessInterface, searchTerm: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method resultItemClicked*(self: AccessInterface, itemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateSearchLocationIfPointToChatWithId*(self: AccessInterface, chatId: string) {.base.} =
    raise newException(ValueError, "No implementation available")
