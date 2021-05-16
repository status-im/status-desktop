import NimQml, Tables
import ../../../status/chat/[chat, message]
import ../../../status/status
import ../../../status/ens
import ../../../status/accounts
import strutils

type
  CategoryRoles {.pure.} = enum
    Id = UserRole + 1
    Name = UserRole + 2
    Position = UserRole + 3

QtObject:
  type
    CategoryList* = ref object of QAbstractListModel
      categories*: seq[CommunityCategory]
      status: Status

  proc setup(self: CategoryList) = self.QAbstractListModel.setup

  proc delete(self: CategoryList) = 
    self.categories = @[]
    self.QAbstractListModel.delete

  proc newCategoryList*(status: Status): CategoryList =
    new(result, delete)
    result.categories = @[]
    result.status = status
    result.setup()

  method rowCount*(self: CategoryList, index: QModelIndex = nil): int = self.categories.len

  method data(self: CategoryList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.categories.len:
      return
    let catItem = self.categories[index.row]
    let catItemRole = role.CategoryRoles
    case catItemRole:
      of CategoryRoles.Id: result = newQVariant(catItem.id)
      of CategoryRoles.Name: result = newQVariant(catItem.name)
      of CategoryRoles.Position: result = newQVariant(catItem.position)

  method roleNames(self: CategoryList): Table[int, string] =
    {
      CategoryRoles.Name.int:"name",
      CategoryRoles.Position.int:"position",
      CategoryRoles.Id.int: "categoryId"
    }.toTable

  proc setCategories*(self: CategoryList, categories: seq[CommunityCategory]) =
    self.beginResetModel()
    self.categories = categories
    self.endResetModel()

  proc addCategoryToList*(self: CategoryList, category: CommunityCategory): int =
    self.beginInsertRows(newQModelIndex(), 0, 0)
    self.categories.insert(category, 0)
    self.endInsertRows()
    result = self.categories.len

  proc removeCategoryFromList*(self: CategoryList, categoryId: string): int =
    let idx = self.categories.findIndexById(categoryId)
    if idx == -1: return
    self.beginRemoveRows(newQModelIndex(), idx, idx)
    self.categories.delete(idx)
    self.endRemoveRows()
    result = self.categories.len
