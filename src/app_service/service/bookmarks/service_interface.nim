import ./dto/bookmark as bookmark_dto

export bookmark_dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

import results

type R = Result[BookmarkDto, string]

method getBookmarks*(self: ServiceInterface): seq[BookmarkDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method storeBookmark*(self: ServiceInterface, url, name: string): R {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteBookmark*(self: ServiceInterface, url: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method updateBookmark*(self: ServiceInterface, oldUrl, newUrl, newName: string): R {.base.} =
  raise newException(ValueError, "No implementation available")
