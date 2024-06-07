import NimQml, Tables

import item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1
    Description
    Fees
    LogoUrl
    SiteUrl
    Hostname
    RecurrentSiteUrl

QtObject:
  type
    Model* = ref object of QAbstractListModel
      list: seq[Item]

  proc delete(self: Model) =
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup()

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.list.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Name.int:"name",
      ModelRole.Description.int:"description",
      ModelRole.Fees.int:"fees",
      ModelRole.LogoUrl.int:"logoUrl",
      ModelRole.SiteUrl.int:"siteUrl",
      ModelRole.Hostname.int:"hostname",
      ModelRole.RecurrentSiteUrl.int:"recurrentSiteUrl"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.list.len):
      return

    let item = self.list[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Name:
      result = newQVariant(item.getName)
    of ModelRole.Description:
      result = newQVariant(item.getDescription)
    of ModelRole.Fees:
      result = newQVariant(item.getFees)
    of ModelRole.LogoUrl:
      result = newQVariant(item.getLogoUrl)
    of ModelRole.SiteUrl:
      result = newQVariant(item.getSiteUrl)
    of ModelRole.Hostname:
      result = newQVariant(item.getHostname)
    of ModelRole.RecurrentSiteUrl:
      result = newQVariant(item.getRecurrentSiteUrl)

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.list = items
    self.endResetModel()
