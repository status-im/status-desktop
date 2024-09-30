import NimQml, Tables
import pending_request_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    PubKey
    ChatId
    CommunityId
    State
    Our

QtObject:
  type PendingRequestModel* = ref object of QAbstractListModel
    items*: seq[PendingRequestItem]

  proc setup(self: PendingRequestModel) =
    self.QAbstractListModel.setup

  proc delete(self: PendingRequestModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newPendingRequestModel*(): PendingRequestModel =
    new(result, delete)
    result.setup

  proc countChanged(self: PendingRequestModel) {.signal.}

  proc setItems*(self: PendingRequestModel, items: seq[PendingRequestItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getCount(self: PendingRequestModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: PendingRequestModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: PendingRequestModel): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.PubKey.int:"pubKey",
      ModelRole.ChatId.int:"chatId",
      ModelRole.CommunityId.int:"communityId",
      ModelRole.State.int:"state",
      ModelRole.Our.int:"our"
    }.toTable

  method data(self: PendingRequestModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
      of ModelRole.Id:
        result = newQVariant(item.id)
      of ModelRole.PubKey:
        result = newQVariant(item.pubKey)
      of ModelRole.ChatId:
        result = newQVariant(item.chatId)
      of ModelRole.CommunityId:
        result = newQVariant(item.communityId)
      of ModelRole.State:
        result = newQVariant(item.state)
      of ModelRole.Our:
        result = newQVariant(item.our)

  proc findIndexById(self: PendingRequestModel, id: string): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        return i
    return -1

  proc addItems*(self: PendingRequestModel, items: seq[PendingRequestItem]) =
    if(items.len == 0):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let first = self.items.len
    let last = first + items.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items.add(items)
    self.endInsertRows()
    self.countChanged()

  proc addItem*(self: PendingRequestModel, item: PendingRequestItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc removeItemWithId*(self: PendingRequestModel, id: string) =
    let ind = self.findIndexById(id)
    if ind == -1:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()
    self.countChanged()
