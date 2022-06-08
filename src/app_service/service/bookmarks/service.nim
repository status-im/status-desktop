import Tables, json, sequtils, strformat, chronicles, strutils
import result
include ../../common/json_utils
import ./dto/bookmark as bookmark_dto
import ../../../app/core/eventemitter
import ../../../app/core/signals/types
import ../../../backend/backend
import ../../../backend/browser

export bookmark_dto

logScope:
  topics = "bookmarks-service"

const SIGNAL_BOOKMARK_ADDED* = "bookmarkAdded"
const SIGNAL_BOOKMARK_REMOVED* = "bookmarkRemoved"
const SIGNAL_BOOKMARK_UPDATED* = "bookmarkUpdated"

type
  Service* = ref object of RootObj
    bookmarks: Table[string, BookmarkDto] # [url, BookmarkDto]
    events: EventEmitter

type R = Result[BookmarkDto, string]

type
  BookmarkArgs* = ref object of Args
    bookmark*: BookmarkDto

type
  BookmarkRemovedArgs* = ref object of Args
    url*: string

proc delete*(self: Service) =
  discard

proc newService*(events: EventEmitter): Service =
  result = Service()
  result.events = events
  result.bookmarks = initTable[string, BookmarkDto]()

proc init*(self: Service) =
  try:
    let response = backend.getBookmarks()
    for bookmark in response.result.getElems().mapIt(it.toBookmarkDto()):
      if not bookmark.removed:
        self.bookmarks[bookmark.url] = bookmark

  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

  self.events.on(SignalType.Message.event) do(e: Args):
    var receivedData = MessageSignal(e)
    if receivedData.bookmarks.len > 0:
      for bookmark in receivedData.bookmarks:
        let url = bookmark.url
        if bookmark.removed and not self.bookmarks.hasKey(url):
          return

        if self.bookmarks.hasKey(url) and bookmark.removed:
          self.bookmarks.del(url)
          self.events.emit(SIGNAL_BOOKMARK_REMOVED, BookmarkRemovedArgs(url: url))
          return

        let emitUpdateEvent = self.bookmarks.hasKey(url)

        self.bookmarks[url] = BookmarkDto()
        self.bookmarks[url].url = bookmark.url
        self.bookmarks[url].name = bookmark.name
        self.bookmarks[url].imageUrl = bookmark.imageUrl
        self.bookmarks[url].removed = bookmark.removed

        if emitUpdateEvent:
          self.events.emit(SIGNAL_BOOKMARK_UPDATED, BookmarkArgs(bookmark: self.bookmarks[url]))
          return

        self.events.emit(SIGNAL_BOOKMARK_ADDED, BookmarkArgs(bookmark: self.bookmarks[url]))

proc getBookmarks*(self: Service): seq[BookmarkDto] =
  return toSeq(self.bookmarks.values)

proc storeBookmark*(self: Service, url, name: string): R =
  try:
    if not url.isEmptyOrWhitespace:
      let response = browser.addBookmark(backend.Bookmark(name: name, url: url)).result
      self.bookmarks[url] = BookmarkDto()
      self.bookmarks[url].url = url
      self.bookmarks[url].name = name
      discard response.getProp("imageUrl", self.bookmarks[url].imageUrl)
      discard response.getProp("removed", self.bookmarks[url].removed)
      discard response.getProp("deletedAt", self.bookmarks[url].deletedAt)
      result.ok self.bookmarks[url]
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    result.err errDescription

proc deleteBookmark*(self: Service, url: string): bool =
  try:
    if not self.bookmarks.hasKey(url):
      return
    discard browser.removeBookmark(url).result
    self.bookmarks.del(url)
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    return
  return true

proc updateBookmark*(self: Service, oldUrl, newUrl, newName: string): R =
  try:
    if not self.bookmarks.hasKey(oldUrl):
      return

    let response = browser.updateBookmark(oldUrl, backend.Bookmark(name: newName, url: newUrl)).result
    self.bookmarks.del(oldUrl)
    self.bookmarks[newUrl] = BookmarkDto()
    self.bookmarks[newUrl].url = newUrl
    self.bookmarks[newUrl].name = newName
    discard response.getProp("imageUrl", self.bookmarks[newurl].imageUrl)
    discard response.getProp("removed", self.bookmarks[newurl].removed)
    discard response.getProp("deletedAt", self.bookmarks[newurl].deletedAt)
    result.ok self.bookmarks[newUrl]
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    result.err errDescription
