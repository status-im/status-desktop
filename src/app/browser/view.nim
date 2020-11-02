import NimQml, json, chronicles
import ../../status/status
import ../../status/libstatus/browser as status_browser
import ../../status/libstatus/types
import views/bookmark_list

QtObject:
  type BrowserView* = ref object of QObject
    status*: Status
    bookmarks*: BookmarkList

  proc setup(self: BrowserView) =
    self.QObject.setup

  proc delete(self: BrowserView) =
    self.QObject.delete
    self.bookmarks.delete

  proc newBrowserView*(status: Status): BrowserView =
    new(result, delete)
    result.bookmarks = newBookmarkList()
    result.status = status
    result.setup

  proc init*(self: BrowserView) =
    var bookmarks: seq[Bookmark] = @[]
    try:
      let responseResult = status_browser.getBookmarks().parseJson["result"]
      if responseResult.kind != JNull:
        for bookmark in responseResult:
          bookmarks.add(Bookmark(url: bookmark["url"].getStr, name: bookmark["name"].getStr, imageUrl: bookmark["imageUrl"].getStr))
    except:
      # Bad JSON. Just use the empty array
      discard
    self.bookmarks.setNewData(bookmarks)

  proc bookmarksChanged*(self: BrowserView) {.signal.}

  proc getBookmarks*(self: BrowserView): QVariant {.slot.} =
    return newQVariant(self.bookmarks)

  QtProperty[QVariant] bookmarks:
    read = getBookmarks
    notify = bookmarksChanged

  proc addBookmark*(self: BrowserView, url: string, name: string) {.slot.} =
    let bookmark = status_browser.storeBookmark(url, name)
    self.bookmarks.addBookmarkItemToList(bookmark)
    self.bookmarksChanged()

  proc removeBookmark*(self: BrowserView, url: string) {.slot.} =
    let index = self.bookmarks.getBookmarkIndexByUrl(url)
    if index == -1:
      return
    self.bookmarks.removeBookmarkItemFromList(index)
    status_browser.deleteBookmark(url)
    self.bookmarksChanged()

  proc modifyBookmark*(self: BrowserView, ogUrl: string, newUrl: string, newName: string) {.slot.} =
    let index = self.bookmarks.getBookmarkIndexByUrl(ogUrl)
    if index == -1:
      # Somehow we don't know this URL. Let's just add it as a new one
      self.addBookmark(newUrl, newName)
      return
    self.bookmarks.modifyBookmarkItemFromList(index, newUrl, newName)
    status_browser.updateBookmark(ogUrl, newUrl, newName)
    self.bookmarksChanged()
