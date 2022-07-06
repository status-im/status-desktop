import NimQml, Tables, strformat, sequtils, sugar

# TODO: use generics to remove duplication between user_model and member_model

import ../../../app_service/service/contacts/dto/contacts
import member_item

type
  ModelRole {.pure.} = enum
    PubKey = UserRole + 1
    DisplayName
    EnsName
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
    IsAdmin
    Joined

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[MemberItem]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc countChanged(self: Model) {.signal.}

  proc setItems*(self: Model, items: seq[MemberItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""Member Model:
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
      ModelRole.IsAdmin.int: "isAdmin",
      ModelRole.Joined.int: "joined",
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
    of ModelRole.IsAdmin:
      result = newQVariant(item.isAdmin)
    of ModelRole.Joined:
      result = newQVariant(item.joined)

  proc addItem*(self: Model, item: MemberItem) =
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

  proc findIndexForMessageId(self: Model, pubKey: string): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].pubKey == pubKey):
        return i

    return -1

  proc removeItemWithIndex(self: Model, index: int) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()

  proc isContactWithIdAdded*(self: Model, id: string): bool =
    return self.findIndexForMessageId(id) != -1

  proc setName*(self: Model, pubKey: string, displayName: string,
      ensName: string, localNickname: string) =
    let ind = self.findIndexForMessageId(pubKey)
    if(ind == -1):
      return

    self.items[ind].displayName = displayName
    self.items[ind].ensName = ensName
    self.items[ind].localNickname = localNickname

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[
      ModelRole.DisplayName.int,
      ModelRole.EnsName.int,
      ModelRole.LocalNickname.int,
      ])

  proc setIcon*(self: Model, pubKey: string, icon: string) =
    let ind = self.findIndexForMessageId(pubKey)
    if(ind == -1):
      return

    self.items[ind].icon = icon

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Icon.int])

  proc updateItem*(
      self: Model,
      pubKey: string,
      displayName: string,
      ensName: string,
      localNickname: string,
      alias: string,
      icon: string,
      isContact: bool,
      isAdmin: bool,
      joined: bool,
      isUntrustworthy: bool,
      ) =
    let ind = self.findIndexForMessageId(pubKey)
    if(ind == -1):
      return

    self.items[ind].displayName = displayName
    self.items[ind].ensName = ensName
    self.items[ind].localNickname = localNickname
    self.items[ind].alias = alias
    self.items[ind].icon = icon
    self.items[ind].isContact = isContact
    self.items[ind].isAdmin = isAdmin
    self.items[ind].joined = joined
    self.items[ind].isUntrustworthy = isUntrustworthy

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[
      ModelRole.DisplayName.int,
      ModelRole.EnsName.int,
      ModelRole.LocalNickname.int,
      ModelRole.Alias.int,
      ModelRole.Icon.int,
      ModelRole.IsContact.int,
      ModelRole.IsAdmin.int,
      ModelRole.Joined.int,
      ModelRole.IsUntrustworthy.int,
    ])

  proc updateItem*(
      self: Model,
      pubKey: string,
      displayName: string,
      ensName: string,
      localNickname: string,
      alias: string,
      icon: string,
      isContact: bool,
      isUntrustworthy: bool,
      ) =
    let ind = self.findIndexForMessageId(pubKey)
    if(ind == -1):
      return

    self.items[ind].displayName = displayName
    self.items[ind].ensName = ensName
    self.items[ind].localNickname = localNickname
    self.items[ind].alias = alias
    self.items[ind].icon = icon
    self.items[ind].isContact = isContact
    self.items[ind].isUntrustworthy = isUntrustworthy

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[
      ModelRole.DisplayName.int,
      ModelRole.EnsName.int,
      ModelRole.LocalNickname.int,
      ModelRole.Alias.int,
      ModelRole.Icon.int,
      ModelRole.IsContact.int,
      ModelRole.IsUntrustworthy.int,
    ])

  proc setOnlineStatus*(self: Model, pubKey: string,
      onlineStatus: OnlineStatus) =
    let ind = self.findIndexForMessageId(pubKey)
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
    let ind = self.findIndexForMessageId(pubKey)
    if(ind == -1):
      return

    self.removeItemWithIndex(ind)

# TODO: rename me to getItemsAsPubkeys
  proc getItemIds*(self: Model): seq[string] =
    return self.items.map(i => i.pubKey)
