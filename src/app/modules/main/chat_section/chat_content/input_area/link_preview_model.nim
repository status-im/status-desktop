import NimQml, strformat, tables
import ./link_preview_item
import ../../../../../../app_service/service/message/dto/link_preview

type
  ModelRole {.pure.} = enum
    Url = UserRole + 1
    Unfurled
    Hostname
    Title
    Description
    ThumbnailWidth
    ThumbnailHeight
    ThumbnailUrl
    ThumbnailDataUri

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete*(self: Model) = 
    for i in 0 ..< self.items.len:
      self.items[i].delete
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newLinkPreviewModel*(): Model =
    new(result, delete)
    result.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc countChanged(self: Model) {.signal.}

  proc getCount*(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Url.int:"url",
      ModelRole.Unfurled.int:"unfurled",
      ModelRole.Hostname.int:"hostname",
      ModelRole.Title.int:"title",
      ModelRole.Description.int:"description",
      ModelRole.ThumbnailWidth.int:"thumbnailWidth",
      ModelRole.ThumbnailHeight.int:"thumbnailHeight",
      ModelRole.ThumbnailUrl.int:"thumbnailUrl",
      ModelRole.ThumbnailDataUri.int:"thumbnailDataUri",
    }.toTable

  method allLinkPreviewRoles(self: Model): seq[int] =
    return @[
      Unfurled.int,
      Hostname.int,
      Title.int,
      Description.int,
      ThumbnailWidth.int,
      ThumbnailHeight.int,
      ThumbnailUrl.int,
      ThumbnailDataUri.int,
    ]

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Url:
      result = newQVariant(item.linkPreview.url)
    of ModelRole.Unfurled:
      result = newQVariant(item.unfurled)
    of ModelRole.Hostname:
      result = newQVariant(item.linkPreview.hostname)
    of ModelRole.Title:
      result = newQVariant(item.linkPreview.title)
    of ModelRole.Description:
      result = newQVariant(item.linkPreview.description)
    of ModelRole.ThumbnailWidth:
      result = newQVariant(item.linkPreview.thumbnail.width)
    of ModelRole.ThumbnailHeight:
      result = newQVariant(item.linkPreview.thumbnail.height)
    of ModelRole.ThumbnailUrl:
      result = newQVariant(item.linkPreview.thumbnail.url)
    of ModelRole.ThumbnailDataUri:
      result = newQVariant(item.linkPreview.thumbnail.dataUri)
    
  proc clearItems*(self: Model) =
    self.beginResetModel()
    self.items = @[]
    self.endResetModel()
    self.countChanged()

  proc setUrls*(self: Model, urls: seq[string]) =
    var items: seq[Item]
    for url in urls:
      let linkPreview = initLinkPreview(url)
      var item = Item()
      item.unfurled = false
      item.linkPreview = linkPreview
      items.add(item)

    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc updateLinkPreviews*(self: Model, linkPreviews: Table[string, LinkPreview]) =
    for row, item in self.items:
      if not linkPreviews.hasKey(item.linkPreview.url):
        continue
      item.unfurled = true
      item.linkPreview = linkPreviews[item.linkPreview.url]
      let modelIndex = self.createIndex(row, 0, nil)
      defer: modelIndex.delete
      self.dataChanged(modelIndex, modelIndex, self.allLinkPreviewRoles())
