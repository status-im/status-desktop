import NimQml, Tables, chronicles
import sequtils as sequtils
import ../../../status/types/[bookmark]

type
  BookmarkRoles {.pure.} = enum
    Name = UserRole + 1
    Url = UserRole + 2
    ImageUrl = UserRole + 3

QtObject:
  type
    BookmarkList* = ref object of QAbstractListModel
      bookmarks*: seq[Bookmark]

  proc setup(self: BookmarkList) = self.QAbstractListModel.setup

  proc delete(self: BookmarkList) =
    self.bookmarks = @[]
    self.QAbstractListModel.delete

  proc newBookmarkList*(): BookmarkList =
    new(result, delete)
    result.bookmarks = @[]
    result.setup

  method rowCount*(self: BookmarkList, index: QModelIndex = nil): int = self.bookmarks.len

  proc rowData(self: BookmarkList, index: int, column: string): string {.slot.} =
    if (index > self.bookmarks.len - 1):
      return
    let bookmark = self.bookmarks[index]
    case column:
      of "name": result = bookmark.name
      of "url": result = bookmark.url
      of "imageUrl": result = bookmark.imageUrl

  method data(self: BookmarkList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.bookmarks.len:
      return

    let bookmarkItem = self.bookmarks[index.row]

    let bookmarkItemRole = role.BookmarkRoles
    case bookmarkItemRole:
      of BookmarkRoles.Name: result = newQVariant(bookmarkItem.name)
      of BookmarkRoles.Url: result = newQVariant(bookmarkItem.url)
      of BookmarkRoles.ImageUrl: result = newQVariant(bookmarkItem.imageUrl)

  method roleNames(self: BookmarkList): Table[int, string] =
    {
      BookmarkRoles.Name.int:"name",
      BookmarkRoles.ImageUrl.int:"imageUrl",
      BookmarkRoles.Url.int:"url"
    }.toTable

  proc addBookmarkItemToList*(self: BookmarkList, bookmark: Bookmark) =
    self.beginInsertRows(newQModelIndex(), self.bookmarks.len, self.bookmarks.len)
    self.bookmarks.add(bookmark)
    self.endInsertRows()

  proc removeBookmarkItemFromList*(self: BookmarkList, index: int) =
    self.beginRemoveRows(newQModelIndex(), index, index)
    self.bookmarks.delete(index)
    self.endRemoveRows()

  proc modifyBookmarkItemFromList*(self: BookmarkList, index: int, url: string, name: string) =
    let topLeft = self.createIndex(index, index, nil)
    let bottomRight = self.createIndex(index, index, nil)
    self.bookmarks[index] = Bookmark(url: url, name: name)
    self.dataChanged(topLeft, bottomRight, @[BookmarkRoles.Name.int, BookmarkRoles.Url.int])

  proc setNewData*(self: BookmarkList, bookmarkList: seq[Bookmark]) =
    self.beginResetModel()
    self.bookmarks = bookmarkList
    self.endResetModel()
  
  proc getBookmarkIndexByUrl*(self: BookmarkList, url: string): int {.slot.} =
    var i = 0
    for bookmark in self.bookmarks:
      if bookmark.url == url:
        return i
      i = i + 1
    return -1

