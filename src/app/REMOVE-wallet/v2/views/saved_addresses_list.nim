import # std libs
  std/tables

import # vendor libs
  nimqml, status/types/address

type
  SavedAddressRoles {.pure.} = enum
    Name = UserRole + 1,
    Address = UserRole + 2

QtObject:
  type SavedAddressesList* = ref object of QAbstractListModel
    savedAddresses*: seq[SavedAddress]

  proc setup(self: SavedAddressesList) = self.QAbstractListModel.setup

  proc delete(self: SavedAddressesList) =
    self.savedAddresses = @[]
    self.QAbstractListModel.delete

  proc newSavedAddressesList*(): SavedAddressesList =
    new(result, delete)
    result.savedAddresses = @[]
    result.setup

  proc getSavedAddress*(self: SavedAddressesList, index: int): SavedAddress =
    self.savedAddresses[index]

  proc rowData(self: SavedAddressesList, index: int, column: string): string {.slot.} =
    if (index >= self.savedAddresses.len):
      return

    let savedAddress = self.savedAddresses[index]
    case column:
      of "name": result = savedAddress.name
      of "address": result = $savedAddress.address

  method rowCount*(self: SavedAddressesList, index: QModelIndex = nil): int =
    return self.savedAddresses.len

  method data(self: SavedAddressesList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return

    if index.row < 0 or index.row >= self.savedAddresses.len:
      return

    let savedAddress = self.savedAddresses[index.row]
    let collectionRole = role.SavedAddressRoles
    case collectionRole:
    of SavedAddressRoles.Name: result = newQVariant(savedAddress.name)
    of SavedAddressRoles.Address: result = newQVariant($savedAddress.address)

  method roleNames(self: SavedAddressesList): Table[int, string] =
    { SavedAddressRoles.Name.int:"name",
    SavedAddressRoles.Address.int:"address"}.toTable

  proc setData*(self: SavedAddressesList, savedAddresses: seq[SavedAddress]) =
    self.beginResetModel()
    self.savedAddresses = savedAddresses
    self.endResetModel()
