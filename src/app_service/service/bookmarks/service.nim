import Tables, json, sequtils, strformat, chronicles
import result
include ../../common/json_utils
import service_interface, dto/bookmark
import status/statusgo_backend_new/bookmarks as status_go

export service_interface

logScope:
  topics = "bookmarks-service"

type 
  Service* = ref object of ServiceInterface
    bookmarks: Table[string, BookmarkDto] # [url, BookmarkDto]

type R = Result[BookmarkDto, string]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.bookmarks = initTable[string, BookmarkDto]()

method init*(self: Service) =
  try:
    let response = status_go.getBookmarks()
    for bookmark in response.result.getElems().mapIt(it.toBookmarkDto()):
        self.bookmarks[bookmark.url] = bookmark

  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

method getBookmarks*(self: Service): seq[BookmarkDto] =
  return toSeq(self.bookmarks.values)

method storeBookmark*(self: Service, url, name: string): R =
  try:
    let response = status_go.storeBookmark(url, name).result
    self.bookmarks[url] = BookmarkDto()
    self.bookmarks[url].url = url
    self.bookmarks[url].name = name
    discard response.getProp("imageUrl", self.bookmarks[url].imageUrl)
    result.ok self.bookmarks[url]
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    result.err errDescription

method deleteBookmark*(self: Service, url: string): bool =
  try:
    if not self.bookmarks.hasKey(url):
      return
    discard status_go.deleteBookmark(url)
    self.bookmarks.del(url)
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    return
  return true

method updateBookmark*(self: Service, oldUrl, newUrl, newName: string): R =
  try:
    if not self.bookmarks.hasKey(oldUrl):
      return

    let response = status_go.updateBookmark(oldUrl, newUrl, newName).result
    self.bookmarks.del(oldUrl)
    self.bookmarks[newUrl].url = newUrl
    self.bookmarks[newUrl].name = newName
    discard response.getProp("imageUrl", self.bookmarks[newurl].imageUrl)
    result.ok self.bookmarks[newUrl]
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    result.err errDescription
