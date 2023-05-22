import NimQml, Tables, strutils, strformat

import ./item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Address
    Favourite
    Ens
    ChainShortNames
    IsTest

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: Model) {.signal.}
  proc itemChanged(self: Model, address: string) {.signal.}

  proc getCount*(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Name.int:"name",
      ModelRole.Address.int:"address",
      ModelRole.Favourite.int:"favourite",
      ModelRole.Ens.int:"ens",
      ModelRole.ChainShortNames.int:"chainShortNames",
      ModelRole.IsTest.int:"isTest",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Name:
      result = newQVariant(item.getName())
    of ModelRole.Address:
      result = newQVariant(item.getAddress())
    of ModelRole.Favourite:
      result = newQVariant(item.getFavourite())
    of ModelRole.Ens:
      result = newQVariant(item.getEns())
    of ModelRole.ChainShortNames:
      result = newQVariant(item.getChainShortNames())
    of ModelRole.IsTest:
      result = newQVariant(item.getIsTest())

  proc rowData(self: Model, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "name": result = $item.getName()
      of "address": result = $item.getAddress()
      of "favourite": result = $item.getFavourite()
      of "ens": result = $item.getEns()
      of "chainShortNames": result = $item.getChainShortNames()
      of "isTest": result = $item.getIsTest()

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

    for item in items:
        self.itemChanged(item.getAddress())

  proc getNameByAddress*(self: Model, address: string): string =
    for item in self.items:
      if(cmpIgnoreCase(item.getAddress(), address) == 0):
        return item.getName()
    return ""

  proc getChainShortNamesForAddress*(self: Model, address: string): string =
    for item in self.items:
      if(cmpIgnoreCase(item.getAddress(), address) == 0):
        return item.getChainShortNames()
    return ""

  proc getEnsForAddress*(self: Model, address: string): string =
    for item in self.items:
      if(cmpIgnoreCase(item.getAddress(), address) == 0):
        return item.getEns()
    return ""
