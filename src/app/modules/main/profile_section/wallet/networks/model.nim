import NimQml, Tables, strutils, strformat

import ./item

const EXPLORER_TX_PREFIX* = "/tx/"

type
  ModelRole* {.pure.} = enum
    ChainId = UserRole + 1,
    Layer
    ChainName
    IconUrl
    ShortName
    ChainColor

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

  proc getCount(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount*(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.ChainId.int:"chainId",
      ModelRole.Layer.int:"layer",
      ModelRole.ChainName.int:"chainName",
      ModelRole.IconUrl.int:"iconUrl",
      ModelRole.ShortName.int:"shortName",
      ModelRole.ChainColor.int:"chainColor",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ChainId:
      result = newQVariant(item.getChainId())
    of ModelRole.Layer:
      result = newQVariant(item.getLayer())
    of ModelRole.ChainName:
      result = newQVariant(item.getChainName())
    of ModelRole.IconUrl:
      result = newQVariant(item.getIconURL())
    of ModelRole.ShortName:
      result = newQVariant(item.getShortName())
    of ModelRole.ChainColor:
      result = newQVariant(item.getChainColor())

  proc rowData*(self: Model, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "chainId": result = $item.getChainId()
      of "layer": result = $item.getLayer()
      of "chainName": result = $item.getChainName()
      of "iconUrl": result = $item.getIconURL()
      of "shortName": result = $item.getShortName()
      of "chainColor": result = $item.getChainColor()

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getAllNetworksSupportedPrefix*(self: Model): string =
    var networkString = ""
    for item in self.items:
      networkString = networkString & item.getShortName() & ':'
    return networkString
