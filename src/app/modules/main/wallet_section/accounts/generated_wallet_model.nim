import NimQml, Tables, strutils, strformat

import ./generated_wallet_item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    IconName,
    GeneratedModel,
    DerivedFrom,
    KeyUid,
    MigratedToKeycard

QtObject:
  type
    GeneratedWalletModel* = ref object of QAbstractListModel
      generatedWalletItems: seq[GeneratedWalletItem]

  proc delete(self: GeneratedWalletModel) =
    self.generatedWalletItems = @[]
    self.QAbstractListModel.delete

  proc setup(self: GeneratedWalletModel) =
    self.QAbstractListModel.setup

  proc newGeneratedWalletModel*(): GeneratedWalletModel =
    new(result, delete)
    result.setup

  proc `$`*(self: GeneratedWalletModel): string =
    for i in 0 ..< self.generatedWalletItems.len:
      result &= fmt"""[{i}]:({$self.generatedWalletItems[i]})"""

  proc countChanged(self: GeneratedWalletModel) {.signal.}

  proc getCount(self: GeneratedWalletModel): int {.slot.} =
    self.generatedWalletItems.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: GeneratedWalletModel, index: QModelIndex = nil): int =
    return self.generatedWalletItems.len

  method roleNames(self: GeneratedWalletModel): Table[int, string] =
    {
      ModelRole.Name.int: "name",
      ModelRole.IconName.int: "iconName",
      ModelRole.GeneratedModel.int: "generatedModel",
      ModelRole.DerivedFrom.int: "derivedfrom",
      ModelRole.KeyUid.int: "keyUid",
      ModelRole.MigratedToKeycard.int: "migratedToKeycard"
    }.toTable

  method data(self: GeneratedWalletModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.generatedWalletItems.len):
      return

    let item = self.generatedWalletItems[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Name:
      result = newQVariant(item.getName())
    of ModelRole.IconName:
      result = newQVariant(item.getIconName())
    of ModelRole.GeneratedModel:
      result = newQVariant(item.getGeneratedModel())
    of ModelRole.DerivedFrom:
      result = newQVariant(item.getDerivedFrom())
    of ModelRole.KeyUid:
      result = newQVariant(item.getKeyUid())
    of ModelRole.MigratedToKeycard:
      result = newQVariant(item.getMigratedToKeycard())

  proc setItems*(self: GeneratedWalletModel, items: seq[GeneratedWalletItem]) =
    self.beginResetModel()
    self.generatedWalletItems = items
    self.endResetModel()
    self.countChanged()
