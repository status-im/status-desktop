import NimQml, Tables, stew/shims/strformat, sequtils, sugar
import user_item

import ../../../app_service/common/types
import ../../../app_service/service/accounts/utils
import contacts_utils
import model_utils

type
  ModelRole {.pure.} = enum
    PubKey = UserRole + 1
    CompressedPubKey
    DisplayName
    PreferredDisplayName
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
    IsCurrentUser
    LastUpdated
    LastUpdatedLocally
    Bio
    ThumbnailImage
    LargeImage
    IsContactRequestReceived
    IsContactRequestSent
    IsRemoved
    TrustStatus

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
      ModelRole.CompressedPubKey.int: "compressedPubKey",
      ModelRole.DisplayName.int: "displayName",
      ModelRole.PreferredDisplayName.int: "preferredDisplayName",
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
      ModelRole.IsCurrentUser.int: "isCurrentUser",
      ModelRole.LastUpdated.int: "lastUpdated",
      ModelRole.LastUpdatedLocally.int: "lastUpdatedLocally",
      ModelRole.Bio.int: "bio",
      ModelRole.ThumbnailImage.int: "thumbnailImage",
      ModelRole.LargeImage.int: "largeImage",
      ModelRole.IsContactRequestReceived.int: "isContactRequestReceived",
      ModelRole.IsContactRequestSent.int: "isContactRequestSent",
      ModelRole.IsRemoved.int: "isRemoved",
      ModelRole.TrustStatus.int: "trustStatus",
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
    of ModelRole.CompressedPubKey:
      result = newQVariant(compressPk(item.pubKey))
    of ModelRole.DisplayName:
      result = newQVariant(item.displayName)
    of ModelRole.PreferredDisplayName:
      return newQVariant(resolvePreferredDisplayName(
        item.localNickname, item.ensName, item.displayName, item.alias))
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
      result = newQVariant(not item.isCurrentUser and item.trustStatus == TrustStatus.Trusted)
    of ModelRole.IsUntrustworthy:
      result = newQVariant(not item.isCurrentUser and item.trustStatus == TrustStatus.Untrustworthy)
    of ModelRole.IsBlocked:
      result = newQVariant(item.isBlocked)
    of ModelRole.ContactRequest:
      result = newQVariant(item.contactRequest.int)
    of ModelRole.IsCurrentUser:
      result = newQVariant(item.isCurrentUser)
    of ModelRole.LastUpdated:
      result = newQVariant(item.lastUpdated)
    of ModelRole.LastUpdatedLocally:
      result = newQVariant(item.lastUpdatedLocally)
    of ModelRole.Bio:
      result = newQVariant(item.bio)
    of ModelRole.ThumbnailImage:
      result = newQVariant(item.thumbnailImage)
    of ModelRole.LargeImage:
      result = newQVariant(item.largeImage)
    of ModelRole.IsContactRequestReceived:
      result = newQVariant(item.isContactRequestReceived)
    of ModelRole.IsContactRequestSent:
      result = newQVariant(item.isContactRequestSent)
    of ModelRole.IsRemoved:
      result = newQVariant(item.isRemoved)
    of ModelRole.TrustStatus:
      result = newQVariant(item.trustStatus.int)
    else:
      result = newQVariant()

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
      if self.items[i].pubKey == pubKey:
        return i

    return -1

  proc getItemByPubKey*(self: Model, pubKey: string): UserItem =
    for item in self.items:
      if item.pubKey == pubKey:
        return item

  proc removeItemWithIndex(self: Model, index: int) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, index, index)
    let pubKey = self.items[index].pubKey
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()

    self.itemChanged(pubKey)

  proc isContactWithIdAdded*(self: Model, id: string): bool =
    return self.findIndexByPubKey(id) != -1

  proc setName*(self: Model, pubKey: string, displayName: string,
      ensName: string, localNickname: string) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    var roles: seq[int] = @[]

    let preferredDisplayNameChanged =
      resolvePreferredDisplayName(self.items[ind].localNickname, self.items[ind].ensName, self.items[ind].displayName, self.items[ind].alias) !=
      resolvePreferredDisplayName(localNickname, ensName, displayName, self.items[ind].alias)

    updateRole(displayName, DisplayName)
    updateRole(ensName, EnsName)
    updateRole(localNickname, LocalNickname)

    if preferredDisplayNameChanged:
      roles.add(ModelRole.PreferredDisplayName.int)

    if roles.len == 0:
      return

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, roles)
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
      trustStatus: TrustStatus,
    ) =
    let ind = self.findIndexByPubKey(pubKey)
    if ind == -1:
      return

    var roles: seq[int] = @[]

    let preferredDisplayNameChanged =
      resolvePreferredDisplayName(self.items[ind].localNickname, self.items[ind].ensName, self.items[ind].displayName, self.items[ind].alias) !=
      resolvePreferredDisplayName(localNickname, ensName, displayName, alias)

    let trustStatusChanged = trustStatus != self.items[ind].trustStatus

    updateRole(displayName, DisplayName)
    updateRole(ensName, EnsName)
    updateRole(localNickname, LocalNickname)
    updateRole(alias, Alias)
    updateRole(icon, Icon)
    updateRole(trustStatus, TrustStatus)

    if preferredDisplayNameChanged:
      roles.add(ModelRole.PreferredDisplayName.int)

    if trustStatusChanged:
      roles.add(ModelRole.IsUntrustworthy.int)
      roles.add(ModelRole.IsVerified.int)

    if roles.len == 0:
      return

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, roles)
    self.itemChanged(pubKey)

  proc updateTrustStatus*(self: Model, pubKey: string, trustStatus: TrustStatus) =
    let ind = self.findIndexByPubKey(pubKey)
    if ind == -1:
      return

    if self.items[ind].trustStatus == trustStatus:
      return

    self.items[ind].trustStatus = trustStatus

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, @[ModelRole.TrustStatus.int, ModelRole.IsUntrustworthy.int, ModelRole.IsVerified.int])
    self.itemChanged(pubKey)

  proc setOnlineStatus*(self: Model, pubKey: string, onlineStatus: OnlineStatus) =
    let ind = self.findIndexByPubKey(pubKey)
    if ind == -1:
      return

    if self.items[ind].onlineStatus == onlineStatus:
      return

    self.items[ind].onlineStatus = onlineStatus

    let index = self.createIndex(ind, 0, nil)
    defer: index.delete
    self.dataChanged(index, index, @[ModelRole.OnlineStatus.int])
    self.itemChanged(pubKey)


# TODO: rename me to removeItemByPubkey
  proc removeItemById*(self: Model, pubKey: string) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    self.removeItemWithIndex(ind)

# TODO: rename me to getItemsAsPubkeys
  proc getItemIds*(self: Model): seq[string] =
    return self.items.map(i => i.pubKey)
