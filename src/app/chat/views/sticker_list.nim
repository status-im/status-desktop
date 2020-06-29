import NimQml, Tables, sequtils
import ../../../status/chat/stickers
import ../../../status/libstatus/types

type
  StickerRoles {.pure.} = enum
    Url = UserRole + 1
    Hash = UserRole + 2
    PackId = UserRole + 3

QtObject:
  type
    StickerList* = ref object of QAbstractListModel
      stickers*: seq[Sticker]

  proc setup(self: StickerList) = self.QAbstractListModel.setup

  proc delete(self: StickerList) = self.QAbstractListModel.delete

  proc newStickerList*(stickers: seq[Sticker] = @[]): StickerList =
    new(result, delete)
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
      of StickerRoles.Url: result = newQVariant(decodeContentHash(sticker.hash))
      of StickerRoles.Hash: result = newQVariant(sticker.hash)
      of StickerRoles.PackId: result = newQVariant(sticker.packId)

  method roleNames(self: StickerList): Table[int, string] =
    {
      StickerRoles.Url.int:"url",
      StickerRoles.Hash.int:"hash",
      StickerRoles.PackId.int:"packId"
    }.toTable

  proc addStickerToList*(self: StickerList, sticker: Sticker) =
    if(self.stickers.any(proc(existingSticker: Sticker): bool = return existingSticker.hash == sticker.hash)):
      return
    self.beginInsertRows(newQModelIndex(), 0, 0)
    self.stickers.insert(sticker, 0)
    self.endInsertRows()

  proc removeStickersFromList*(self: StickerList, packId: int) =
    if not self.stickers.anyIt(it.packId == packId):
      return
    self.beginRemoveRows(newQModelIndex(), 0, 0)
    self.stickers.keepItIf(it.packId != packId)
    self.endRemoveRows()
