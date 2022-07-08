import NimQml, Tables, json, strutils, strformat

import message_item, message_reaction_item, message_transaction_parameters_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    PrevMsgIndex
    NextMsgIndex
    CommunityId
    ResponseToMessageWithId
    SenderId
    SenderDisplayName
    SenderLocalName
    SenderIcon
    AmISender
    SenderIsAdded
    Seen
    OutgoingStatus
    MessageText
    MessageImage
    MessageContainsMentions # Actually we don't need to exposed this to qml since we only used it as an improved way to
                            # check whether we need to update mentioned contact name or not.
    Timestamp
    ContentType
    MessageType
    Sticker
    StickerPack
    GapFrom
    GapTo
    Pinned
    PinnedBy
    Reactions
    EditMode
    IsEdited
    Links
    TransactionParameters
    MentionedUsersPks
    SenderTrustStatus

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items*: seq[Item]
      allKeys: seq[int]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

    # This is just a clean way to have all roles in a seq, without typing long seq manualy, and this way we're sure that
    # all new added roles will be included here as well.
    for i in result.roleNames().keys:
      result.allKeys.add(i)

  proc `$`*(self: Model): string =
    result = "MessageModel:\n"
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc countChanged(self: Model) {.signal.}
  proc getCount(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.PrevMsgIndex.int:"prevMsgIndex",
      ModelRole.NextMsgIndex.int:"nextMsgIndex",
      ModelRole.CommunityId.int:"communityId",
      ModelRole.ResponseToMessageWithId.int:"responseToMessageWithId",
      ModelRole.SenderId.int:"senderId",
      ModelRole.SenderDisplayName.int:"senderDisplayName",
      ModelRole.SenderLocalName.int:"senderLocalName",
      ModelRole.SenderIcon.int:"senderIcon",
      ModelRole.AmISender.int:"amISender",
      ModelRole.SenderIsAdded.int:"senderIsAdded",
      ModelRole.Seen.int:"seen",
      ModelRole.OutgoingStatus.int:"outgoingStatus",
      ModelRole.MessageText.int:"messageText",
      ModelRole.MessageImage.int:"messageImage",
      ModelRole.MessageContainsMentions.int:"messageContainsMentions",
      ModelRole.Timestamp.int:"timestamp",
      ModelRole.ContentType.int:"contentType",
      ModelRole.MessageType.int:"messageType",
      ModelRole.Sticker.int:"sticker",
      ModelRole.StickerPack.int:"stickerPack",
      ModelRole.GapFrom.int:"gapFrom",
      ModelRole.GapTo.int:"gapTo",
      ModelRole.Pinned.int:"pinned",
      ModelRole.PinnedBy.int:"pinnedBy",
      ModelRole.Reactions.int:"reactions",
      ModelRole.EditMode.int: "editMode",
      ModelRole.IsEdited.int: "isEdited",
      ModelRole.Links.int: "links",
      ModelRole.TransactionParameters.int: "transactionParameters",
      ModelRole.MentionedUsersPks.int: "mentionedUsersPks",
      ModelRole.SenderTrustStatus.int: "senderTrustStatus"
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
    of ModelRole.PrevMsgIndex:
      result = newQVariant(index.row + 1)
    of ModelRole.NextMsgIndex:
      result = newQVariant(index.row - 1)
    of ModelRole.CommunityId:
      result = newQVariant(item.communityId)
    of ModelRole.ResponseToMessageWithId:
      result = newQVariant(item.responseToMessageWithId)
    of ModelRole.SenderId:
      result = newQVariant(item.senderId)
    of ModelRole.SenderDisplayName:
      result = newQVariant(item.senderDisplayName)
    of ModelRole.SenderTrustStatus:
      result = newQVariant(item.senderTrustStatus.int)
    of ModelRole.SenderLocalName:
      result = newQVariant(item.senderLocalName)
    of ModelRole.SenderIcon:
      result = newQVariant(item.senderIcon)
    of ModelRole.AmISender:
      result = newQVariant(item.amISender)
    of ModelRole.SenderIsAdded:
      result = newQVariant(item.senderIsAdded)
    of ModelRole.Seen:
      result = newQVariant(item.seen)
    of ModelRole.OutgoingStatus:
      result = newQVariant(item.outgoingStatus)
    of ModelRole.MessageText:
      result = newQVariant(item.messageText)
    of ModelRole.MessageImage:
      result = newQVariant(item.messageImage)
    of ModelRole.MessageContainsMentions:
      result = newQVariant(item.messageContainsMentions)
    of ModelRole.Timestamp:
      result = newQVariant(item.timestamp)
    of ModelRole.ContentType:
      result = newQVariant(item.contentType.int)
    of ModelRole.MessageType:
      result = newQVariant(item.messageType)
    of ModelRole.Sticker:
      result = newQVariant(item.sticker)
    of ModelRole.StickerPack:
      result = newQVariant(item.stickerPack)
    of ModelRole.GapFrom:
      result = newQVariant(item.gapFrom)
    of ModelRole.GapTo:
      result = newQVariant(item.gapTo)
    of ModelRole.Pinned:
      result = newQVariant(item.pinned)
    of ModelRole.PinnedBy:
      result = newQVariant(item.pinnedBy)
    of ModelRole.Reactions:
      result = newQVariant(item.reactionsModel)
    of ModelRole.EditMode:
      result = newQVariant(item.editMode)
    of ModelRole.IsEdited:
      result = newQVariant(item.isEdited)
    of ModelRole.Links:
      result = newQVariant(item.links.join(" "))
    of ModelRole.TransactionParameters:
      result = newQVariant($(%*{
        "id": item.transactionParameters.id,
        "fromAddress": item.transactionParameters.fromAddress,
        "address": item.transactionParameters.address,
        "contract": item.transactionParameters.contract,
        "value": item.transactionParameters.value,
        "transactionHash": item.transactionParameters.transactionHash,
        "commandState": item.transactionParameters.commandState,
        "signature": item.transactionParameters.signature
      }))
    of ModelRole.MentionedUsersPks:
      result = newQVariant(item.mentionedUsersPks.join(" "))

  proc updateItemAtIndex(self: Model, index: int) =
    let ind = self.createIndex(index, 0, nil)
    self.dataChanged(ind, ind, self.allKeys)

  proc findIndexForMessageId*(self: Model, messageId: string): int =
    result = -1
    if messageId.len == 0:
      return
    for i in 0 ..< self.items.len:
      if(self.items[i].id == messageId):
        result = i
        return

  proc findIdsOfTheMessagesWhichRespondedToMessageWithId*(self: Model, messageId: string): seq[string] =
    for i in 0 ..< self.items.len:
      if(self.items[i].responseToMessageWithId == messageId):
        result.add(self.items[i].id)

  proc findIndexBasedOnTimestampToInsertTo(self: Model, timestamp: int64): int =
    for i in 0 ..< self.items.len:
      if(timestamp > self.items[i].timestamp):
        return i
    return 0

  proc filterExistingItems(self: Model, items: seq[Item]): seq[Item] =
    for item in items:
      if(self.findIndexForMessageId(item.id) < 0):
        result &= item

  proc prependItems*(self: Model, items: seq[Item]) =
    let itemsToAppend = self.filterExistingItems(items)
    if(itemsToAppend.len == 0):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let first = 0
    let last = itemsToAppend.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items = itemsToAppend & self.items
    self.endInsertRows()
    self.countChanged()

  proc appendItems*(self: Model, items: seq[Item]) =
    let itemsToAppend = self.filterExistingItems(items)
    if(itemsToAppend.len == 0):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let first = self.items.len
    let last = first + itemsToAppend.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items.add(itemsToAppend)
    self.endInsertRows()
    self.countChanged()

  proc appendItem*(self: Model, item: Item) =
    if(self.findIndexForMessageId(item.id) != -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc prependItem*(self: Model, item: Item) =
    if(self.findIndexForMessageId(item.id) != -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, 0, 0)
    self.items.insert(item, 0)
    self.endInsertRows()
    self.countChanged()

  proc insertItemBasedOnTimestamp*(self: Model, item: Item) =
    if(self.findIndexForMessageId(item.id) != -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let position = self.findIndexBasedOnTimestampToInsertTo(item.timestamp)

    self.beginInsertRows(parentModelIndex, position, position)
    self.items.insert(item, position)
    self.endInsertRows()

    if position > 0:
      self.updateItemAtIndex(position - 1)
    self.countChanged()

  proc removeItem*(self: Model, messageId: string) =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()
    
    if self.items.len > 0 and ind > 0 and ind < self.items.len:
        self.updateItemAtIndex(ind - 1)
    self.countChanged()

  proc getItemWithMessageId*(self: Model, messageId: string): Item =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    return self.items[ind]

  proc addReaction*(self: Model, messageId: string, emojiId: EmojiId, didIReactWithThisEmoji: bool,
    userPublicKey: string, userDisplayName: string, reactionId: string) =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    self.items[ind].addReaction(emojiId, didIReactWithThisEmoji, userPublicKey, userDisplayName, reactionId)

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Reactions.int])

  proc removeReaction*(self: Model, messageId: string, emojiId: EmojiId, reactionId: string, didIRemoveThisReaction: bool) =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    self.items[ind].removeReaction(emojiId, reactionId, didIRemoveThisReaction)

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Reactions.int])

  proc pinUnpinMessage*(self: Model, messageId: string, pin: bool, pinnedBy: string) =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    self.items[ind].pinned = pin
    self.items[ind].pinnedBy = pinnedBy

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Pinned.int, ModelRole.PinnedBy.int])

  proc getMessageByIdAsJson*(self: Model, messageId: string): JsonNode =
    for it in self.items:
      if(it.id == messageId):
        return it.toJsonNode()

  proc getMessageByIndexAsJson*(self: Model, index: int): JsonNode =
    if(index < 0 or index >= self.items.len):
      return
    self.items[index].toJsonNode()

  iterator modelContactUpdateIterator*(self: Model, contactId: string): Item =
    for i in 0 ..< self.items.len:
      yield self.items[i]

      var roles: seq[int]
      if(self.items[i].senderId == contactId):
        roles = @[ModelRole.SenderDisplayName.int, ModelRole.SenderLocalName.int,
          ModelRole.SenderIcon.int, ModelRole.SenderIsAdded.int, ModelRole.SenderTrustStatus.int]
      if(self.items[i].pinnedBy == contactId):
        roles.add(ModelRole.PinnedBy.int)
      if(self.items[i].messageContainsMentions):
        roles.add(@[ModelRole.MessageText.int, ModelRole.MessageContainsMentions.int])

      if(roles.len > 0):
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, roles)

  proc setEditModeOn*(self: Model, messageId: string)  =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    self.items[ind].editMode = true

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.EditMode.int])

  proc setEditModeOff*(self: Model, messageId: string)  =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    self.items[ind].editMode = false

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.EditMode.int])

  proc updateEditedMsg*(
      self: Model,
      messageId: string,
      updatedMsg: string,
      messageContainsMentions: bool,
      links: seq[string],
      mentionedUsersPks: seq[string]
      ) =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return

    self.items[ind].messageText = updatedMsg
    self.items[ind].messageContainsMentions = messageContainsMentions
    self.items[ind].isEdited = true
    self.items[ind].links = links
    self.items[ind].mentionedUsersPks = mentionedUsersPks

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[
      ModelRole.MessageText.int,
      ModelRole.MessageContainsMentions.int,
      ModelRole.IsEdited.int,
      ModelRole.Links.int,
      ModelRole.MentionedUsersPks.int
      ])

  proc clear*(self: Model) =
    self.beginResetModel()
    self.items = @[]
    self.endResetModel()
    self.countChanged()

  proc refreshItemWithId*(self: Model, messageId: string) =
    let ind = self.findIndexForMessageId(messageId)
    if(ind == -1):
      return
    self.updateItemAtIndex(ind)
