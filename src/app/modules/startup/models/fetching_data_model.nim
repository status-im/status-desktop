import NimQml, Tables, strutils

import fetching_data_item

type
  ModelRole {.pure.} = enum
    Entity = UserRole + 1
    Icon
    LoadedMessages
    TotalMessages

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]
      allTotalsSet: bool
      lastKnownBackedUpMsgClock: uint64

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup
    result.allTotalsSet = false
    result.lastKnownBackedUpMsgClock = 0

  proc countChanged(self: Model) {.signal.}
  proc getCount*(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int]count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Entity.int:"entity",
      ModelRole.Icon.int:"icon",
      ModelRole.LoadedMessages.int:"loadedMessages",
      ModelRole.TotalMessages.int:"totalMessages"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Entity:
      result = newQVariant(item.entity())
    of ModelRole.Icon:
      result = newQVariant(item.icon())
    of ModelRole.LoadedMessages:
      result = newQVariant(item.loadedMessages())
    of ModelRole.TotalMessages:
      result = newQVariant(item.totalMessages())

  proc findIndexForEntity(self: Model, entity: string): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].entity == entity):
        return i
    return -1

  proc init*(self: Model, entities: seq[tuple[entity: string, icon: string]]) =
    self.allTotalsSet = false
    self.beginResetModel()
    self.items = @[]
    for e in entities:
      self.items.add(newItem(e.entity, e.icon))
    self.endResetModel()
    self.countChanged()

  proc receivedMessageAtPosition*(self: Model, entity: string, position: int) =
    let ind = self.findIndexForEntity(entity)
    if(ind == -1):
      return
    self.items[ind].receivedMessageAtPosition(position)
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.LoadedMessages.int])

  proc evaluateWhetherToProcessReceivedData*(self: Model, backedUpMsgClock: uint64, entities: seq[tuple[entity: string, icon: string]]): bool =
    if self.lastKnownBackedUpMsgClock > backedUpMsgClock:
      return false
    if self.lastKnownBackedUpMsgClock < backedUpMsgClock:
      self.init(entities)
      self.lastKnownBackedUpMsgClock = backedUpMsgClock
    return true

  proc reevaluateAllTotals(self: Model) =
    self.allTotalsSet = true
    for it in self.items:
      if it.loadedMessages != it.totalMessages:
        self.allTotalsSet = false
        return

  proc updateTotalMessages*(self: Model, entity: string, totalMessages: int) =
    if self.allTotalsSet:
      return
    let ind = self.findIndexForEntity(entity)
    if(ind == -1):
      return
    self.items[ind].totalMessages = totalMessages
    self.reevaluateAllTotals()
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.TotalMessages.int, ModelRole.LoadedMessages.int])

  proc removeSection*(self: Model, entity: string) =
    if self.allTotalsSet:
      return
    let ind = self.findIndexForEntity(entity)
    if(ind == -1):
      return
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()
    self.countChanged()
    self.reevaluateAllTotals()

  proc allMessagesLoaded*(self: Model): bool =
    if not self.allTotalsSet:
      return false
    for it in self.items:
      if it.loadedMessages != it.totalMessages:
        return false
    return true

  proc isEntityLoaded*(self: Model, entity: string): bool =
    let ind = self.findIndexForEntity(entity)
    if(ind == -1):
      return false
    return self.items[ind].loadedMessages == self.items[ind].totalMessages