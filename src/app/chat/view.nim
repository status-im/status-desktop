import NimQml, Tables, json, sequtils, chronicles, times, re, sugar, strutils, os, sets, strformat
import ../../status/status
import ../../status/mailservers
import ../../status/stickers
import ../../status/libstatus/accounts/constants
import ../../status/libstatus/mailservers as status_mailservers
import ../../status/accounts as status_accounts
import ../../status/chat as status_chat
import ../../status/messages as status_messages
import ../../status/libstatus/wallet as status_wallet
import ../../status/libstatus/stickers as status_stickers
import ../../status/contacts as status_contacts
import ../../status/ens as status_ens
import ../../status/chat/[chat, message]
import ../../status/wallet
import ../../status/libstatus/types
import ../../status/profile/profile
import web3/[conversions, ethtypes]
import ../../status/threads
import views/channels_list, views/message_list, views/chat_item, views/sticker_pack_list, views/sticker_list, views/suggestions_list
import json_serialization
import ../../status/libstatus/utils

logScope:
  topics = "chats-view"

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      status: Status
      chats*: ChannelsList
      currentSuggestions*: SuggestionsList
      callResult: string
      messageList*: Table[string, ChatMessageList]
      activeChannel*: ChatItemView
      stickerPacks*: StickerPackList
      recentStickers*: StickerList
      replyTo: string
      pubKey*: string
      channelOpenTime*: Table[string, int64]
      connected: bool
      unreadMessageCnt: int
      oldestMessageTimestamp: int64
      loadingMessages: bool

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc delete(self: ChatsView) = 
    self.chats.delete
    self.activeChannel.delete
    self.currentSuggestions.delete
    for msg in self.messageList.values:
      msg.delete
    self.messageList = initTable[string, ChatMessageList]()
    self.channelOpenTime = initTable[string, int64]()
    self.QAbstractListModel.delete

  proc newChatsView*(status: Status): ChatsView =
    new(result, delete)
    result.status = status
    result.connected = false
    result.chats = newChannelsList(status)
    result.activeChannel = newChatItemView(status)
    result.currentSuggestions = newSuggestionsList()
    result.messageList = initTable[string, ChatMessageList]()
    result.stickerPacks = newStickerPackList()
    result.recentStickers = newStickerList()
    result.unreadMessageCnt = 0
    result.pubKey = ""
    result.loadingMessages = false
    result.setup()

  proc oldestMessageTimestampChanged*(self: ChatsView) {.signal.}

  proc getOldestMessageTimestamp*(self: ChatsView): QVariant {.slot.}  =
    newQVariant($self.oldestMessageTimestamp)

  QtProperty[QVariant] oldestMsgTimestamp:
    read = getOldestMessageTimestamp
    notify = oldestMessageTimestampChanged

  proc setLastMessageTimestamp(self: ChatsView, force = false) = 
    if self.status.chat.lastMessageTimestamps.hasKey(self.activeChannel.id):
      if force or self.status.chat.lastMessageTimestamps[self.activeChannel.id] <= self.oldestMessageTimestamp:
        self.oldestMessageTimestamp = self.status.chat.lastMessageTimestamps[self.activeChannel.id]
    else:
      let topics = self.status.mailservers.getMailserverTopicsByChatId(self.activeChannel.id)
      if topics.len > 0:
        self.oldestMessageTimestamp = topics[0].lastRequest
      else:
        self.oldestMessageTimestamp = times.toUnix(times.getTime())
    self.oldestMessageTimestampChanged()

  proc addStickerPackToList*(self: ChatsView, stickerPack: StickerPack, isInstalled, isBought, isPending: bool) =
    self.stickerPacks.addStickerPackToList(stickerPack, newStickerList(stickerPack.stickers), isInstalled, isBought, isPending)
  
  proc getStickerPackList(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.stickerPacks)

  QtProperty[QVariant] stickerPacks:
    read = getStickerPackList

  proc buyPackGasEstimate*(self: ChatsView, packId: int, address: string, price: string): int {.slot.} =
    var success: bool
    result = self.status.stickers.estimateGas(packId, address, price, success)
    if not success:
      result = 325000

  proc transactionWasSent*(self: ChatsView, txResult: string) {.signal.}
  proc transactionCompleted*(self: ChatsView, success: bool, txHash: string, revertReason: string = "") {.signal.}

  proc buyStickerPack*(self: ChatsView, packId: int, address: string, price: string, gas: string, gasPrice: string, password: string): string {.slot.} =
    var success: bool
    let response = self.status.stickers.buyPack(packId, address, price, gas, gasPrice, password, success)
    # TODO: 
    # check if response["error"] is not null and handle the error
    result = $(%* { "result": %response, "success": %success })
    if success:
      self.stickerPacks.updateStickerPackInList(packId, false, true)
      self.transactionWasSent(response)

  proc obtainAvailableStickerPacks*(self: ChatsView) =
    spawnAndSend(self, "setAvailableStickerPacks") do:
      let availableStickerPacks = status_stickers.getAvailableStickerPacks()
      var packs: seq[StickerPack] = @[]
      for packId, stickerPack in availableStickerPacks.pairs:
        packs.add(stickerPack)
      $(%*(packs))

  proc stickerPacksLoaded*(self: ChatsView) {.signal.}

  proc installedStickerPacksUpdated*(self: ChatsView) {.signal.}

  proc recentStickersUpdated*(self: ChatsView) {.signal.}

  proc setAvailableStickerPacks*(self: ChatsView, availableStickersJSON: string) {.slot.} =
    let
      accounts = status_wallet.getWalletAccounts() # TODO: make generic
      installedStickerPacks = self.status.stickers.getInstalledStickerPacks()
    var
      purchasedStickerPacks: seq[int]
    for account in accounts:
      let address = parseAddress(account.address)
      purchasedStickerPacks = self.status.stickers.getPurchasedStickerPacks(address)
    let availableStickers = JSON.decode($availableStickersJSON, seq[StickerPack])

    let pendingTransactions = status_wallet.getPendingTransactions().parseJson["result"]
    var pendingStickerPacks = initHashSet[int]()
    for trx in pendingTransactions.getElems():
      if trx["type"].getStr == $PendingTransactionType.BuyStickerPack:
        pendingStickerPacks.incl(trx["data"].getStr.parseInt)

    for stickerPack in availableStickers:
      let isInstalled = installedStickerPacks.hasKey(stickerPack.id)
      let isBought = purchasedStickerPacks.contains(stickerPack.id)
      let isPending = pendingStickerPacks.contains(stickerPack.id) and not isBought
      self.status.stickers.availableStickerPacks[stickerPack.id] = stickerPack
      self.addStickerPackToList(stickerPack, isInstalled, isBought, isPending)
    self.stickerPacksLoaded()
    self.installedStickerPacksUpdated()

  proc getChatsList(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats)

  QtProperty[QVariant] chats:
    read = getChatsList

  proc getChannelColor*(self: ChatsView, channel: string): string {.slot.} =
    self.chats.getChannelColor(channel)

  proc replaceMentionsWithPubKeys(self: ChatsView, mentions: seq[string], contacts: seq[Profile], message: string, predicate: proc (contact: Profile): string): string =
    var updatedMessage = message
    for mention in mentions:
      let matches = contacts.filter(c => "@" & predicate(c).toLowerAscii == mention.toLowerAscii).map(c => c.address)
      if matches.len > 0:
        let pubKey = matches[0]
        var startIndex = 0
        var index = updatedMessage.find(mention)

        while index > -1:
          if index == 0 or updatedMessage[index-1] == ' ':
            updatedMessage = updatedMessage.replaceWord(mention, '@' & pubKey)
          startIndex = index + mention.len
          index = updatedMessage.find(mention, startIndex)

    result = updatedMessage

  proc plainText(self: ChatsView, input: string): string {.slot.} =
    result = plain_text(input)

  proc sendMessage*(self: ChatsView, message: string, replyTo: string, contentType: int = ContentType.Message.int) {.slot.} =
    let aliasPattern = re(r"(@[A-z][a-z]* [A-z][a-z]* [A-z][a-z]*)", flags = {reStudy, reIgnoreCase})
    let ensPattern = re(r"(@\w*(?=\.stateofus\.eth))", flags = {reStudy, reIgnoreCase})
    let namePattern = re(r"(@\w*)", flags = {reStudy, reIgnoreCase})

    let contacts = self.status.contacts.getContacts()

    let aliasMentions = findAll(message, aliasPattern)
    let ensMentions = findAll(message, ensPattern)
    let nameMentions = findAll(message, namePattern)

    var m = self.replaceMentionsWithPubKeys(aliasMentions, contacts, message, (c => c.alias))
    m = self.replaceMentionsWithPubKeys(ensMentions, contacts, m, (c => c.ensName))
    m = self.replaceMentionsWithPubKeys(nameMentions, contacts, m, (c => c.ensName.split(".")[0]))
    self.status.chat.sendMessage(self.activeChannel.id, m, replyTo, contentType)

  proc verifyMessageSent*(self: ChatsView, data: string) {.slot.} =
    let messageData = data.parseJson
    self.messageList[messageData["chatId"].getStr].checkTimeout(messageData["id"].getStr)

  proc resendMessage*(self: ChatsView, chatId: string, messageId: string) {.slot.} =
    self.status.messages.trackMessage(messageId, chatId)
    self.status.chat.resendMessage(messageId)
    self.messageList[chatId].resetTimeOut(messageId)

  proc sendImage*(self: ChatsView, imagePath: string): string {.slot.} =
    result = ""
    try:
      var image: string = replace(imagePath, "file://", "")
      if defined(windows):
        # Windows doesn't work with paths starting with a slash
        image.removePrefix('/')
      let tmpImagePath = image_resizer(image, 2000, TMPDIR)
      self.status.chat.sendImage(self.activeChannel.id, tmpImagePath)
      removeFile(tmpImagePath)
    except Exception as e:
      error "Error sending the image", msg = e.msg
      result = fmt"Error sending the image: {e.msg}"

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc sendingMessage*(self: ChatsView) {.signal.}

  proc appReady*(self: ChatsView) {.signal.}

  proc alias*(self: ChatsView, pubKey: string): string {.slot.} =
    generateAlias(pubKey)

  proc userNameOrAlias*(self: ChatsView, pubKey: string): string {.slot.} =
    if self.status.chat.contacts.hasKey(pubKey):
      return status_ens.userNameOrAlias(self.status.chat.contacts[pubKey])
    generateAlias(pubKey)

  proc markAllChannelMessagesReadByIndex*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    discard self.status.chat.markAllChannelMessagesRead(selectedChannel.id)

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    if(self.chats.chats.len == 0): return
    if(not self.activeChannel.chatItem.isNil and self.activeChannel.chatItem.unviewedMessagesCount > 0):
      var response = self.status.chat.markAllChannelMessagesRead(self.activeChannel.id)
      if not response.hasKey("error"):
        self.chats.clearUnreadMessagesCount(self.activeChannel.chatItem)
    let selectedChannel = self.chats.getChannel(index)
    if self.activeChannel.id == selectedChannel.id: return

    if selectedChannel.chatType.isOneToOne:
      selectedChannel.name = self.userNameOrAlias(selectedChannel.id)

    self.activeChannel.setChatItem(selectedChannel)
    self.status.chat.setActiveChannel(selectedChannel.id)

  proc getActiveChannelIdx(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats.chats.findIndexById(self.activeChannel.id))

  QtProperty[QVariant] activeChannelIndex:
    read = getActiveChannelIdx
    write = setActiveChannelByIndex
    notify = activeChannelChanged

  proc getNumInstalledStickerPacks(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.status.stickers.installedStickerPacks.len)

  QtProperty[QVariant] numInstalledStickerPacks:
    read = getNumInstalledStickerPacks
    notify = installedStickerPacksUpdated

  proc installStickerPack*(self: ChatsView, packId: int) {.slot.} =
    self.status.stickers.installStickerPack(packId)
    self.stickerPacks.updateStickerPackInList(packId, true, false)
    self.installedStickerPacksUpdated()

  proc resetStickerPackBuyAttempt*(self: ChatsView, packId: int) {.slot.} =
    self.stickerPacks.updateStickerPackInList(packId, false, false)
  
  proc uninstallStickerPack*(self: ChatsView, packId: int) {.slot.} =
    self.status.stickers.uninstallStickerPack(packId)
    self.status.stickers.removeRecentStickers(packId)
    self.stickerPacks.updateStickerPackInList(packId, false, false)
    self.recentStickers.removeStickersFromList(packId)
    self.installedStickerPacksUpdated()
    self.recentStickersUpdated()

  proc getRecentStickerList*(self: ChatsView): QVariant {.slot.} =
    result = newQVariant(self.recentStickers)

  QtProperty[QVariant] recentStickers:
    read = getRecentStickerList
    notify = recentStickersUpdated

  proc setActiveChannel*(self: ChatsView, channel: string) {.slot.} =
    if(channel == ""): return
    self.activeChannel.setChatItem(self.chats.getChannel(self.chats.chats.findIndexById(channel)))
    discard self.status.chat.markAllChannelMessagesRead(self.activeChannel.id)
    self.setLastMessageTimestamp(true)
    self.activeChannelChanged()

  proc getActiveChannel*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.activeChannel)

  QtProperty[QVariant] activeChannel:
    read = getActiveChannel
    write = setActiveChannel
    notify = activeChannelChanged


  proc getCurrentSuggestions(self: ChatsView): QVariant {.slot.} =
    return newQVariant(self.currentSuggestions)

  QtProperty[QVariant] suggestionList:
    read = getCurrentSuggestions

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList(channel, self.status)
      self.channelOpenTime[channel] = now().toTime.toUnix * 1000

  proc messagePushed*(self: ChatsView) {.signal.}
  proc newMessagePushed*(self: ChatsView) {.signal.}

  proc messageNotificationPushed*(self: ChatsView, chatId: string, text: string, messageType: string, chatType: int, timestamp: string, identicon: string, username: string, hasMention: bool) {.signal.}

  proc messagesCleared*(self: ChatsView) {.signal.}

  proc clearMessages*(self: ChatsView, id: string) =
    self.messageList[id].clear()
    self.messagesCleared()

  proc pushMessages*(self:ChatsView, messages: var seq[Message]) =
    for msg in messages.mitems:
      self.upsertChannel(msg.chatId)
      msg.alias = self.status.chat.getUserName(msg.fromAuthor, msg.alias)
      self.messageList[msg.chatId].add(msg)
      self.messagePushed()
      if self.channelOpenTime.getOrDefault(msg.chatId, high(int64)) < msg.timestamp.parseFloat.fromUnixFloat.toUnix:
        if msg.chatId != self.activeChannel.id:
          let channel = self.chats.getChannelById(msg.chatId)
          if not channel.muted:
            self.messageNotificationPushed(msg.chatId, msg.text, msg.messageType, channel.chatType.int, msg.timestamp, msg.identicon, msg.alias, msg.hasMention)
        else:
          discard self.status.chat.markMessagesSeen(msg.chatId, @[msg.id])
          self.newMessagePushed()

  proc messageEmojiReactionId(self: ChatsView, chatId: string, messageId: string, emojiId: int): string =
    if (self.messageList[chatId].getReactions(messageId) == "") :
      return ""

    let oldReactions = parseJson(self.messageList[chatId].getReactions(messageId))

    for pair in oldReactions.pairs:
      if (pair[1]["emojiId"].getInt == emojiId and pair[1]["from"].getStr == self.pubKey):
        return pair[0]
    return ""

  proc toggleEmojiReaction*(self: ChatsView, messageId: string, emojiId: int) {.slot.} =
    let emojiReactionId = self.messageEmojiReactionId(self.activeChannel.id, messageId, emojiId)
    if (emojiReactionId == ""):
      self.status.chat.addEmojiReaction(self.activeChannel.id, messageId, emojiId)
    else:
      self.status.chat.removeEmojiReaction(emojiReactionId)

  proc pushReactions*(self:ChatsView, reactions: var seq[Reaction]) =
    let t = reactions.len
    for reaction in reactions.mitems:
      let messageList = self.messageList[reaction.chatId]
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


  proc updateUsernames*(self:ChatsView, contacts: seq[Profile]) =
    if contacts.len > 0:
      # Updating usernames for all the messages list
      for k in self.messageList.keys:
        self.messageList[k].updateUsernames(contacts)

  proc updateChannelForContacts*(self: ChatsView, contacts: seq[Profile]) =
    for contact in contacts:
      let channel = self.chats.getChannelById(contact.id)
      if not channel.isNil:
        if contact.localNickname == "":
          channel.name = contact.username
        else:
          channel.name = contact.localNickname
        self.chats.updateChat(channel, false)
        if (self.activeChannel.id == channel.id):
          self.activeChannel.setChatItem(channel)
          self.activeChannelChanged()


  proc markMessageAsSent*(self:ChatsView, chat: string, messageId: string) =
    self.messageList[chat].markMessageAsSent(messageId)

  proc getMessageList(self: ChatsView): QVariant {.slot.} =
    self.upsertChannel(self.activeChannel.id)
    return newQVariant(self.messageList[self.activeChannel.id])

  QtProperty[QVariant] messageList:
    read = getMessageList
    notify = activeChannelChanged

  proc pushChatItem*(self: ChatsView, chatItem: Chat) =
    discard self.chats.addChatItemToList(chatItem)
    self.messagePushed()

  proc addRecentStickerToList*(self: ChatsView, sticker: Sticker) =
    self.recentStickers.addStickerToList(sticker)
    self.recentStickersUpdated()
  
  proc copyToClipboard*(self: ChatsView, content: string) {.slot.} =
    setClipBoardText(content)

  proc getLinkPreviewData*(self: ChatsView, link: string): string {.slot.} =
    result = $self.status.chat.getLinkPreviewData(link)

  proc sendSticker*(self: ChatsView, hash: string, pack: int) {.slot.} =
    let sticker = Sticker(hash: hash, packId: pack)
    self.addRecentStickerToList(sticker)
    self.status.chat.sendSticker(self.activeChannel.id, sticker)

  proc joinChat*(self: ChatsView, channel: string, chatTypeInt: int): int {.slot.} =
    self.status.chat.join(channel, ChatType(chatTypeInt))
    self.setActiveChannel(channel)

  proc chatGroupJoined(self: ChatsView, channel: string) {.signal.}

  proc joinGroup*(self: ChatsView) {.slot.} =
    self.status.chat.confirmJoiningGroup(self.activeChannel.id)
    self.activeChannel.membershipChanged()
    self.chatGroupJoined(self.activeChannel.id)

  proc messagesLoaded*(self: ChatsView) {.signal.}

  proc loadMoreMessages*(self: ChatsView) {.slot.} =
    trace "Loading more messages", chaId = self.activeChannel.id
    self.status.chat.chatMessages(self.activeChannel.id, false)
    self.status.chat.chatReactions(self.activeChannel.id, false)
    if self.status.chat.msgCursor[self.activeChannel.id] == "":
      self.setLastMessageTimestamp()
    self.messagesLoaded();

  proc loadMoreMessagesWithIndex*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    trace "Loading more messages", chaId = selectedChannel.id
    self.status.chat.chatMessages(selectedChannel.id, false)
    self.status.chat.chatReactions(selectedChannel.id, false)
    self.setLastMessageTimestamp()
    self.messagesLoaded();

  proc loadingMessagesChanged*(self: ChatsView) {.signal.}

  proc hideLoadingIndicator*(self: ChatsView) {.slot.} =
    self.loadingMessages = false
    self.loadingMessagesChanged()

  proc isLoadingMessages(self: ChatsView): QVariant {.slot.} =
    return newQVariant(self.loadingMessages)

  QtProperty[QVariant] loadingMessages:
    read = isLoadingMessages
    notify = loadingMessagesChanged

  proc requestMoreMessages*(self: ChatsView, fetchRange: int) {.slot.} =
    self.loadingMessages = true
    self.loadingMessagesChanged()
    let topics = self.status.mailservers.getMailserverTopicsByChatId(self.activeChannel.id).map(topic => topic.topic)
    let currentOldestMessageTimestamp = self.oldestMessageTimestamp
    self.oldestMessageTimestamp = self.oldestMessageTimestamp - fetchRange

    self.status.mailservers.requestMessages(topics, self.oldestMessageTimestamp, currentOldestMessageTimestamp, true)
    self.oldestMessageTimestampChanged()
    self.messagesLoaded();

  proc leaveChatByIndex*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    self.status.chat.leave(selectedChannel.id)

  proc leaveActiveChat*(self: ChatsView) {.slot.} =
    self.status.chat.leave(self.activeChannel.id)

  proc removeChat*(self: ChatsView, chatId: string) =
    discard self.chats.removeChatItemFromList(chatId)
    self.messageList[chatId].delete
    self.messageList.del(chatId)

  proc clearChatHistory*(self: ChatsView, id: string) {.slot.} =
    self.status.chat.clearHistory(id)

  proc clearChatHistoryByIndex*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    self.status.chat.clearHistory(selectedChannel.id)

  proc unreadMessages*(self: ChatsView): int {.slot.} =
    result = self.unreadMessageCnt

  proc unreadMessagesCntChanged*(self: ChatsView) {.signal.}

  QtProperty[int] unreadMessagesCount:
    read = unreadMessages
    notify = unreadMessagesCntChanged

  proc calculateUnreadMessages*(self: ChatsView) =
    var unreadTotal = 0
    for chatItem in self.chats.chats:
      unreadTotal = unreadTotal + chatItem.unviewedMessagesCount
    if unreadTotal != self.unreadMessageCnt:
      self.unreadMessageCnt = unreadTotal
      self.unreadMessagesCntChanged()

  proc updateChats*(self: ChatsView, chats: seq[Chat], triggerChange:bool = true) =
    for chat in chats:
      self.upsertChannel(chat.id)
      self.chats.updateChat(chat, triggerChange)
      if(self.activeChannel.id == chat.id):
        self.activeChannel.setChatItem(chat)
        self.currentSuggestions.setNewData(self.status.contacts.getContacts())
    self.calculateUnreadMessages()

  proc deleteMessage*(self: ChatsView, channelId: string, messageId: string) =
    self.messageList[channelId].deleteMessage(messageId)

  proc renameGroup*(self: ChatsView, newName: string) {.slot.} =
    self.status.chat.renameGroup(self.activeChannel.id, newName)

  proc createGroup*(self: ChatsView, groupName: string, pubKeys: string) {.slot.} =
    let pubKeysSeq = map(parseJson(pubKeys).getElems(), proc(x:JsonNode):string = x.getStr)
    self.status.chat.createGroup(groupName, pubKeysSeq)

  proc addGroupMembers*(self: ChatsView, chatId: string, pubKeys: string) {.slot.} =
    let pubKeysSeq = map(parseJson(pubKeys).getElems(), proc(x:JsonNode):string = x.getStr)
    self.status.chat.addGroupMembers(chatId, pubKeysSeq)

  proc kickGroupMember*(self: ChatsView, chatId: string, pubKey: string) {.slot.} =
    self.status.chat.kickGroupMember(chatId, pubKey)

  proc makeAdmin*(self: ChatsView, chatId: string, pubKey: string) {.slot.} =
    self.status.chat.makeAdmin(chatId, pubKey)

  proc isEnsVerified*(self: ChatsView, id: string): bool {.slot.} =
    if id == "": return false
    let contact = self.status.contacts.getContactByID(id)
    if contact == nil:
      return false
    result = contact.ensVerified

  proc formatENSUsername*(self: ChatsView, username: string): string {.slot.} =
    result = status_ens.addDomain(username)

  proc generateIdenticon*(self: ChatsView, pk: string): string {.slot.} =
    result = status_accounts.generateIdenticon(pk)

  # Resolving a ENS name
  proc resolveENS*(self: ChatsView, ens: string) {.slot.} =
    spawnAndSend(self, "ensResolved") do: # Call self.ensResolved(string) when ens is resolved
      status_ens.pubkey(ens)

  proc ensWasResolved*(self: ChatsView, resolvedPubKey: string) {.signal.}

  proc ensResolved(self: ChatsView, pubKey: string) {.slot.} =
    self.ensWasResolved(pubKey)

  proc isConnected*(self: ChatsView): bool {.slot.} =
    result = self.connected

  proc onlineStatusChanged(self: ChatsView, connected: bool) {.signal.}

  proc setConnected*(self: ChatsView, connected: bool) =
    self.connected = connected
    self.onlineStatusChanged(connected)

  QtProperty[bool] isOnline:
    read = isConnected
    notify = onlineStatusChanged

  proc muteChannel*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    self.status.chat.muteChat(selectedChannel.id)
    selectedChannel.muted = true
    self.chats.updateChat(selectedChannel, false)

  proc unmuteChannel*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    self.status.chat.unmuteChat(selectedChannel.id)
    selectedChannel.muted = false
    self.chats.updateChat(selectedChannel, false)

  proc channelIsMuted*(self: ChatsView, channelIndex: int): bool {.slot.} =
    if (self.chats.chats.len == 0): return false
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return false
    result = selectedChannel.muted  

  ### Chat commands functions ###
  proc acceptRequestAddressForTransaction*(self: ChatsView, messageId: string , address: string) {.slot.} =
    self.status.chat.acceptRequestAddressForTransaction(messageId, address)

  proc declineRequestAddressForTransaction*(self: ChatsView, messageId: string) {.slot.} =
    self.status.chat.declineRequestAddressForTransaction(messageId)

  proc declineRequestTransaction*(self: ChatsView, messageId: string) {.slot.} =
    self.status.chat.declineRequestTransaction(messageId)

  proc requestAddressForTransaction*(self: ChatsView, chatId: string, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.status.chat.requestAddressForTransaction(chatId, fromAddress, amount, tokenAddress)
    

  proc requestTransaction*(self: ChatsView, chatId: string, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.status.chat.requestTransaction(chatId, fromAddress, amount, tokenAddress)
