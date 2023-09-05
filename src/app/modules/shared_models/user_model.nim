import NimQml, Tables, strformat, sequtils, sugar
import user_item

import ../../../app_service/common/types

type
  ModelRole {.pure.} = enum
    PubKey = UserRole + 1
    DisplayName
    EnsName
    IsEnsVerified
    LocalNickname
    Alias
    Icon
    ColorId
    ColorHash
    OnlineStatus
    IsContact
    IsVerified
    IsUntrustworthy
    IsBlocked
    ContactRequest
    IncomingVerificationStatus
    OutgoingVerificationStatus

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[UserItem]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc countChanged(self: Model) {.signal.}
  proc itemChanged(self: Model, pubKey: string) {.signal.}

  proc setItems*(self: Model, items: seq[UserItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

    for item in items:
      self.itemChanged(item.pubKey)

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""User Model:
      [{i}]:({$self.items[i]})
      """

  proc getCount*(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int]count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.PubKey.int: "pubKey",
      ModelRole.DisplayName.int: "displayName",
      ModelRole.EnsName.int: "ensName",
      ModelRole.IsEnsVerified.int: "isEnsVerified",
      ModelRole.LocalNickname.int: "localNickname",
      ModelRole.Alias.int: "alias",
      ModelRole.Icon.int: "icon",
      ModelRole.ColorId.int: "colorId",
      ModelRole.ColorHash.int: "colorHash",
      ModelRole.OnlineStatus.int: "onlineStatus",
      ModelRole.IsContact.int: "isContact",
      ModelRole.IsVerified.int: "isVerified",
      ModelRole.IsUntrustworthy.int: "isUntrustworthy",
      ModelRole.IsBlocked.int: "isBlocked",
      ModelRole.ContactRequest.int: "contactRequest",
      ModelRole.IncomingVerificationStatus.int: "incomingVerificationStatus",
      ModelRole.OutgoingVerificationStatus.int: "outgoingVerificationStatus",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.PubKey:
      result = newQVariant(item.pubKey)
    of ModelRole.DisplayName:
      result = newQVariant(item.displayName)
    of ModelRole.EnsName:
      result = newQVariant(item.ensName)
    of ModelRole.IsEnsVerified:
      result = newQVariant(item.isEnsVerified)
    of ModelRole.LocalNickname:
      result = newQVariant(item.localNickname)
    of ModelRole.Alias:
      result = newQVariant(item.alias)
    of ModelRole.Icon:
      result = newQVariant(item.icon)
    of ModelRole.ColorId:
      result = newQVariant(item.colorId)
    of ModelRole.ColorHash:
      result = newQVariant(item.colorHash)
    of ModelRole.OnlineStatus:
      result = newQVariant(item.onlineStatus.int)
    of ModelRole.IsContact:
      result = newQVariant(item.isContact)
    of ModelRole.IsVerified:
      result = newQVariant(item.isVerified)
    of ModelRole.IsUntrustworthy:
      result = newQVariant(item.isUntrustworthy)
    of ModelRole.IsBlocked:
      result = newQVariant(item.isBlocked)
    of ModelRole.ContactRequest:
      result = newQVariant(item.contactRequest.int)
    of ModelRole.IncomingVerificationStatus:
      result = newQVariant(item.incomingVerificationStatus.int)
    of ModelRole.OutgoingVerificationStatus:
      result = newQVariant(item.outgoingVerificationStatus.int)

  proc addItems*(self: Model, items: seq[UserItem]) =
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

    for item in items:
      self.itemChanged(item.pubKey)

  proc addItem*(self: Model, item: UserItem) =
    # we need to maintain online contact on top, that means
    # if we add an item online status we add it as the last online item (before the first offline item)
    # if we add an item with offline status we add it as the first offline item (after the last online item)
    var position = -1
    for i in 0 ..< self.items.len:
      if(self.items[i].onlineStatus == OnlineStatus.Inactive):
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
    self.itemChanged(item.pubKey)

  proc clear*(self: Model) =
     self.beginResetModel()
     self.items = @[]
     self.endResetModel()

  proc findIndexByPubKey(self: Model, pubKey: string): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].pubKey == pubKey):
        return i

    return -1

  proc removeItemWithIndex(self: Model, index: int) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, index, index)
    let pubKey = self.items[index].pubKey
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()

    self.itemChanged(pubKey)

# TODO: rename to `containsItem`
  proc isContactWithIdAdded*(self: Model, id: string): bool =
    return self.findIndexByPubKey(id) != -1

  proc setName*(self: Model, pubKey: string, displayName: string,
      ensName: string, localNickname: string) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    self.items[ind].displayName = displayName
    self.items[ind].ensName = ensName
    self.items[ind].localNickname = localNickname

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, @[
      ModelRole.DisplayName.int,
      ModelRole.EnsName.int,
      ModelRole.LocalNickname.int,
      ])
    self.itemChanged(pubKey)

  proc setIcon*(self: Model, pubKey: string, icon: string) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    self.items[ind].icon = icon

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, @[ModelRole.Icon.int])
    self.itemChanged(pubKey)

  proc updateItem*(
      self: Model,
      pubKey: string,
      displayName: string,
      ensName: string,
      isEnsVerified: bool,
      localNickname: string,
      alias: string,
      icon: string,
      isUntrustworthy: bool = false,
      ) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    self.items[ind].displayName = displayName
    self.items[ind].ensName = ensName
    self.items[ind].isEnsVerified = isEnsVerified
    self.items[ind].localNickname = localNickname
    self.items[ind].alias = alias
    self.items[ind].icon = icon
    self.items[ind].isUntrustworthy = isUntrustworthy

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, @[
      ModelRole.DisplayName.int,
      ModelRole.EnsName.int,
      ModelRole.IsEnsVerified.int,
      ModelRole.LocalNickname.int,
      ModelRole.Alias.int,
      ModelRole.Icon.int,
      ModelRole.IsUntrustworthy.int,
    ])
    self.itemChanged(pubKey)

  proc updateIncomingRequestStatus*(
      self: Model,
      pubKey: string,
      requestStatus: VerificationRequestStatus
      ) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    self.items[ind].incomingVerificationStatus = requestStatus

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, @[
      ModelRole.IncomingVerificationStatus.int
    ])
    self.itemChanged(pubKey)

  proc updateTrustStatus*(self: Model, pubKey: string, isUntrustworthy: bool) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    let first = self.createIndex(ind, 0, nil)
    let last = self.createIndex(ind, 0, nil)
    defer: first.delete
    defer: last.delete
    self.items[ind].isUntrustworthy = isUntrustworthy
    self.dataChanged(first, last, @[ModelRole.IsUntrustworthy.int])
    self.itemChanged(pubKey)

  proc setOnlineStatus*(self: Model, pubKey: string,
      onlineStatus: OnlineStatus) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    if(self.items[ind].onlineStatus == onlineStatus):
      return

    var item = self.items[ind]
    item.onlineStatus = onlineStatus
    self.removeItemWithIndex(ind)
    self.addItem(item)

# TODO: rename me to removeItemByPubkey
  proc removeItemById*(self: Model, pubKey: string) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    self.removeItemWithIndex(ind)

# TODO: rename me to getItemsAsPubkeys
  proc getItemIds*(self: Model): seq[string] =
    return self.items.map(i => i.pubKey)

  proc containsItemWithPubKey*(self: Model, pubKey: string): bool =
    return self.findIndexByPubKey(pubKey) != -1
