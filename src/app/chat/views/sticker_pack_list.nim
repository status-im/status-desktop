import NimQml, Tables
import ../../../status/chat/stickers
import ../../../status/libstatus/types

type
  StickerPackRoles {.pure.} = enum
    Author = UserRole + 1,
    Id = UserRole + 2
    Name = UserRole + 3
    Price = UserRole + 4
    Preview = UserRole + 5
    Thumbnail = UserRole + 6

QtObject:
  type
    StickerPackList* = ref object of QAbstractListModel
      packs*: seq[StickerPack]

  proc setup(self: StickerPackList) = self.QAbstractListModel.setup

  proc delete(self: StickerPackList) = self.QAbstractListModel.delete

  proc newStickerPackList*(): StickerPackList =
    new(result, delete)
    result.packs = @[]
    result.setup()

  method rowCount(self: StickerPackList, index: QModelIndex = nil): int = self.packs.len

  method data(self: StickerPackList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.packs.len:
      return

    let stickerPack = self.packs[index.row]
    let stickerPackRole = role.StickerPackRoles
    case stickerPackRole:
      of StickerPackRoles.Author: result = newQVariant(stickerPack.author)
      of StickerPackRoles.Id: result = newQVariant($stickerPack.id)
      of StickerPackRoles.Name: result = newQVariant(stickerPack.name)
      of StickerPackRoles.Price: result = newQVariant(stickerPack.price)
      of StickerPackRoles.Preview: result = newQVariant(decodeContentHash(stickerPack.preview))
      of StickerPackRoles.Thumbnail: result = newQVariant(decodeContentHash(stickerPack.thumbnail))

  method roleNames(self: StickerPackList): Table[int, string] =
    {
      StickerPackRoles.Author.int:"author",
      StickerPackRoles.Id.int:"id",
      StickerPackRoles.Name.int: "name",
      StickerPackRoles.Price.int: "price",
      StickerPackRoles.Preview.int: "preview",
      StickerPackRoles.Thumbnail.int: "thumbnail"
    }.toTable

  proc addStickerPackToList*(self: StickerPackList, pack: StickerPack): int =
    self.beginInsertRows(newQModelIndex(), 0, 0)
    self.packs.insert(pack, 0)
    self.endInsertRows()
    result = 0
