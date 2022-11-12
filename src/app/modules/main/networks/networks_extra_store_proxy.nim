import NimQml, Tables, strutils

import ./model

# Proxy data model for the Networks data model with additional role; see isActiveRoleName
# isEnabled values are copied from the original model into isActiveRoleName values
const isActiveRoleName = "isActive"

QtObject:
  type
    NetworksExtraStoreProxy* = ref object of QAbstractListModel
      sourceModel: Model
      activeNetworks: seq[bool]
      extraRole: tuple[roleId: int, roleName: string]

  proc delete(self: NetworksExtraStoreProxy) =
    self.sourceModel = nil
    self.activeNetworks = @[]
    self.QAbstractListModel.delete

  proc setup(self: NetworksExtraStoreProxy) =
    self.QAbstractListModel.setup

  proc updateActiveNetworks(self: NetworksExtraStoreProxy, sourceModel: Model) =
    var tmpSeq = newSeq[bool](sourceModel.rowCount())
    for i in 0 ..< sourceModel.rowCount():
      tmpSeq[i] = sourceModel.data(sourceModel.index(i, 0, newQModelIndex()), ModelRole.IsEnabled.int).boolVal()
    self.activeNetworks = tmpSeq

  proc newNetworksExtraStoreProxy*(sourceModel: Model): NetworksExtraStoreProxy =
    new(result, delete)

    result.sourceModel = sourceModel
    # assign past last role element
    result.extraRole = (0, isActiveRoleName)
    for k in sourceModel.roleNames().keys:
      if k > result.extraRole.roleId:
        result.extraRole.roleId = k
    result.extraRole.roleId += 1

    result.updateactiveNetworks(sourceModel)
    result.setup

    signalConnect(result.sourceModel, "countChanged()", result, "onCountChanged()")

  proc countChanged(self: NetworksExtraStoreProxy) {.signal.}

  # Nimqml doesn't support connecting signals to other signals
  proc onCountChanged(self: NetworksExtraStoreProxy) {.slot.} =
    self.updateActiveNetworks(self.sourceModel)
    self.countChanged()

  proc getCount(self: NetworksExtraStoreProxy): int {.slot.} =
    return self.sourceModel.rowCount()

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: NetworksExtraStoreProxy, index: QModelIndex = nil): int =
    return self.sourceModel.rowCount()

  method roleNames(self: NetworksExtraStoreProxy): Table[int, string] =
    var srcRoles = self.sourceModel.roleNames()
    srcRoles.add(self.extraRole.roleId, self.extraRole.roleName)
    return srcRoles

  method data(self: NetworksExtraStoreProxy, index: QModelIndex, role: int): QVariant =
    if role == self.extraRole.roleId:
      if index.row() < 0 or index.row() >= self.activeNetworks.len:
        return QVariant()
      return newQVariant(self.activeNetworks[index.row()])
    return self.sourceModel.data(index, role)

  method setData*(self: NetworksExtraStoreProxy, index: QModelIndex, value: QVariant, role: int): bool =
    if role == self.extraRole.roleId:
      if index.row() < 0 or index.row() >= self.activeNetworks.len:
        return false
      self.activeNetworks[index.row()] = value.boolVal()
      self.dataChanged(index, index, [self.extraRole.roleId])
      return true
    return self.sourceModel.setData(index, value, role)

  proc rowData(self: NetworksExtraStoreProxy, index: int, column: string): string {.slot.} =
    if column == isActiveRoleName:
      if index < 0 or index >= self.activeNetworks.len:
        return ""
      return $self.activeNetworks[index]
    return self.sourceModel.rowData(index, column)