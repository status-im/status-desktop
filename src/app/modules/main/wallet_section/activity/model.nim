import NimQml, Tables, strutils, strformat, sequtils, logging

import ./entry

# TODO - DEV: remove these imports and associated code after all the metadata is returned by the filter API
import app_service/service/transaction/dto
import app/modules/shared_models/currency_amount
import ../transactions/item as transaction

type
  ModelRole {.pure.} = enum
    ActivityEntryRole = UserRole + 1

QtObject:
  type
    Model* = ref object of QAbstractListModel
      entries: seq[ActivityEntry]
      hasMore: bool

  proc delete(self: Model) =
    self.entries = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.entries = @[]
    result.setup
    result.hasMore = true

  proc `$`*(self: Model): string =
    for i in 0 ..< self.entries.len:
      result &= fmt"""[{i}]:({$self.entries[i]})"""

  proc countChanged(self: Model) {.signal.}

  proc getCount*(self: Model): int {.slot.} =
    self.entries.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.entries.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.ActivityEntryRole.int:"activityEntry",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.entries.len):
      return

    let entry = self.entries[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ActivityEntryRole:
      result = newQVariant(entry)

  proc hasMoreChanged*(self: Model) {.signal.}

  proc setHasMore(self: Model, hasMore: bool) {.slot.} =
    self.hasMore = hasMore
    self.hasMoreChanged()

  proc resetModel*(self: Model, newEntries: seq[ActivityEntry]) =
    self.beginResetModel()
    self.entries = newEntries
    self.endResetModel()

  proc setEntries*(self: Model, newEntries: seq[ActivityEntry], offset: int, hasMore: bool) =
    if offset == 0:
      self.resetModel(newEntries)
    else:
      let parentModelIndex = newQModelIndex()
      defer: parentModelIndex.delete

      if offset != self.entries.len:
        error "offset != self.entries.len"
        return
      self.beginInsertRows(parentModelIndex, self.entries.len, self.entries.len + newEntries.len - 1)
      self.entries.add(newEntries)
      self.endInsertRows()
    self.countChanged()
    self.setHasMore(hasMore)

  proc getHasMore*(self: Model): bool {.slot.} =
    return self.hasMore

  QtProperty[bool] hasMore:
    read = getHasMore
    notify = hasMoreChanged
