import NimQml, Tables


import ./io_interface

type
  ModelRole {.pure.} = enum
    # key = name
    Key = UserRole + 1
    Name
    UpdatedAt
    Source
    Version
    TokensCount

QtObject:
  type SourcesOfTokensModel* = ref object of QAbstractListModel
    delegate: io_interface.SourcesOfTokensModelDataSource

  proc setup(self: SourcesOfTokensModel) =
    self.QAbstractListModel.setup

  proc delete(self: SourcesOfTokensModel) =
    self.QAbstractListModel.delete

  proc newSourcesOfTokensModel*(delegate: io_interface.SourcesOfTokensModelDataSource): SourcesOfTokensModel =
    new(result, delete)
    result.setup
    result.delegate = delegate

  method rowCount(self: SourcesOfTokensModel, index: QModelIndex = nil): int =
    return self.delegate.getSourcesOfTokensList().len

  proc countChanged(self: SourcesOfTokensModel) {.signal.}
  proc getCount(self: SourcesOfTokensModel): int {.slot.} =
    return self.rowCount()
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method roleNames(self: SourcesOfTokensModel): Table[int, string] =
    {
      ModelRole.Key.int:"key",
      ModelRole.Name.int:"name",
      ModelRole.UpdatedAt.int:"updatedAt",
      ModelRole.Source.int:"source",
      ModelRole.Version.int:"version",
      ModelRole.TokensCount.int:"tokensCount",
    }.toTable

  method data(self: SourcesOfTokensModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.rowCount():
      return
    let item = self.delegate.getSourcesOfTokensList()[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Key:
        result = newQVariant(item.name)
      of ModelRole.Name:
        result = newQVariant(item.name)
      of ModelRole.UpdatedAt:
        result = newQVariant(item.updatedAt)
      of ModelRole.Source:
        result = newQVariant(item.source)
      of ModelRole.Version:
        result = newQVariant(item.version)
      of ModelRole.TokensCount:
        result = newQVariant(item.tokensCount)

  proc modelsAboutToUpdate*(self: SourcesOfTokensModel) =
      self.beginResetModel()

  proc modelsUpdated*(self: SourcesOfTokensModel) =
      self.endResetModel()
