import NimQml
import Tables
import sequtils
import ../../../../../app_service/service/settings/dto/network_details

type
  CustomNetworkRoles {.pure.} = enum
    Id = UserRole + 1,
    Name = UserRole + 2

QtObject:
  type CustomNetworkList* = ref object of QAbstractListModel
    list: seq[NetworkDetails]

  proc setup(self: CustomNetworkList) = self.QAbstractListModel.setup

  proc delete(self: CustomNetworkList) =
    self.QAbstractListModel.delete

  proc newCustomNetworkList*(): CustomNetworkList =
    new(result, delete)
    result.setup

  proc setCustomNetworks*(self: CustomNetworkList, list: seq[NetworkDetails]) =
    self.beginResetModel()
    self.list = list
    self.endResetModel()

  method rowCount(self: CustomNetworkList, index: QModelIndex = nil): int =
    return self.list.len

  method data(self: CustomNetworkList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return

    if index.row < 0 or index.row >= self.list.len:
      return
    let network = self.list[index.row]
    case role.CustomNetworkRoles:
      of CustomNetworkRoles.Id: result = newQVariant(network.id)
      of CustomNetworkRoles.Name: result = newQVariant(network.name)

  method roleNames(self: CustomNetworkList): Table[int, string] =
    {
      CustomNetworkRoles.Id.int:"customNetworkId",
      CustomNetworkRoles.Name.int:"name",
    }.toTable

  proc addCustomNetwork*(self: CustomNetworkList, name: string, id: int) =
    self.beginInsertRows(newQModelIndex(), self.list.len, self.list.len)
    self.list.add(NetworkDetails(
      id: $id,
      name: name
    ))
    self.endInsertRows()