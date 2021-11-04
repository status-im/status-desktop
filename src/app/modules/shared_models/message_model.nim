import NimQml, Tables, json, strutils

import message_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    From
    Alias
    Identicon
    Seen
    OutgoingStatus
    Text
    Timestamp
    ContentType
    MessageType
    # StickerHash
    # StickerPack
    # Image
    # GapFrom
    # GapTo
    Pinned
    CountsForReactions

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.From.int:"from",
      ModelRole.Alias.int:"alias",
      ModelRole.Identicon.int:"identicon",
      ModelRole.Seen.int:"seen",
      ModelRole.OutgoingStatus.int:"outgoingStatus",
      ModelRole.Text.int:"text",
      ModelRole.Timestamp.int:"timestamp",
      ModelRole.ContentType.int:"contentType",
      ModelRole.MessageType.int:"messageType",
      # ModelRole.StickerHash.int:"stickerHash",
      # ModelRole.StickerPack.int:"stickerPack",
      # ModelRole.Image.int:"image",
      # ModelRole.GapFrom.int:"gapFrom",
      # ModelRole.GapTo.int:"gapTo",
      ModelRole.Pinned.int:"pinned",
      ModelRole.CountsForReactions.int:"countsForReactions",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Id: 
      result = newQVariant(item.id)
    of ModelRole.From: 
      result = newQVariant(item.`from`)
    of ModelRole.Alias: 
      result = newQVariant(item.alias)
    of ModelRole.Identicon: 
      result = newQVariant(item.identicon)
    of ModelRole.Seen: 
      result = newQVariant(item.seen)
    of ModelRole.OutgoingStatus: 
      result = newQVariant(item.outgoingStatus)
    of ModelRole.Text: 
      result = newQVariant(item.text)
    of ModelRole.Timestamp: 
      result = newQVariant(item.timestamp)
    of ModelRole.ContentType: 
      result = newQVariant(item.contentType.int)
    of ModelRole.MessageType: 
      result = newQVariant(item.messageType)
    # of ModelRole.StickerHash: 
    #   result = newQVariant(item.stickerHash)
    # of ModelRole.StickerPack: 
    #   result = newQVariant(item.stickerPack)
    # of ModelRole.Image: 
    #   result = newQVariant(item.image)
    # of ModelRole.GapFrom: 
    #   result = newQVariant(item.gapFrom)
    # of ModelRole.GapTo: 
    #   result = newQVariant(item.gapTo)
    of ModelRole.Pinned: 
      result = newQVariant(item.pinned)
    of ModelRole.CountsForReactions: 
      result = newQVariant($(%* item.getCountsForReactions))

  proc findIndexForMessageId(self: Model, messageId: string): int = 
    for i in 0 ..< self.items.len:
      if(self.items[i].id == messageId):
        return i

    return -1

  proc prependItems*(self: Model, items: seq[Item]) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let first = 0
    let last = items.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items = items & self.items
    self.endInsertRows()

  proc appendItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

  proc removeItem*(self: Model, messageId: string) =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()

  proc getItemWithMessageId*(self: Model, messageId: string): Item = 
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    return self.items[ind]

  proc addReaction*(self: Model, messageId: string, emojiId: int, name: string, reactionId: string) = 
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    self.items[ind].addReaction(emojiId, name, reactionId)
    
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.CountsForReactions.int])

  proc removeReaction*(self: Model, messageId: string, reactionId: string) = 
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    self.items[ind].removeReaction(reactionId)
    
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.CountsForReactions.int])

  proc getNamesForReaction*(self: Model, messageId: string, emojiId: int): seq[string] = 
    for i in 0 ..< self.items.len:
      if(self.items[i].id == messageId):
        return self.items[i].getNamesForReactions(emojiId)

  proc pinUnpinMessage*(self: Model, messageId: string, pin: bool) = 
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    self.items[ind].pinned = pin
    
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Pinned.int])