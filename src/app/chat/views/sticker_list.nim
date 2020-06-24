import NimQml, Tables
import ../../../status/chat/stickers

import ../../../status/libstatus/types

type
  StickerRoles {.pure.} = enum
    Url = UserRole + 1
    Hash = UserRole + 2

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

  method roleNames(self: StickerList): Table[int, string] =
    {
      StickerRoles.Url.int:"url",
      StickerRoles.Hash.int:"hash"
    }.toTable
