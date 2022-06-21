import NimQml, Tables
import ephemeral_notification_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    DurationInMs
    Title
    SubTitle
    Icon
    Loading
    EphNotifType
    Url

QtObject:
  type Model* = ref object of QAbstractListModel
    items*: seq[Item]

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.DurationInMs.int:"durationInMs",
      ModelRole.Title.int:"title",
      ModelRole.SubTitle.int:"subTitle",
      ModelRole.Icon.int:"icon",
      ModelRole.Loading.int:"loading",
      ModelRole.EphNotifType.int:"ephNotifType",
      ModelRole.Url.int:"url"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
      of ModelRole.Id:
        result = newQVariant(item.id)
      of ModelRole.DurationInMs:
        result = newQVariant(item.durationInMs)
      of ModelRole.Title:
        result = newQVariant(item.title)
      of ModelRole.SubTitle:
        result = newQVariant(item.subTitle)
      of ModelRole.Icon:
        result = newQVariant(item.icon)
      of ModelRole.Loading:
        result = newQVariant(item.loading)
      of ModelRole.EphNotifType:
        result = newQVariant(item.ephNotifType.int)
      of ModelRole.Url:
        result = newQVariant(item.url)

  proc findIndexById(self: Model, id: int64): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        return i
    return -1
  
  proc getItemWithId*(self: Model, id: int64): Item =
    let ind = self.findIndexById(id)
    if(ind == -1):
      return
    return self.items[ind]

  proc addItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

  proc removeItemWithId*(self: Model, id: int64) =
    let ind = self.findIndexById(id)
    if(ind == -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()