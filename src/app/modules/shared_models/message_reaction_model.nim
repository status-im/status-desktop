import NimQml, Tables, json, strutils, strformat

import message_reaction_item

type
  ModelRole {.pure.} = enum
    EmojiId = UserRole + 1
    DidIReactWithThisEmoji
    NumberOfReactions
    JsonArrayOfUsersReactedWithThisEmoji

QtObject:
  type
    MessageReactionModel* = ref object of QAbstractListModel
      items: seq[MessageReactionItem]

  proc delete(self: MessageReactionModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: MessageReactionModel) =
    self.QAbstractListModel.setup

  proc newMessageReactionModel*(): MessageReactionModel =
    new(result, delete)
    result.setup

  proc `$`*(self: MessageReactionModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """
  proc countChanged(self: MessageReactionModel) {.signal.}

  proc getCount(self: MessageReactionModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: MessageReactionModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: MessageReactionModel): Table[int, string] =
    {
      ModelRole.EmojiId.int:"emojiId",
      ModelRole.DidIReactWithThisEmoji.int:"didIReactWithThisEmoji",
      ModelRole.NumberOfReactions.int:"numberOfReactions",
      ModelRole.JsonArrayOfUsersReactedWithThisEmoji.int: "jsonArrayOfUsersReactedWithThisEmoji"
    }.toTable

  method data(self: MessageReactionModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.EmojiId:
      result = newQVariant(item.emojiId.int)
    of ModelRole.DidIReactWithThisEmoji:
      result = newQVariant(item.didIReactWithThisEmoji)
    of ModelRole.NumberOfReactions:
      result = newQVariant(item.numberOfReactions)
    of ModelRole.JsonArrayOfUsersReactedWithThisEmoji:
      # Would be good if we could return QVariant of array (seq) here, but it's not supported in our NimQml,
      # because of that we're returning json array as a string.
      result = newQVariant($item.jsonArrayOfUsersReactedWithThisEmoji)

  proc reactionItemWithEmojiIdExists(self: MessageReactionModel, emojiId: EmojiId): bool =
    for it in self.items:
      if(it.emojiId == emojiId):
        return true
    return false

  proc getIndexOfTheItemWithEmojiId(self: MessageReactionModel, emojiId: EmojiId): int =
    for i in 0..<self.items.len:
      if(self.items[i].emojiId == emojiId):
        return i
    return -1

  proc findPositionForTheItemWithEmojiId(self: MessageReactionModel, emojiId: EmojiId): int =
    if(self.items.len == 0):
      return 0

    for i in 0..<self.items.len:
      if(emojiId < self.items[i].emojiId):
        return i

    return self.items.len

  proc shouldAddReaction*(self: MessageReactionModel, emojiId: EmojiId, userPublicKey: string): bool =
    let ind = self.getIndexOfTheItemWithEmojiId(emojiId)
    if(ind == -1):
      return true
    return self.items[ind].shouldAddReaction(userPublicKey)

  proc getReactionId*(self: MessageReactionModel, emojiId: EmojiId, userPublicKey: string): string =
    let ind = self.getIndexOfTheItemWithEmojiId(emojiId)
    if(ind == -1):
      return ""
    return self.items[ind].getReactionId(userPublicKey)

  proc addReaction*(self: MessageReactionModel, emojiId: EmojiId, didIReactWithThisEmoji: bool, userPublicKey: string,
    userDisplayName: string, reactionId: string) =
    if(self.reactionItemWithEmojiIdExists(emojiId)):
      let ind = self.getIndexOfTheItemWithEmojiId(emojiId)
      if(ind == -1):
        return
      self.items[ind].addReaction(didIReactWithThisEmoji, userPublicKey, userDisplayName, reactionId)
      let index = self.createIndex(ind, 0, nil)
      defer: index.delete
      self.dataChanged(index, index)
    else:
      let parentModelIndex = newQModelIndex()
      defer: parentModelIndex.delete

      var item = initMessageReactionItem(emojiId)
      item.addReaction(didIReactWithThisEmoji, userPublicKey, userDisplayName, reactionId)
      let position = self.findPositionForTheItemWithEmojiId(emojiId) # Model should maintain items based on the emoji id.

      self.beginInsertRows(parentModelIndex, position, position)
      self.items.insert(item, position)
      self.endInsertRows()

    self.countChanged()

  proc removeReaction*(self: MessageReactionModel, emojiId: EmojiId, reactionId: string, didIRemoveThisReaction: bool) =
    let ind = self.getIndexOfTheItemWithEmojiId(emojiId)
    if(ind == -1):
      return
    self.items[ind].removeReaction(reactionId, didIRemoveThisReaction)

    if(self.items[ind].numberOfReactions() == 0):
      # remove item if there are no reactions for this emoji id
      let parentModelIndex = newQModelIndex()
      defer: parentModelIndex.delete

      self.beginRemoveRows(parentModelIndex, ind, ind)
      self.items.delete(ind)
      self.endRemoveRows()
      self.countChanged()
    else:
      let index = self.createIndex(ind, 0, nil)
      defer: index.delete
      self.dataChanged(index, index)
