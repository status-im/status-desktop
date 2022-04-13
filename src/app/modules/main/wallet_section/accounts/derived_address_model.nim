import NimQml, Tables, strutils, strformat

import ./derived_address_item

type
  ModelRole {.pure.} = enum
    Address = UserRole + 1,
    Path,
    HasActivity,
    AlreadyCreated,

QtObject:
  type
    DerivedAddressModel* = ref object of QAbstractListModel
      derivedWalletAddresses: seq[DerivedAddressItem]

  proc delete(self: DerivedAddressModel) =
    self.derivedWalletAddresses = @[]
    self.QAbstractListModel.delete

  proc setup(self: DerivedAddressModel) =
    self.QAbstractListModel.setup

  proc newDerivedAddressModel*(): DerivedAddressModel =
    new(result, delete)
    result.setup

  proc `$`*(self: DerivedAddressModel): string =
    for i in 0 ..< self.derivedWalletAddresses.len:
      result &= fmt"""[{i}]:({$self.derivedWalletAddresses[i]})"""

  proc countChanged(self: DerivedAddressModel) {.signal.}

  proc getCount(self: DerivedAddressModel): int {.slot.} =
    self.derivedWalletAddresses.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: DerivedAddressModel, index: QModelIndex = nil): int =
    return self.derivedWalletAddresses.len

  method roleNames(self: DerivedAddressModel): Table[int, string] =
    {
      ModelRole.Address.int: "address",
      ModelRole.Path.int: "path",
      ModelRole.HasActivity.int: "hasActivity",
      ModelRole.AlreadyCreated.int: "alreadyCreated"
    }.toTable

  method data(self: DerivedAddressModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.derivedWalletAddresses.len):
      return

    let item = self.derivedWalletAddresses[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Address:
      result = newQVariant(item.getAddress())
    of ModelRole.Path:
      result = newQVariant(item.getPath())
    of ModelRole.HasActivity:
      result = newQVariant(item.getHasActivity())
    of ModelRole.AlreadyCreated:
      result = newQVariant(item.getAlreadyCreated())

  proc setItems*(self: DerivedAddressModel, items: seq[DerivedAddressItem]) =
    self.beginResetModel()
    self.derivedWalletAddresses = items
    self.endResetModel()
    self.countChanged()

  proc getDerivedAddressAtIndex*(self: DerivedAddressModel, index: int): string =
    if (index < 0 or index > self.getCount()):
      return
    let item = self.derivedWalletAddresses[index]
    result = item.getAddress()


  proc getDerivedAddressPathAtIndex*(self: DerivedAddressModel, index: int): string =
    if (index < 0 or index > self.getCount()):
      return
    let item = self.derivedWalletAddresses[index]
    result = item.getPath()


  proc getDerivedAddressHasActivityAtIndex*(self: DerivedAddressModel, index: int): bool =
    if (index < 0 or index > self.getCount()):
      return
    let item = self.derivedWalletAddresses[index]
    result = item.getHasActivity()

  proc getDerivedAddressAlreadyCreatedAtIndex*(self: DerivedAddressModel, index: int): bool =
    if (index < 0 or index > self.getCount()):
      return
    let item = self.derivedWalletAddresses[index]
    result = item.getAlreadyCreated()

  proc getNextSelectableDerivedAddressIndex*(self: DerivedAddressModel): int =
    for i in 0 ..< self.derivedWalletAddresses.len:
      if(not self.derivedWalletAddresses[i].getAlreadyCreated()):
        return i
    return -1



