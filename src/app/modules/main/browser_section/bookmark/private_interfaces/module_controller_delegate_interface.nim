method getBookmarks*(self: AccessInterface): seq[bookmark_service.BookmarkDto] =
  raise newException(ValueError, "No implementation available")

method storeBookmark*(self: AccessInterface, url, name: string) =
  raise newException(ValueError, "No implementation available")

method deleteBookmark*(self: AccessInterface, url: string) =
  raise newException(ValueError, "No implementation available")

method updateBookmark*(self: AccessInterface, oldUrl, newUrl, newName: string) =
  raise newException(ValueError, "No implementation available")

method onBoomarkStored*(self: AccessInterface, url: string, name: string, imageUrl: string) =
  raise newException(ValueError, "No implementation available")

method onBookmarkDeleted*(self: AccessInterface, url: string) =
  raise newException(ValueError, "No implementation available")

method onBookmarkUpdated*(self: AccessInterface, oldUrl: string, newUrl: string, newName: string, newImageUrl: string) =
  raise newException(ValueError, "No implementation available")
