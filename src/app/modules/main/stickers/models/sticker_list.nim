import NimQml, Tables, sequtils
import ../io_interface, ../item

type
  StickerRoles {.pure.} = enum
    Url = UserRole + 1
    Hash = UserRole + 2
    PackId = UserRole + 3

QtObject:
  type
    StickerList* = ref object of QAbstractListModel
      delegate: io_interface.AccessInterface
      stickers*: seq[Item]

  proc setup(self: StickerList) = self.QAbstractListModel.setup

  proc delete(self: StickerList) = self.QAbstractListModel.delete

  proc newStickerList*(delegate: io_interface.AccessInterface, stickers: seq[Item] = @[]): StickerList =
    new(result, delete)
    result.delegate = delegate
    result.stickers = stickers
    result.setup()

  method rowCount(self: StickerList, index: QModelIndex = nil): int = self.stickers.len

  method data(self: StickerList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.stickers.len:
      return

    let sticker = self.stickers[index.row]
    let stickerRole = role.StickerRoles
    case stickerRole:
      of StickerRoles.Url: result = newQVariant(sticker.getURL)
      of StickerRoles.Hash: result = newQVariant(sticker.getHash)
      of StickerRoles.PackId: result = newQVariant(sticker.getPackId)

  method roleNames(self: StickerList): Table[int, string] =
    {
      StickerRoles.Url.int:"url",
      StickerRoles.Hash.int:"hash",
      StickerRoles.PackId.int:"packId"
    }.toTable

  proc addStickerToList*(self: StickerList, sticker: Item) =
    if(self.stickers.any(proc(existingSticker: Item): bool = return existingSticker.getHash == sticker.getHash)):
      return
    self.beginInsertRows(newQModelIndex(), 0, 0)
    self.stickers.insert(sticker, 0)
    self.endInsertRows()

  proc findIndexByPackId(self: StickerList, packId: string): int =
    for i in 0 ..< self.stickers.len:
      if(self.stickers[i].getPackId() == packId):
        return i
    return -1

  proc removeStickersFromList*(self: StickerList, packId: string) =
    let idx = self.findIndexByPackId(packId)
    if idx == -1:
      return
    self.beginRemoveRows(newQModelIndex(), idx, idx)
    self.stickers.delete(idx)
    self.endRemoveRows()
