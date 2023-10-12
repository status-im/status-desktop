import NimQml, strformat, tables, sequtils, chronicles
import ./link_preview_item
import ../../../app_service/service/message/dto/link_preview
import ../../../app_service/service/message/dto/standard_link_preview
import ../../../app_service/service/message/dto/status_link_preview
import ../../../app_service/service/message/dto/status_contact_link_preview
import ../../../app_service/service/message/dto/status_community_link_preview
import ../../../app_service/service/message/dto/status_community_channel_link_preview

type
  ModelRole {.pure.} = enum
    Url = UserRole + 1
    Unfurled
    Immutable
    Empty
    PreviewType
    # Standard unfurled link (oembed, opengraph, image)
    StandardPreview
    StandardPreviewThumbnail
    # Status contact
    StatusContactPreview
    StatusContactPreviewThumbnail
    # Status community
    StatusCommunityPreview
    StatusCommunityPreviewIcon
    StatusCommunityPreviewBanner
    # Status channel
    StatusCommunityChannelPreview
    # NOTE: I know "CommunityChannelCommunity" doesn't sound good, 
    # and we could use existing `StatusCommunityPreview` role for this,
    # but I decided no to mess things around. So there we have it:
    StatusCommunityChannelCommunityPreview 
    StatusCommunityChannelCommunityPreviewIcon
    StatusCommunityChannelCommunityPreviewBanner

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
      ModelRole.Empty.int:"empty",
      ModelRole.PreviewType.int:"previewType",
      # Standard
      ModelRole.StandardPreview.int:"standardPreview",
      ModelRole.StandardPreviewThumbnail.int:"standardPreviewThumbnail",
      # Contact
      ModelRole.StatusContactPreview.int:"statusContactPreview",
      ModelRole.StatusContactPreviewThumbnail.int:"statusContactPreviewThumbnail",
      # Community
      ModelRole.StatusCommunityPreview.int:"statusCommunityPreview",
      ModelRole.StatusCommunityPreviewIcon.int:"statusCommunityPreviewIcon",
      ModelRole.StatusCommunityPreviewBanner.int:"statusCommunityPreviewBanner",
      # Channel
      ModelRole.StatusCommunityChannelPreview.int:"statusCommunityChannelPreview",
      ModelRole.StatusCommunityChannelCommunityPreview.int:"statusCommunityChannelCommunityPreview",
      ModelRole.StatusCommunityChannelCommunityPreviewIcon.int:"statusCommunityChannelCommunityPreviewIcon",
      ModelRole.StatusCommunityChannelCommunityPreviewBanner.int:"statusCommunityChannelCommunityPreviewBanner",
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
    of ModelRole.Empty:
      result = newQVariant(item.linkPreview.empty()) 
    of ModelRole.PreviewType:
      result = newQVariant(item.linkPreview.previewType.int)
    of ModelRole.StandardPreview:
      if item.linkPreview.standardPreview != nil:
        result = newQVariant(item.linkPreview.standardPreview)
    of ModelRole.StandardPreviewThumbnail:
      if item.linkPreview.standardPreview != nil:
        result = newQVariant(item.linkPreview.standardPreview.getThumbnail())
    of ModelRole.StatusContactPreview:
      if item.linkPreview.statusContactPreview != nil:
        result = newQVariant(item.linkPreview.statusContactPreview)
    of ModelRole.StatusContactPreviewThumbnail:
      if item.linkPreview.statusContactPreview != nil:
        result = newQVariant(item.linkPreview.statusContactPreview.getIcon())
    of ModelRole.StatusCommunityPreview:
      if item.linkPreview.statusCommunityPreview != nil:
        result = newQVariant(item.linkPreview.statusCommunityPreview)
    of ModelRole.StatusCommunityPreviewIcon:
      if item.linkPreview.statusCommunityPreview != nil:
        result = newQVariant(item.linkPreview.statusCommunityPreview.getIcon())
    of ModelRole.StatusCommunityPreviewBanner:
      if item.linkPreview.statusCommunityPreview != nil:
        result = newQVariant(item.linkPreview.statusCommunityPreview.getBanner())
    of ModelRole.StatusCommunityChannelPreview:
      if item.linkPreview.statusCommunityChannelPreview != nil:
        result = newQVariant(item.linkPreview.statusCommunityChannelPreview)
    of ModelRole.StatusCommunityChannelCommunityPreview:
      if (let community = item.getChannelCommunity(); community) != nil:
        result = newQVariant(community)
    of ModelRole.StatusCommunityChannelCommunityPreviewIcon:
      if (let community = item.getChannelCommunity(); community) != nil:
        result = newQVariant(community.getIcon())
    of ModelRole.StatusCommunityChannelCommunityPreviewBanner:
      if (let community = item.getChannelCommunity(); community) != nil:
        result = newQVariant(community.getBanner())
    else:
      result = newQVariant()

  proc removeItemWithIndex(self: Model, ind: int) =
    if(ind < 0 or ind >= self.items.len):
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

  proc moveRow(self: Model, fromRow: int, to: int) =
    if fromRow == to:
      return
    if fromRow < 0 or fromRow >= self.items.len:
      return
    if to < 0 or to >= self.items.len:
      return

    let sourceIndex = newQModelIndex()
    defer: sourceIndex.delete
    let destIndex = newQModelIndex()
    defer: destIndex.delete

    let currentItem = self.items[fromRow]
    self.beginMoveRows(sourceIndex, fromRow, fromRow, destIndex, to)
    self.items.delete(fromRow)
    self.items.insert(currentItem, to)
    self.endMoveRows()

  proc updateLinkPreviews*(self: Model, linkPreviews: Table[string, LinkPreview]) =
    for row, item in self.items:
      if not linkPreviews.hasKey(item.linkPreview.url) or item.immutable:
        continue
      item.unfurled = true
      item.linkPreview = linkPreviews[item.linkPreview.url]
      debug "<<< updating link preview in model", linkPreview = $item.linkPreview
      let modelIndex = self.createIndex(row, 0, nil)
      defer: modelIndex.delete
      self.dataChanged(modelIndex, modelIndex)

  proc setUrls*(self: Model, urls: seq[string]) =
    var itemsToInsert: seq[Item]
    var indexesToRemove: seq[int]

    #remove
    for i in 0 ..< self.items.len:
      if not urls.anyIt(it == self.items[i].linkPreview.url):
        indexesToRemove.add(i)

    while indexesToRemove.len > 0:
      let index = pop(indexesToRemove)
      self.removeItemWithIndex(index)

    # Move or insert
    for i in 0 ..< urls.len:
      let index = self.findUrlIndex(urls[i])
      if index >= 0:
        self.moveRow(index, i)
        continue

      let linkPreview = initLinkPreview(urls[i])
      var item = Item()
      item.unfurled = false
      item.immutable = false
      item.linkPreview = linkPreview

      let parentModelIndex = newQModelIndex()
      defer: parentModelIndex.delete
      self.beginInsertRows(parentModelIndex, i, i)
      self.items.insert(item, i)
      self.endInsertRows()
      
    self.countChanged()

  proc clearItems*(self: Model) =
    self.beginResetModel()
    self.items = @[]
    self.endResetModel()
    self.countChanged()

  proc removePreviewData*(self: Model, index: int) {.slot.} =
    if index < 0 or index >= self.items.len:
      return

    self.items[index].linkPreview = initLinkPreview(self.items[index].linkPreview.url)
    self.items[index].unfurled = false
    self.items[index].immutable = true

    let modelIndex = self.createIndex(index, 0, nil)
    defer: modelIndex.delete
    self.dataChanged(modelIndex, modelIndex)

  proc removeAllPreviewData*(self: Model) {.slot.} =
    for i in 0 ..< self.items.len:
      self.removePreviewData(i)
      
  proc getUnfuledLinkPreviews*(self: Model): seq[LinkPreview] =
    result = @[]
    for item in self.items:
      if item.unfurled and not item.linkPreview.empty():
        result.add(item.linkPreview)

  proc getLinks*(self: Model): seq[string] =
    result = @[]
    for item in self.items:
      result.add(item.linkPreview.url)
