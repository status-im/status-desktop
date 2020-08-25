import NimQml, tables
from ../../../status/wallet import CollectibleList

type
  CollectiblesRoles {.pure.} = enum
    CollectibleType = UserRole + 1
    CollectiblesJSON = UserRole + 2
    Error = UserRole + 3
    Loading = UserRole + 4

QtObject:
  type CollectiblesList* = ref object of QAbstractListModel
    collectibleLists*: seq[CollectibleList]

  proc setup(self: CollectiblesList) = self.QAbstractListModel.setup

  proc forceUpdate*(self: CollectiblesList) =
    self.beginResetModel()
    self.endResetModel()

  proc delete(self: CollectiblesList) =
    self.QAbstractListModel.delete
    self.collectibleLists = @[]

  proc newCollectiblesList*(): CollectiblesList =
    new(result, delete)
    result.collectibleLists = @[]
    result.setup

  proc setCollectiblesJSONByType*(self: CollectiblesList, collectibleType: string, collectiblesJSON: string) =
    for collectibleList in self.collectibleLists:
      if collectibleList.collectibleType == collectibleType:
        collectibleList.collectiblesJSON = collectiblesJSON
        collectibleList.loading = 0
        self.forceUpdate()
        break

  method rowCount(self: CollectiblesList, index: QModelIndex = nil): int =
    return self.collectibleLists.len

  method data(self: CollectiblesList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.collectibleLists.len:
      return
    let collectibleList = self.collectibleLists[index.row]
    let collectibleRole = role.CollectiblesRoles
    case collectibleRole:
    of CollectiblesRoles.CollectibleType: result = newQVariant(collectibleList.collectibleType)
    of CollectiblesRoles.CollectiblesJSON: result = newQVariant(collectibleList.collectiblesJSON)
    of CollectiblesRoles.Error: result = newQVariant(collectibleList.error)
    of CollectiblesRoles.Loading: result = newQVariant(collectibleList.loading)

  method roleNames(self: CollectiblesList): Table[int, string] =
    { CollectiblesRoles.CollectibleType.int:"collectibleType",
    CollectiblesRoles.CollectiblesJSON.int:"collectiblesJSON",
    CollectiblesRoles.Error.int:"error",
    CollectiblesRoles.Loading.int:"loading" }.toTable

  proc addCollectibleListToList*(self: CollectiblesList, collectibleList: CollectibleList) =
    self.beginInsertRows(newQModelIndex(), self.collectibleLists.len, self.collectibleLists.len)
    self.collectibleLists.add(collectibleList)
    self.endInsertRows()

  proc setNewData*(self: CollectiblesList, collectibleLists: seq[CollectibleList]) =
    self.beginResetModel()
    self.collectibleLists = collectibleLists
    self.endResetModel()
