import ../../../../../app_service/service/bookmarks/service as bookmark_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getBookmarks*(self: AccessInterface): seq[bookmark_service.BookmarkDto] =
  raise newException(ValueError, "No implementation available")

method storeBookmark*(self: AccessInterface, url, name: string) =
  raise newException(ValueError, "No implementation available")

method deleteBookmark*(self: AccessInterface, url: string) =
  raise newException(ValueError, "No implementation available")

method updateBookmark*(self: AccessInterface, oldUrl, newUrl, newName: string) =
  raise newException(ValueError, "No implementation available")
