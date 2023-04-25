import ../../../../../app_service/service/bookmarks/service as bookmark_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onActivated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getBookmarks*(self: AccessInterface): seq[bookmark_service.BookmarkDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method storeBookmark*(self: AccessInterface, url, name: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteBookmark*(self: AccessInterface, url: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateBookmark*(self: AccessInterface, oldUrl, newUrl, newName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBoomarkStored*(self: AccessInterface, url: string, name: string, imageUrl: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBookmarkDeleted*(self: AccessInterface, url: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBookmarkUpdated*(self: AccessInterface, oldUrl: string, newUrl: string, newName: string, newImageUrl: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
