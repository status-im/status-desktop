import NimQml, Tables, strutils

import result_item

type
  MessageSearchResultModelRole {.pure.} = enum
    ItemId = UserRole + 1
    Content
    Time
    TitleId
    Title
    SectionName
    IsLetterIdenticon
    BadgeImage
    BadgePrimaryText
    BadgeSecondaryText
    BadgeIdenticonColor

QtObject:
  type
    MessageSearchResultModel* = ref object of QAbstractListModel
      resultList: seq[SearchResultItem]

  proc delete(self: MessageSearchResultModel) =
    self.QAbstractListModel.delete

  proc setup(self: MessageSearchResultModel) =
    self.QAbstractListModel.setup

  proc newMessageSearchResultModel*(): MessageSearchResultModel =
    new(result, delete)
    result.setup()

  #################################################
  # Properties
  #################################################
  
  proc countChanged*(self: MessageSearchResultModel) {.signal.}

  proc count*(self: MessageSearchResultModel): int {.slot.}  =
    self.resultList.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  method rowCount(self: MessageSearchResultModel, index: QModelIndex = nil): int =
    return self.resultList.len

  method roleNames(self: MessageSearchResultModel): Table[int, string] =
    {
      MessageSearchResultModelRole.ItemId.int:"itemId",
      MessageSearchResultModelRole.Content.int:"content",
      MessageSearchResultModelRole.Time.int:"time",
      MessageSearchResultModelRole.TitleId.int:"titleId",
      MessageSearchResultModelRole.Title.int:"title",
      MessageSearchResultModelRole.SectionName.int:"sectionName",
      MessageSearchResultModelRole.IsLetterIdenticon.int:"isLetterIdenticon",
      MessageSearchResultModelRole.BadgeImage.int:"badgeImage",
      MessageSearchResultModelRole.BadgePrimaryText.int:"badgePrimaryText",
      MessageSearchResultModelRole.BadgeSecondaryText.int:"badgeSecondaryText",
      MessageSearchResultModelRole.BadgeIdenticonColor.int:"badgeIdenticonColor"
    }.toTable

  method data(self: MessageSearchResultModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.resultList.len):
      return

    let item = self.resultList[index.row]
    let enumRole = role.MessageSearchResultModelRole

    case enumRole:
    of MessageSearchResultModelRole.ItemId: 
      result = newQVariant(item.getItemId)
    of MessageSearchResultModelRole.Content: 
      result = newQVariant(item.getContent)
    of MessageSearchResultModelRole.Time: 
      result = newQVariant(item.getTime)
    of MessageSearchResultModelRole.TitleId: 
      result = newQVariant(item.getTitleId)
    of MessageSearchResultModelRole.Title: 
      result = newQVariant(item.getTitle)
    of MessageSearchResultModelRole.SectionName: 
      result = newQVariant(item.getSectionName)
    of MessageSearchResultModelRole.IsLetterIdenticon: 
      result = newQVariant(item.getIsLetterIdentIcon)
    of MessageSearchResultModelRole.BadgeImage: 
      result = newQVariant(item.getBadgeImage)
    of MessageSearchResultModelRole.BadgePrimaryText: 
      result = newQVariant(item.getBadgePrimaryText)
    of MessageSearchResultModelRole.BadgeSecondaryText: 
      result = newQVariant(item.getBadgeSecondaryText)
    of MessageSearchResultModelRole.BadgeIdenticonColor: 
      result = newQVariant(item.getBadgeIdenticonColor)

  proc add*(self: MessageSearchResultModel, item: SearchResultItem) =
    self.beginInsertRows(newQModelIndex(), self.resultList.len, self.resultList.len)
    self.resultList.add(item)
    self.endInsertRows()

  proc set*(self: MessageSearchResultModel, items: seq[SearchResultItem]) =
    self.beginResetModel()
    self.resultList = items
    self.endResetModel()

  proc clear*(self: MessageSearchResultModel) =
    self.beginResetModel()
    self.resultList = @[]
    self.endResetModel()