import NimQml, json, chronicles
import ../../status/status
import ../../status/libstatus/types as status_types
import ../../status/libstatus/settings as status_settings
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
      let bookmarksJSON = status_settings.getSetting[string](Setting.Bookmarks, "[]").parseJson
      for bookmark in bookmarksJSON:
        bookmarks.add(Bookmark(url: bookmark["url"].getStr, name: bookmark["name"].getStr, image: ""))
    except:
      # Bad JSON. Just use the empty array
      discard
    self.bookmarks.setNewData(bookmarks)

  proc getBookmarks*(self: BrowserView): QVariant {.slot.} =
    return newQVariant(self.bookmarks)

  QtProperty[QVariant] bookmarks:
    read = getBookmarks

  proc addBookmark*(self: BrowserView, url: string, name: string) {.slot.} =
    self.bookmarks.addBookmarkItemToList(Bookmark(url: url, name: name, image: ""))
    discard status_settings.saveSetting(Setting.Bookmarks, $(%self.bookmarks.bookmarks))
