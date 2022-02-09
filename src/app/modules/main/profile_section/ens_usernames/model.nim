import NimQml, Tables

type Item* = object
  ensUsername*: string
  isPending*: bool

type
  ModelRole {.pure.} = enum
    EnsUsername = UserRole + 1
    IsPending

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

  proc countChanged(self: Model) {.signal.}
  proc getCount(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.EnsUsername.int:"ensUsername",
      ModelRole.IsPending.int:"isPending"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.EnsUsername:
      result = newQVariant(item.ensUsername)
    of ModelRole.IsPending:
      result = newQVariant(item.isPending)

  proc findIndexForItemWithEnsUsername(self: Model, ensUsername: string): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].ensUsername == ensUsername):
        return i
    return -1

  proc containsEnsUsername*(self: Model, ensUsername: string): bool =
    return self.findIndexForItemWithEnsUsername(ensUsername) != -1

  proc addItem*(self: Model, item: Item) =
    if(self.containsEnsUsername(item.ensUsername)):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc removeItemByEnsUsername*(self: Model, ensUsername: string) =
    let index = self.findIndexForItemWithEnsUsername(ensUsername)
    if(index == -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()

  proc updatePendingStatus*(self: Model, ensUsername: string, pendingStatus: bool) =
    let ind = self.findIndexForItemWithEnsUsername(ensUsername)
    if(ind == -1):
      return

    self.items[ind].isPending = pendingStatus

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.IsPending.int])
