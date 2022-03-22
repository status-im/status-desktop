import Tables
import result
import io_interface

import ../../../../../app_service/service/bookmarks/service as bookmark_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    bookmarkService: bookmark_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  bookmarkService: bookmark_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.bookmarkService = bookmarkService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getBookmarks*(self: Controller): seq[bookmark_service.BookmarkDto] =
  return self.bookmarkService.getBookmarks()

proc storeBookmark*(self: Controller, url, name: string) =
  let b = self.bookmarkService.storeBookmark(url, name)
  if b.isOk:
    self.delegate.onBoomarkStored(url, name, b.get().imageUrl)

proc deleteBookmark*(self: Controller, url: string) =
  if self.bookmarkService.deleteBookmark(url):
    self.delegate.onBookmarkDeleted(url)

proc updateBookmark*(self: Controller, oldUrl, newUrl, newName: string) =
  let b = self.bookmarkService.updateBookmark(oldUrl, newUrl, newName)
  if b.isOk:
    self.delegate.onBookmarkUpdated(oldUrl, newUrl, newName, b.get().imageUrl)
