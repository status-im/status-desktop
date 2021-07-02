import NimQml, Tables, std/wrapnils
import ../../../status/chat/chat

QtObject:
  type CategoryItemView* = ref object of QObject
    categoryItem*: CommunityCategory

  proc setup(self: CategoryItemView) =
    self.QObject.setup

  proc delete*(self: CategoryItemView) =
    self.QObject.delete

  proc newCategoryItemView*(): CategoryItemView =
    new(result, delete)
    result = CategoryItemView()
    result.setup

  proc setCategoryItem*(self: CategoryItemView, categoryItem: CommunityCategory) =
    self.categoryItem = categoryItem

  proc id*(self: CategoryItemView): string {.slot.} = result = ?.self.categoryItem.id

  QtProperty[string] id:
    read = id

  proc name*(self: CategoryItemView): string {.slot.} = result = ?.self.categoryItem.name

  QtProperty[string] name:
    read = name
