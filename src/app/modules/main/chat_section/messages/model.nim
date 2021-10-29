import NimQml, Tables, strutils, strformat

import item

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
      # ModelRole.GapTo.int:"gapTo"
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