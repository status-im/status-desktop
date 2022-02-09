import Tables
import result
import controller_interface
import io_interface

import ../../../../../app_service/service/bookmarks/service as bookmark_service

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    bookmarkService: bookmark_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface,
  bookmarkService: bookmark_service.ServiceInterface):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.bookmarkService = bookmarkService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getBookmarks*(self: Controller): seq[bookmark_service.BookmarkDto] =
  return self.bookmarkService.getBookmarks()

method storeBookmark*(self: Controller, url, name: string) =
  let b = self.bookmarkService.storeBookmark(url, name)
  if b.isOk:
    self.delegate.onBoomarkStored(url, name, b.get().imageUrl)

method deleteBookmark*(self: Controller, url: string) =
  if self.bookmarkService.deleteBookmark(url):
    self.delegate.onBookmarkDeleted(url)

method updateBookmark*(self: Controller, oldUrl, newUrl, newName: string) =
  let b = self.bookmarkService.updateBookmark(oldUrl, newUrl, newName)
  if b.isOk:
    self.delegate.onBookmarkUpdated(oldUrl, newUrl, newName, b.get().imageUrl)
