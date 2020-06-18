import NimQml
import tables
import ../../../status/wallet

type
  CollectiblesRoles {.pure.} = enum
    Name = UserRole + 1,
    Image = UserRole + 2
    CollectibleId = UserRole + 3

QtObject:
  type CollectiblesList* = ref object of QAbstractListModel
    collectibles*: seq[Collectible]

  proc setup(self: CollectiblesList) = self.QAbstractListModel.setup

  proc delete(self: CollectiblesList) =
    self.QAbstractListModel.delete
    self.collectibles = @[]

  proc newCollectiblesList*(): CollectiblesList =
    new(result, delete)
    result.collectibles = @[]
    result.setup

  method rowCount(self: CollectiblesList, index: QModelIndex = nil): int =
    return self.collectibles.len

  method data(self: CollectiblesList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.collectibles.len:
      return
    let collectible = self.collectibles[index.row]
    let collectibleRole = role.CollectiblesRoles
    case collectibleRole:
    of CollectiblesRoles.Name: result = newQVariant(collectible.name)
    of CollectiblesRoles.Image: result = newQVariant(collectible.image)
    of CollectiblesRoles.CollectibleId: result = newQVariant(collectible.id)

  method roleNames(self: CollectiblesList): Table[int, string] =
    { CollectiblesRoles.Name.int:"name",
    CollectiblesRoles.Image.int:"image",
    CollectiblesRoles.CollectibleId.int:"collectibleId" }.toTable

  proc addCollectibleToList*(self: CollectiblesList, colelctible: Collectible) =
    self.beginInsertRows(newQModelIndex(), self.collectibles.len, self.collectibles.len)
    self.collectibles.add(colelctible)
    self.endInsertRows()

  proc setNewData*(self: CollectiblesList, collectibles: seq[Collectible]) =
    self.beginResetModel()
    self.collectibles = collectibles
    self.endResetModel()

  proc forceUpdate*(self: CollectiblesList) =
    self.beginResetModel()
    self.endResetModel()
