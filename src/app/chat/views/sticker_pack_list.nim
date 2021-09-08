import NimQml, Tables, sequtils, sugar
import status/chat/stickers, ./sticker_list
import status/utils
import status/types/[sticker]

type
  StickerPackRoles {.pure.} = enum
    Author = UserRole + 1,
    Id = UserRole + 2
    Name = UserRole + 3
    Price = UserRole + 4
    Preview = UserRole + 5
    Stickers = UserRole + 6
    Thumbnail = UserRole + 7
    Installed = UserRole + 8
    Bought = UserRole + 9
    Pending = UserRole + 10

type
  StickerPackView* = tuple[pack: StickerPack, stickers: StickerList, installed, bought, pending: bool]

QtObject:
  type
    StickerPackList* = ref object of QAbstractListModel
      packs*: seq[StickerPackView]
      packIdToRetrieve*: int

  proc setup(self: StickerPackList) = self.QAbstractListModel.setup

  proc delete(self: StickerPackList) = self.QAbstractListModel.delete

  proc clear*(self: StickerPackList) =
    self.beginResetModel()
    self.packs = @[]
    self.endResetModel()

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

    let packInfo = self.packs[index.row]
    let stickerPack = packInfo.pack
    let stickerPackRole = role.StickerPackRoles
    case stickerPackRole:
      of StickerPackRoles.Author: result = newQVariant(stickerPack.author)
      of StickerPackRoles.Id: result = newQVariant(stickerPack.id)
      of StickerPackRoles.Name: result = newQVariant(stickerPack.name)
      of StickerPackRoles.Price: result = newQVariant(stickerPack.price.wei2Eth)
      of StickerPackRoles.Preview: result = newQVariant(decodeContentHash(stickerPack.preview))
      of StickerPackRoles.Stickers: result = newQVariant(packInfo.stickers)
      of StickerPackRoles.Thumbnail: result = newQVariant(decodeContentHash(stickerPack.thumbnail))
      of StickerPackRoles.Installed: result = newQVariant(packInfo.installed)
      of StickerPackRoles.Bought: result = newQVariant(packInfo.bought)
      of StickerPackRoles.Pending: result = newQVariant(packInfo.pending)

  method roleNames(self: StickerPackList): Table[int, string] =
    {
      StickerPackRoles.Author.int:"author",
      StickerPackRoles.Id.int:"packId",
      StickerPackRoles.Name.int: "name",
      StickerPackRoles.Price.int: "price",
      StickerPackRoles.Preview.int: "preview",
      StickerPackRoles.Stickers.int: "stickers",
      StickerPackRoles.Thumbnail.int: "thumbnail",
      StickerPackRoles.Installed.int: "installed",
      StickerPackRoles.Bought.int: "bought",
      StickerPackRoles.Pending.int: "pending"
    }.toTable


  proc findIndexById*(self: StickerPackList, packId: int, mustBeInstalled: bool = false): int {.slot.} =
    result = -1
    var idx = -1
    for item in self.packs:
      inc idx
      let installed = if mustBeInstalled: item.installed else: true
      if(item.pack.id == packId and installed):
        result = idx
        break

  proc hasKey*(self: StickerPackList, packId: int): bool =
    result = self.packs.anyIt(it.pack.id == packId)
  
  proc `[]`*(self: StickerPackList, packId: int): StickerPack =
    if not self.hasKey(packId):
      raise newException(ValueError, "Sticker pack list does not have a pack with id " & $packId)
    result = find(self.packs, (view: StickerPackView) => view.pack.id == packId).pack

  proc addStickerPackToList*(self: StickerPackList, pack: StickerPack, stickers: StickerList, installed, bought, pending: bool) =
    self.beginInsertRows(newQModelIndex(), 0, 0)
    self.packs.insert((pack: pack, stickers: stickers, installed: installed, bought: bought, pending: pending), 0)
    self.endInsertRows()

  proc removeStickerPackFromList*(self: StickerPackList, packId: int) =
    let idx = self.findIndexById(packId)
    self.beginRemoveRows(newQModelIndex(), idx, idx)
    self.packs.keepItIf(it.pack.id != packId)
    self.endRemoveRows()

  proc updateStickerPackInList*(self: StickerPackList, packId: int, installed: bool, pending: bool) =
    if not self.hasKey(packId):
      return

    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.packs.len, 0, nil)
    self.packs.apply(proc(it: var StickerPackView) =
      if it.pack.id == packId:
        it.installed = installed
        it.pending = pending)

    self.dataChanged(topLeft, bottomRight, @[StickerPackRoles.Installed.int, StickerPackRoles.Pending.int])



  proc getStickers*(self: StickerPackList): QVariant {.slot.} =
    let packInfo = self.packs[self.packIdToRetrieve]
    result = newQVariant(packInfo.stickers)
  
  proc rowData*(self: StickerPackList, row: int, data: string): string {.slot.} =
    if row < 0 or (row > self.packs.len - 1):
      return
    self.packIdToRetrieve = row
    let packInfo = self.packs[row]
    let stickerPack = packInfo.pack
    case data:
      of "author": result = stickerPack.author
      of "name": result = stickerPack.name
      of "price": result = $stickerPack.price.wei2Eth
      of "preview": result = decodeContentHash(stickerPack.preview)
      of "thumbnail": result = decodeContentHash(stickerPack.thumbnail)
      of "installed": result = $packInfo.installed
      of "bought": result = $packInfo.bought
      of "pending": result = $packInfo.pending
      else: result = ""


    

