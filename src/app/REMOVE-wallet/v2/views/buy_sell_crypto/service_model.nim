import NimQml, Tables

import service_item

type
  CryptoServiceModelRole {.pure.} = enum
    Name = UserRole + 1
    Description
    Fees
    LogoUrl
    SiteUrl
    Hostname

QtObject:
  type
    CryptoServiceModel* = ref object of QAbstractListModel
      list: seq[CryptoServiceItem]

  proc delete(self: CryptoServiceModel) =
    self.QAbstractListModel.delete

  proc setup(self: CryptoServiceModel) =
    self.QAbstractListModel.setup

  proc newCryptoServiceModel*(): CryptoServiceModel =
    new(result, delete)
    result.setup()

  method rowCount(self: CryptoServiceModel, index: QModelIndex = nil): int =
    return self.list.len

  method roleNames(self: CryptoServiceModel): Table[int, string] =
    {
      CryptoServiceModelRole.Name.int:"name",
      CryptoServiceModelRole.Description.int:"description",
      CryptoServiceModelRole.Fees.int:"fees",
      CryptoServiceModelRole.LogoUrl.int:"logoUrl",
      CryptoServiceModelRole.SiteUrl.int:"siteUrl",
      CryptoServiceModelRole.Hostname.int:"hostname"
    }.toTable

  method data(self: CryptoServiceModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.list.len):
      return

    let item = self.list[index.row]
    let enumRole = role.CryptoServiceModelRole

    case enumRole:
    of CryptoServiceModelRole.Name: 
      result = newQVariant(item.getName)
    of CryptoServiceModelRole.Description: 
      result = newQVariant(item.getDescription)
    of CryptoServiceModelRole.Fees: 
      result = newQVariant(item.getFees)
    of CryptoServiceModelRole.LogoUrl: 
      result = newQVariant(item.getLogoUrl)
    of CryptoServiceModelRole.SiteUrl: 
      result = newQVariant(item.getSiteUrl)
    of CryptoServiceModelRole.Hostname: 
      result = newQVariant(item.getHostname)

  proc set*(self: CryptoServiceModel, items: seq[CryptoServiceItem]) =
    self.beginResetModel()
    self.list = items
    self.endResetModel()