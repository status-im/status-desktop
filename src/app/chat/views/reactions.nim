import NimQml, tables, json, chronicles
import ../../../status/[status, chat/message]
import message_list, chat_item
import ../../../status/libstatus/settings as status_settings
import ../../../status/libstatus/types

logScope:
  topics = "reactions-view"

QtObject:
  type ReactionView* = ref object of QObject
    messageList: ptr Table[string, ChatMessageList]
    activeChannel: ChatItemView
    status: Status
    pubKey*: string

  proc setup(self: ReactionView) =
    self.QObject.setup

  proc delete*(self: ReactionView) =
    self.QObject.delete

  proc newReactionView*(status: Status, messageList: ptr Table[string, ChatMessageList], activeChannel: ChatItemView): ReactionView =
    new(result, delete)
    result = ReactionView()
    result.messageList = messageList
    result.status = status
    result.activeChannel = activeChannel
    result.setup

  proc init*(self: ReactionView) =
    self.pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")

  proc messageEmojiReactionId(self: ReactionView, chatId: string, messageId: string, emojiId: int): string =
    if (self.messageList[][chatId].getReactions(messageId) == "") :
      return ""

    let oldReactions = parseJson(self.messageList[][chatId].getReactions(messageId))

    for pair in oldReactions.pairs:
      if (pair[1]["emojiId"].getInt == emojiId and pair[1]["from"].getStr == self.pubKey):
        return pair[0]
    return ""

  proc toggle*(self: ReactionView, messageId: string, emojiId: int) {.slot.} =
    let emojiReactionId = self.messageEmojiReactionId(self.activeChannel.id, messageId, emojiId)
    if (emojiReactionId == ""):
      self.status.chat.addEmojiReaction(self.activeChannel.id, messageId, emojiId)
    else:
      self.status.chat.removeEmojiReaction(emojiReactionId)
    
  proc push*(self: ReactionView, reactions: var seq[Reaction]) =
    let t = reactions.len
    for reaction in reactions.mitems:
      let messageList = self.messageList[][reaction.chatId]
      var emojiReactions = messageList.getReactions(reaction.messageId)
      var oldReactions: JsonNode
      if (emojiReactions == "") :
        oldReactions = %*{}
      else: 
        oldReactions = parseJson(emojiReactions)

      if (oldReactions.hasKey(reaction.id)):
        if (reaction.retracted):
          # Remove the reaction
          oldReactions.delete(reaction.id)
          messageList.setMessageReactions(reaction.messageId, $oldReactions)
        continue

      oldReactions[reaction.id] = %* {
        "from": reaction.fromAccount,
        "emojiId": reaction.emojiId
      }
      messageList.setMessageReactions(reaction.messageId, $oldReactions)
