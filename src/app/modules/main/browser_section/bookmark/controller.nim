import Tables
import result
import io_interface

import ../../../../../app_service/service/bookmarks/service as bookmark_service
import ../../../../core/eventemitter

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    bookmarkService: bookmark_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  bookmarkService: bookmark_service.Service):
  Controller =
  result = Controller()
  result.events = events
  result.delegate = delegate
  result.bookmarkService = bookmarkService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_BOOKMARK_REMOVED) do(e: Args):
    let args = BookmarkRemovedArgs(e)
    self.delegate.onBookmarkDeleted(args.url)

  self.events.on(SIGNAL_BOOKMARK_ADDED) do(e: Args):
    let args = BookmarkArgs(e)
    self.delegate.onBoomarkStored(args.bookmark.url, args.bookmark.name, args.bookmark.imageUrl)

  self.events.on(SIGNAL_BOOKMARK_UPDATED) do(e: Args):
    let args = BookmarkArgs(e)
    self.delegate.onBookmarkUpdated(args.bookmark.url, args.bookmark.url, args.bookmark.name, args.bookmark.imageUrl)

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
