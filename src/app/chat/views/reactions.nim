import NimQml, tables, json, chronicles
import status/[status, chat/chat, settings]
import message_list, chat_item
import status/utils as status_utils
import status/types/[message, setting]

logScope:
  topics = "reactions-view"

QtObject:
  type ReactionView* = ref object of QObject
    messageList: ptr OrderedTable[string, ChatMessageList]
    pinnedMessageList: ptr OrderedTable[string, ChatMessageList]
    activeChannel: ChatItemView
    status: Status
    pubKey*: string

  proc setup(self: ReactionView) =
    self.QObject.setup

  proc delete*(self: ReactionView) =
    self.QObject.delete

  proc newReactionView*(status: Status, messageList: ptr OrderedTable[string, ChatMessageList], pinnedMessageList: ptr OrderedTable[string, ChatMessageList], activeChannel: ChatItemView): ReactionView =
    new(result, delete)
    result = ReactionView()
    result.messageList = messageList
    result.pinnedMessageList = pinnedMessageList
    result.status = status
    result.activeChannel = activeChannel
    result.setup

  proc init*(self: ReactionView) =
    self.pubKey = self.status.settings.getSetting[:string](Setting.PublicKey, "0x0")

  proc messageEmojiReactionId(self: ReactionView, chatId: string, messageId: string, emojiId: int): string =
    let chat = self.status.chat.channels[chatId]
    var chatId = chatId
    if chat.chatType == ChatType.Profile:
      chatId = status_utils.getTimelineChatId()

    if (self.messageList[][chatId].getReactions(messageId) == "") :
      return ""

    let oldReactions = parseJson(self.messageList[][chatId].getReactions(messageId))

    for pair in oldReactions.pairs:
      if (pair[1]["emojiId"].getInt == emojiId and pair[1]["from"].getStr == self.pubKey):
        return pair[0]
    return ""

  proc toggle*(self: ReactionView, messageId: string, chatId: string, emojiId: int) {.slot.} =
    let emojiReactionId = self.messageEmojiReactionId(chatId, messageId, emojiId)
    if (emojiReactionId == ""):
      self.status.chat.addEmojiReaction(chatId, messageId, emojiId)
    else:
      self.status.chat.removeEmojiReaction(emojiReactionId)
    
  proc push*(self: ReactionView, reactions: var seq[Reaction]) =
    let t = reactions.len
    for reaction in reactions.mitems:

      var chatId: string;
      if reaction.chatId == self.pubKey:
        chatId = reaction.fromAccount
      else:
        chatId = reaction.chatId

      let chat = self.status.chat.channels[chatId]
      var messageList = self.messageList[][chatId]

      if chat.chatType == ChatType.Profile:
        messageList = self.messageList[][status_utils.getTimelineChatId()]

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
          self.pinnedMessageList[][chatId].setMessageReactions(reaction.messageId, $oldReactions)
        continue

      oldReactions[reaction.id] = %* {
        "from": reaction.fromAccount,
        "emojiId": reaction.emojiId
      }
      messageList.setMessageReactions(reaction.messageId, $oldReactions)
      self.pinnedMessageList[][chatId].setMessageReactions(reaction.messageId, $oldReactions)
