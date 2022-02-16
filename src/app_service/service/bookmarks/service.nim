import Tables, json, sequtils, strformat, chronicles
import result
include ../../common/json_utils
import ./dto/bookmark as bookmark_dto
import ../../../backend/backend

export bookmark_dto

logScope:
  topics = "bookmarks-service"

type
  Service* = ref object of RootObj
    bookmarks: Table[string, BookmarkDto] # [url, BookmarkDto]

type R = Result[BookmarkDto, string]

proc delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.bookmarks = initTable[string, BookmarkDto]()

proc init*(self: Service) =
  try:
    let response = backend.getBookmarks()
    for bookmark in response.result.getElems().mapIt(it.toBookmarkDto()):
        self.bookmarks[bookmark.url] = bookmark

  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

proc getBookmarks*(self: Service): seq[BookmarkDto] =
  return toSeq(self.bookmarks.values)

proc storeBookmark*(self: Service, url, name: string): R =
  try:
    let response = backend.storeBookmark(backend.Bookmark(name: name, url: url)).result
    self.bookmarks[url] = BookmarkDto()
    self.bookmarks[url].url = url
    self.bookmarks[url].name = name
    discard response.getProp("imageUrl", self.bookmarks[url].imageUrl)
    result.ok self.bookmarks[url]
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    result.err errDescription

proc deleteBookmark*(self: Service, url: string): bool =
  try:
    if not self.bookmarks.hasKey(url):
      return
    discard backend.deleteBookmark(url)
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

    let response = backend.updateBookmark(oldUrl, backend.Bookmark(name: newName, url: newUrl)).result
    self.bookmarks.del(oldUrl)
    self.bookmarks[newUrl] = BookmarkDto()
    self.bookmarks[newUrl].url = newUrl
    self.bookmarks[newUrl].name = newName
    discard response.getProp("imageUrl", self.bookmarks[newurl].imageUrl)
    result.ok self.bookmarks[newUrl]
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    result.err errDescription
