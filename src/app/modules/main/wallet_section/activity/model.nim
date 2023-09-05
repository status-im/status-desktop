import NimQml, Tables, strutils, strformat, sequtils, logging, options

import ./entry

import app/modules/shared_models/currency_amount
import backend/activity as backend
import backend/backend as importing_transactionidentity_comp

type
  ModelRole {.pure.} = enum
    ActivityEntryRole = UserRole + 1

QtObject:
  type
    Model* = ref object of QAbstractListModel
      entries: seq[entry.ActivityEntry]
      hasMore: bool

  proc delete(self: Model) =
    self.entries = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)

    result.entries = @[]
    result.hasMore = true

    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.entries.len:
      result &= fmt"""[{i}]:({$self.entries[i]})"""

  proc getEntry*(self: Model, index: int): entry.ActivityEntry =
    if index < 0 or index >= self.entries.len:
      return nil

    return self.entries[index]

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

  proc resetModel*(self: Model, newEntries: seq[entry.ActivityEntry]) =
    self.beginResetModel()
    self.entries = newEntries
    self.endResetModel()

  proc setEntries*(self: Model, newEntries: seq[entry.ActivityEntry], offset: int, hasMore: bool) =
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

  proc sameIdentity(e: entry.ActivityEntry, d: backend.Data): bool =
    let m = e.getMetadata()
    if m.getPayloadType() != d.payloadType:
      return false

    if m.getPayloadType() == MultiTransaction:
      return m.getMultiTransactionId().get(0) == d.id.get()

    return m.getTransactionIdentity().isSome() and d.transaction.isSome() and m.getTransactionIdentity().get() == d.transaction.get()

  proc updateEntries*(self: Model, updates: seq[backend.Data]) =
    for i in countdown(self.entries.high, 0):
      for j in countdown(updates.high, 0):
        if sameIdentity(self.entries[i], updates[j]):
          if updates[j].nftName.isSome():
            self.entries[i].setNftName(updates[j].nftName.get())
          if updates[j].nftUrl.isSome():
            self.entries[i].setNftImageUrl(updates[j].nftUrl.get())
          break

  proc getHasMore*(self: Model): bool {.slot.} =
    return self.hasMore

  QtProperty[bool] hasMore:
    read = getHasMore
    notify = hasMoreChanged
