import NimQml, Tables
import item

import ../../../../../app_service/service/settings/dto/settings

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Name
    Image
    Color
    Type
    Customized
    MuteAllMessages
    PersonalMentions
    GlobalMentions
    OtherMessages

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete*(self: Model) =
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
      ModelRole.Id.int:"itemId",
      ModelRole.Name.int:"name",
      ModelRole.Image.int:"image",
      ModelRole.Color.int:"color",
      ModelRole.Type.int:"type",
      ModelRole.Customized.int:"customized",
      ModelRole.MuteAllMessages.int:"muteAllMessages",
      ModelRole.PersonalMentions.int:"personalMentions",
      ModelRole.GlobalMentions.int:"globalMentions",
      ModelRole.OtherMessages.int:"otherMessages"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Id:
      result = newQVariant(item.id)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.Image:
      result = newQVariant(item.image)
    of ModelRole.Color:
      result = newQVariant(item.color)
    of ModelRole.Type:
      result = newQVariant(item.itemType.int)
    of ModelRole.Customized:
      result = newQVariant(item.customized)
    of ModelRole.MuteAllMessages:
      result = newQVariant(item.muteAllMessages)
    of ModelRole.PersonalMentions:
      result = newQVariant(item.personalMentions)
    of ModelRole.GlobalMentions:
      result = newQVariant(item.globalMentions)
    of ModelRole.OtherMessages:
      result = newQVariant(item.otherMessages)

  proc addItem*(self: Model, item: Item) =
    # add most recent item on top
    var position = -1
    for i in 0 ..< self.items.len:
      if(item.joinedTimestamp >= self.items[i].joinedTimestamp):
        position = i
        break

    if(position == -1):
      position = self.items.len

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, position, position)
    self.items.insert(item, position)
    self.endInsertRows()
    self.countChanged()

  proc setItems*(self: Model, items: seq[Item]) =
    if(items.len == 0):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, 0, items.len - 1)
    self.items = items
    self.endInsertRows()
    self.countChanged()

  proc findIndexForItemId*(self: Model, id: string): int =
    var ind = 0
    for it in self.items:
      if(it.id == id):
        return ind
      ind.inc
    return -1

  proc removeItemById*(self: Model, id: string) =
    let ind = self.findIndexForItemId(id)
    if(ind == -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()

    self.countChanged()

  iterator modelIterator*(self: Model): Item =
    for i in 0 ..< self.items.len:
      yield self.items[i]

  proc updateExemptions*(self: Model, id: string, muteAllMessages = false, personalMentions = VALUE_NOTIF_SEND_ALERTS, 
    globalMentions = VALUE_NOTIF_SEND_ALERTS, otherMessages = VALUE_NOTIF_TURN_OFF) =
    let ind = self.findIndexForItemId(id)
    if(ind == -1):
      return

    self.items[ind].muteAllMessages = muteAllMessages
    self.items[ind].personalMentions = personalMentions
    self.items[ind].globalMentions = globalMentions
    self.items[ind].otherMessages = otherMessages

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, @[ModelRole.MuteAllMessages.int, ModelRole.PersonalMentions.int,
      ModelRole.GlobalMentions.int, ModelRole.OtherMessages.int, ModelRole.Customized.int])

  proc updateName*(self: Model, id: string, name: string) =
    let ind = self.findIndexForItemId(id)
    if(ind == -1):
      return

    self.items[ind].name = name

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, @[ModelRole.Name.int])