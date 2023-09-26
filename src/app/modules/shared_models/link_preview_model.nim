import NimQml, strformat, tables, sequtils
import ./link_preview_item
import ../../../app_service/service/message/dto/link_preview

type
  ModelRole {.pure.} = enum
    Url = UserRole + 1
    Unfurled
    Immutable
    Hostname
    Title
    Description
    LinkType
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

  proc newLinkPreviewModel*(linkPreviews: seq[LinkPreview] = @[]): Model =
    new(result, delete)
    result.setup
    for linkPreview in linkPreviews:
      var item = Item()
      item.unfurled = true
      item.linkPreview = linkPreview
      result.items.add(item)

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
      ModelRole.Immutable.int:"immutable",
      ModelRole.Hostname.int:"hostname",
      ModelRole.Title.int:"title",
      ModelRole.Description.int:"description",
      ModelRole.LinkType.int:"linkType",
      ModelRole.ThumbnailWidth.int:"thumbnailWidth",
      ModelRole.ThumbnailHeight.int:"thumbnailHeight",
      ModelRole.ThumbnailUrl.int:"thumbnailUrl",
      ModelRole.ThumbnailDataUri.int:"thumbnailDataUri",
    }.toTable

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
    of ModelRole.Immutable:
      result = newQVariant(item.immutable)
    of ModelRole.Hostname:
      result = newQVariant(item.linkPreview.hostname)
    of ModelRole.Title:
      result = newQVariant(item.linkPreview.title)
    of ModelRole.Description:
      result = newQVariant(item.linkPreview.description)
    of ModelRole.LinkType:
      result = newQVariant(item.linkPreview.linkType.int)
    of ModelRole.ThumbnailWidth:
      result = newQVariant(item.linkPreview.thumbnail.width)
    of ModelRole.ThumbnailHeight:
      result = newQVariant(item.linkPreview.thumbnail.height)
    of ModelRole.ThumbnailUrl:
      result = newQVariant(item.linkPreview.thumbnail.url)
    of ModelRole.ThumbnailDataUri:
      result = newQVariant(item.linkPreview.thumbnail.dataUri)

  proc urlExists(self: Model, url: string): bool =
    for it in self.items:
      if(it.linkPreview.url == url):
        return true
    return false

  proc urlExists(self: seq[string], url: string): bool =
    for it in self:
      if(it == url):
        return true
    return false

  proc removeItemWithIndex(self: Model, ind: int) =
    if(ind == -1 or ind >= self.items.len):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()

  proc getItemAtIndex*(self: Model, index: int): Item =
    if(index < 0 or index >= self.items.len):
      return
    return self.items[index]
  
  proc findUrlIndex(self: Model, url: string): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].linkPreview.url == url):
        return i
    return -1

  proc updateLinkPreviews*(self: Model, linkPreviews: Table[string, LinkPreview]) =
    for row, item in self.items:
      if not linkPreviews.hasKey(item.linkPreview.url) or item.immutable:
        continue
      item.unfurled = true
      item.linkPreview = linkPreviews[item.linkPreview.url]
      let modelIndex = self.createIndex(row, 0, nil)
      defer: modelIndex.delete
      self.dataChanged(modelIndex, modelIndex)

  proc setUrls*(self: Model, urls: seq[string]) =
    var itemsToInsert: seq[Item]
    var itemsToUpdate: Table[string, LinkPreview]
    var indexesToRemove: seq[int]

    #remove
    for i in 0 ..< self.items.len:
      if not urls.urlExists(self.items[i].linkPreview.url):
        indexesToRemove.add(i)

    while indexesToRemove.len > 0:
      let index = pop(indexesToRemove)
      self.removeItemWithIndex(index)
      
    self.countChanged()

    # Update or insert
    for url in urls:      
      let linkPreview = initLinkPreview(url)
      if(self.urlExists(url)):
        itemsToUpdate[url] = linkPreview
      else:
        var item = Item()
        item.unfurled = false
        item.immutable = false
        item.linkPreview = linkPreview
        itemsToInsert.add(item)

    #update
    if(itemsToUpdate.len > 0):
      self.updateLinkPreviews(itemsToUpdate)
      
    #insert
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len + itemsToInsert.len - 1)
    self.items = concat(self.items, itemsToInsert)
    self.endInsertRows()
    self.countChanged()

  proc clearItems*(self: Model) =
    self.beginResetModel()
    self.items = @[]
    self.endResetModel()
    self.countChanged()

  proc removePreviewData*(self: Model, link: string) =
    let index = self.findUrlIndex(link)
    if index < 0:
      return

    self.items[index].linkPreview = initLinkPreview(link)
    self.items[index].unfurled = false
    self.items[index].immutable = true

    let modelIndex = self.createIndex(index, 0, nil)
    defer: modelIndex.delete
    self.dataChanged(modelIndex, modelIndex)