import NimQml, Tables, sequtils

import ../../../status/gif

type
  GifRoles {.pure.} = enum
    Url = UserRole + 1
    Id = UserRole + 2
    Title = UserRole + 3
    TinyUrl = UserRole + 4

QtObject:
  type
    GifList* = ref object of QAbstractListModel
      gifs*: seq[GifItem]

  proc setup(self: GifList) = self.QAbstractListModel.setup

  proc delete(self: GifList) = self.QAbstractListModel.delete

  proc newGifList*(): GifList =
    new(result, delete)
    result.gifs = @[]
    result.setup()

  proc setNewData*(self: GifList, gifs: seq[GifItem]) =
    self.beginResetModel()
    self.gifs = gifs
    self.endResetModel()

  method rowCount(self: GifList, index: QModelIndex = nil): int = self.gifs.len

  method data(self: GifList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return

    if index.row < 0 or index.row >= self.gifs.len:
      return

    let gif = self.gifs[index.row]
    case role.GifRoles:
      of GifRoles.Url: result = newQVariant(gif.url)
      of GifRoles.Id: result = newQVariant(gif.id)
      of GifRoles.Title: result = newQVariant(gif.title)
      of GifRoles.TinyUrl: result = newQVariant(gif.tinyUrl)

  method roleNames(self: GifList): Table[int, string] =
    {
      GifRoles.Url.int:"url",
      GifRoles.Id.int:"id",
      GifRoles.Title.int:"title",
      GifRoles.TinyUrl.int:"tinyUrl"
    }.toTable