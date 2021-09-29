import NimQml, json, chronicles
import status/[status, browser]
import types/[bookmark]
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
    let bookmarks = self.status.browser.getBookmarks()
    self.bookmarks.setNewData(bookmarks)

  proc bookmarksChanged*(self: BrowserView) {.signal.}

  proc getBookmarks*(self: BrowserView): QVariant {.slot.} =
    return newQVariant(self.bookmarks)

  QtProperty[QVariant] bookmarks:
    read = getBookmarks
    notify = bookmarksChanged

  proc addBookmark*(self: BrowserView, url: string, name: string) {.slot.} =
    let bookmark = self.status.browser.storeBookmark(Bookmark(url: url, name: name))
    self.bookmarks.addBookmarkItemToList(bookmark)
    self.bookmarksChanged()

  proc removeBookmark*(self: BrowserView, url: string) {.slot.} =
    let index = self.bookmarks.getBookmarkIndexByUrl(url)
    if index == -1:
      return
    self.bookmarks.removeBookmarkItemFromList(index)
    self.status.browser.deleteBookmark(url)
    self.bookmarksChanged()

  proc modifyBookmark*(self: BrowserView, originalUrl: string, newUrl: string, newName: string) {.slot.} =
    let index = self.bookmarks.getBookmarkIndexByUrl(originalUrl)
    if index == -1:
      self.addBookmark(newUrl, newName)
      return

    self.bookmarks.modifyBookmarkItemFromList(index, newUrl, newName)
    self.status.browser.updateBookmark(originalUrl, Bookmark(url: newUrl, name: newName))
    self.bookmarksChanged()
